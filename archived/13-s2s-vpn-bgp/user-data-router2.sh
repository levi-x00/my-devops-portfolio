#!/bin/bash -xe
apt-get update && apt-get install -y strongswan wget
mkdir /home/ubuntu/demo_assets
cd /home/ubuntu/demo_assets
wget https://raw.githubusercontent.com/acantril/learn-cantrill-io-labs/${branch}/${project_name}/OnPremRouter2/ipsec-vti.sh
wget https://raw.githubusercontent.com/acantril/learn-cantrill-io-labs/${branch}/${project_name}/OnPremRouter2/ipsec.conf
wget https://raw.githubusercontent.com/acantril/learn-cantrill-io-labs/${branch}/${project_name}/OnPremRouter2/ipsec.secrets
wget https://raw.githubusercontent.com/acantril/learn-cantrill-io-labs/${branch}/${project_name}/OnPremRouter2/51-eth1.yaml
wget https://raw.githubusercontent.com/acantril/learn-cantrill-io-labs/${branch}/${project_name}/OnPremRouter2/ffrouting-install.sh
chown ubuntu:ubuntu /home/ubuntu/demo_assets -R
cp /home/ubuntu/demo_assets/51-eth1.yaml /etc/netplan
netplan --debug apply
