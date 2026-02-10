#!/bin/bash -xe
set -o pipefail

# Update system and install StrongSwan and BGP tools
dnf update -y
dnf install -y strongswan strongswan-swanctl iproute2 wget curl git

# Install BIRD (BGP daemon)
dnf install -y epel-release || true
dnf install -y bird2 || dnf install -y bird

# Create directories for VPN configuration
mkdir -p /etc/strongswan/swanctl/conf.d
mkdir -p /etc/strongswan/swanctl/secrets.d
mkdir -p /etc/systemd/network

# Enable IP forwarding
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
EOF
sysctl -p

# VPN Configuration - values from Terraform template variables
# These are replaced by templatefile() function
TUNNEL1_OUTSIDE_IP="${tunnel1_outside_ip}"
TUNNEL1_INSIDE_IP="${tunnel1_inside_ip}"
TUNNEL1_INSIDE_CIDR="${tunnel1_inside_cidr}"
TUNNEL1_PSK="${tunnel1_preshared_key}"
TUNNEL1_BGP_NEIGHBOR="${tunnel1_bgp_neighbor}"
TUNNEL1_BGP_ASN="${tunnel1_bgp_asn}"

TUNNEL2_OUTSIDE_IP="${tunnel2_outside_ip}"
TUNNEL2_INSIDE_IP="${tunnel2_inside_ip}"
TUNNEL2_INSIDE_CIDR="${tunnel2_inside_cidr}"
TUNNEL2_PSK="${tunnel2_preshared_key}"
TUNNEL2_BGP_NEIGHBOR="${tunnel2_bgp_neighbor}"
TUNNEL2_BGP_ASN="${tunnel2_bgp_asn}"

AWS_BGP_ASN="${aws_bgp_asn}"
CUSTOMER_BGP_ASN="${customer_bgp_asn}"

# Configure strongswan with swanctl
cat > /etc/strongswan/swanctl/conf.d/aws-vpn.conf << EOF
connections {
  aws-tunnel1 {
    local_addrs = %any
    remote_addrs = ${TUNNEL1_OUTSIDE_IP}
    
    local {
      auth = psk
    }
    remote {
      auth = psk
    }
    children {
      aws-tunnel1-child {
        local_ts = 0.0.0.0/0
        remote_ts = 0.0.0.0/0
        if_id_in = 1
        if_id_out = 1
        esp_proposals = aes256gcm16-modp2048-sha256
        dpd_action = restart
        close_action = restart
        mode = tunnel
        start_action = start
      }
    }
    version = 2
    mobike = no
    proposals = aes256-sha256-modp2048
    rekey_time = 3600s
    reauth_time = 3600s
  }
  
  aws-tunnel2 {
    local_addrs = %any
    remote_addrs = ${TUNNEL2_OUTSIDE_IP}
    
    local {
      auth = psk
    }
    remote {
      auth = psk
    }
    children {
      aws-tunnel2-child {
        local_ts = 0.0.0.0/0
        remote_ts = 0.0.0.0/0
        if_id_in = 2
        if_id_out = 2
        esp_proposals = aes256gcm16-modp2048-sha256
        dpd_action = restart
        close_action = restart
        mode = tunnel
        start_action = start
      }
    }
    version = 2
    mobike = no
    proposals = aes256-sha256-modp2048
    rekey_time = 3600s
    reauth_time = 3600s
  }
}

secrets {
  ike-aws-tunnel1 {
    id-1 = ${TUNNEL1_OUTSIDE_IP}
    secret = ${TUNNEL1_PSK}
  }
  ike-aws-tunnel2 {
    id-1 = ${TUNNEL2_OUTSIDE_IP}
    secret = ${TUNNEL2_PSK}
  }
}
EOF

# Configure secrets
cat > /etc/strongswan/swanctl/secrets.d/aws-vpn.secrets << EOF
: PSK "${TUNNEL1_PSK}"
: PSK "${TUNNEL2_PSK}"
EOF

# Create VTI interfaces using systemd-networkd
cat > /etc/systemd/network/10-vti1.netdev << EOF
[NetDev]
Name=vti1
Kind=vti

[VTI]
Local=$(hostname -I | awk '{print $1}')
Remote=${TUNNEL1_OUTSIDE_IP}
EOF

cat > /etc/systemd/network/10-vti1.network << EOF
[Match]
Name=vti1

[Network]
Address=${TUNNEL1_INSIDE_IP}/30
EOF

cat > /etc/systemd/network/10-vti2.netdev << EOF
[NetDev]
Name=vti2
Kind=vti

[VTI]
Local=$(hostname -I | awk '{print $1}')
Remote=${TUNNEL2_OUTSIDE_IP}
EOF

cat > /etc/systemd/network/10-vti2.network << EOF
[Match]
Name=vti2

[Network]
Address=${TUNNEL2_INSIDE_IP}/30
EOF

# Restart networkd to apply VTI configuration
systemctl restart systemd-networkd
sleep 5

# Start and enable strongswan
systemctl enable strongswan-swanctl
systemctl start strongswan-swanctl

# Wait for tunnels to establish
echo "Waiting for IPSec tunnels to establish..."
for i in {1..30}; do
    if ip tunnel show | grep -q vti1 && ip tunnel show | grep -q vti2; then
        echo "VTI interfaces are up"
        break
    fi
    sleep 2
done

# Configure BGP with Bird2
# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')

cat > /etc/bird.conf << EOF
log syslog all;

router id ${LOCAL_IP};

protocol device {
    scan time 10;
}

protocol kernel {
    ipv4 {
        import all;
        export filter {
            if net = 0.0.0.0/0 then reject;
            accept;
        };
    };
    learn;
}

protocol bgp aws_tunnel1 {
    description "BGP session to AWS VPN Tunnel 1";
    local as ${CUSTOMER_BGP_ASN};
    neighbor ${TUNNEL1_BGP_NEIGHBOR} as ${AWS_BGP_ASN};
    
    ipv4 {
        import all;
        export all;
    };
    
    multihop;
    connect delay time 10;
    connect retry time 30;
    hold time 90;
    keepalive time 30;
}

protocol bgp aws_tunnel2 {
    description "BGP session to AWS VPN Tunnel 2";
    local as ${CUSTOMER_BGP_ASN};
    neighbor ${TUNNEL2_BGP_NEIGHBOR} as ${AWS_BGP_ASN};
    
    ipv4 {
        import all;
        export all;
    };
    
    multihop;
    connect delay time 10;
    connect retry time 30;
    hold time 90;
    keepalive time 30;
}
EOF

# Start BIRD
systemctl enable bird
systemctl start bird

# Wait a bit for BGP to establish
sleep 10

# Set SELinux context for strongswan (if SELinux is enabled)
if command -v setsebool &> /dev/null; then
    setsebool -P networkmanager_ipsec_connectivity 1 2>/dev/null || true
fi

# Create log directory
mkdir -p /var/log/strongswan
chmod 755 /var/log/strongswan

# Check status
echo "=== StrongSwan Status ===" > /tmp/vpn-status.log
swanctl --list-conns >> /tmp/vpn-status.log 2>&1 || true
swanctl --list-sas >> /tmp/vpn-status.log 2>&1 || true

echo "=== BGP Status ===" >> /tmp/vpn-status.log
birdc show protocols >> /tmp/vpn-status.log 2>&1 || birdc show protocols all >> /tmp/vpn-status.log 2>&1 || true

# Signal completion
echo "User-data script completed successfully" >> /tmp/vpn-status.log
date >> /tmp/vpn-status.log
