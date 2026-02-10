#!/bin/bash -xe
set -o pipefail

# Update system and install StrongSwan and BGP tools
dnf update -y
dnf install -y strongswan strongswan-swanctl iproute2 wget curl git

# Install BIRD (BGP daemon) - available in EPEL or build from source
dnf install -y epel-release
dnf install -y bird2

# Create directories for VPN configuration
mkdir -p /etc/strongswan/ipsec.d
mkdir -p /home/ec2-user/vpn-config

# Download VPN configuration script (this will be generated from Terraform)
# The script expects VPN connection details from AWS

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
sysctl -p

# Configure strongswan
# Note: Configuration files will be populated by a script that reads AWS VPN connection details
# This is a template - actual values come from aws_vpn_connection resource

# Create a script to configure VPN from AWS metadata
cat > /home/ec2-user/vpn-config/configure-vpn.sh << 'CONFIG_SCRIPT'
#!/bin/bash

# Get VPN connection details from Terraform outputs (passed via SSM Parameter Store or user-data)
# For now, we'll create a template that can be populated

# Example structure - actual values will come from aws_vpn_connection attributes
# Tunnel 1 configuration
TUNNEL1_OUTSIDE_IP="<TUNNEL1_OUTSIDE_IP>"
TUNNEL1_INSIDE_CIDR="<TUNNEL1_INSIDE_CIDR>"
TUNNEL1_PSK="<TUNNEL1_PSK>"
TUNNEL1_BGP_IP="<TUNNEL1_BGP_IP>"
TUNNEL1_BGP_ASN="<TUNNEL1_BGP_ASN>"

# Tunnel 2 configuration
TUNNEL2_OUTSIDE_IP="<TUNNEL2_OUTSIDE_IP>"
TUNNEL2_INSIDE_CIDR="<TUNNEL2_INSIDE_CIDR>"
TUNNEL2_PSK="<TUNNEL2_PSK>"
TUNNEL2_BGP_IP="<TUNNEL2_BGP_IP>"
TUNNEL2_BGP_ASN="<TUNNEL2_BGP_ASN>"

AWS_BGP_ASN="64512"  # From Transit Gateway

# Configure strongswan
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
      }
    }
    version = 2
    mobike = no
    proposals = aes256-sha256-modp2048
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
      }
    }
    version = 2
    mobike = no
    proposals = aes256-sha256-modp2048
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

# Create VTI interfaces
cat > /etc/systemd/network/vti1.netdev << EOF
[NetDev]
Name=vti1
Kind=vti
EOF

cat > /etc/systemd/network/vti1.network << EOF
[Match]
Name=vti1

[Network]
Address=${TUNNEL1_BGP_IP}/30
EOF

cat > /etc/systemd/network/vti2.netdev << EOF
[NetDev]
Name=vti2
Kind=vti
EOF

cat > /etc/systemd/network/vti2.network << EOF
[Match]
Name=vti2

[Network]
Address=${TUNNEL2_BGP_IP}/30
EOF

# Reload networkd
systemctl restart systemd-networkd

# Start strongswan
systemctl enable strongswan-swanctl
systemctl start strongswan-swanctl

# Wait for tunnels to come up
sleep 10

# Configure BGP with Bird2
cat > /etc/bird.conf << EOF
router id $(hostname -I | awk '{print $1}');

protocol device {
}

protocol kernel {
    ipv4 {
        import all;
        export all;
    };
}

protocol bgp aws_tunnel1 {
    local as ${TUNNEL1_BGP_ASN};
    neighbor ${TUNNEL1_BGP_IP} as ${AWS_BGP_ASN};
    
    ipv4 {
        import all;
        export all;
    };
    
    multihop;
}

protocol bgp aws_tunnel2 {
    local as ${TUNNEL2_BGP_ASN};
    neighbor ${TUNNEL2_BGP_IP} as ${AWS_BGP_ASN};
    
    ipv4 {
        import all;
        export all;
    };
    
    multihop;
}
EOF

# Start BIRD
systemctl enable bird
systemctl start bird

CONFIG_SCRIPT

chmod +x /home/ec2-user/vpn-config/configure-vpn.sh
chown -R ec2-user:ec2-user /home/ec2-user/vpn-config

# Set SELinux context for strongswan (if SELinux is enabled)
setsebool -P networkmanager_ipsec_connectivity 1 2>/dev/null || true

# Enable and start services
systemctl enable strongswan-swanctl
systemctl enable bird

# Create log directory
mkdir -p /var/log/strongswan
chmod 755 /var/log/strongswan

# Signal completion
echo "User-data script completed successfully" > /tmp/user-data-complete.log
