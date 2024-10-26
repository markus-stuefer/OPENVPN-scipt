#!/bin/bash

# OpenVPN Setup Script (ohne Web GUI)
# Getestet auf Ubuntu/Debian. Run with root privileges.

echo "Starting OpenVPN Server Setup..."

# Update system packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install OpenVPN and Easy-RSA
echo "Installing OpenVPN and Easy-RSA..."
apt install -y openvpn easy-rsa

# Set up Easy-RSA directory
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Configure the OpenVPN server
echo "Configuring OpenVPN..."

# Initialize Easy-RSA variables and keys
cat > ~/openvpn-ca/vars <<EOF
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "California"
set_var EASYRSA_REQ_CITY       "San Francisco"
set_var EASYRSA_REQ_ORG        "MyVPN"
set_var EASYRSA_REQ_EMAIL      "admin@myvpn.com"
set_var EASYRSA_REQ_OU         "VPN"
set_var EASYRSA_KEY_SIZE       2048
set_var EASYRSA_ALGO           rsa
set_var EASYRSA_CA_EXPIRE      3650
set_var EASYRSA_CERT_EXPIRE    3650
set_var EASYRSA_REQ_CN         "OpenVPN-CA"
EOF

# Build Certificate Authority (CA)
echo "Building CA..."
source ./vars
./clean-all
./build-ca --batch

# Generate server certificate and key
echo "Generating server certificate and key..."
./build-key-server --batch server
./build-dh

# Generate client certificate
echo "Generating client certificate and key..."
./build-key --batch client

# Copy server files to OpenVPN directory
echo "Copying server files to /etc/openvpn..."
cp ~/openvpn-ca/keys/{server.crt,server.key,ca.crt,dh2048.pem} /etc/openvpn/

# Create server configuration file
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
auth SHA256
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn-status.log
verb 3
client-to-client
keepalive 10 120
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
EOF

# Enable IP forwarding
echo "Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
sysctl -p

# Configure firewall rules
echo "Configuring firewall rules..."
ufw allow OpenSSH
ufw allow 1194/udp
ufw enable

# Start and enable OpenVPN service
echo "Starting OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server

# Client configuration file
echo "Generating client configuration file..."
cat > ~/client.ovpn <<EOF
client
dev tun
proto udp
remote your-server-ip 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
cipher AES-256-CBC
key-direction 1
verb 3

<ca>
$(cat ~/openvpn-ca/keys/ca.crt)
</ca>

<cert>
$(cat ~/openvpn-ca/keys/client.crt)
</cert>

<key>
$(cat ~/openvpn-ca/keys/client.key)
</key>
EOF

echo "OpenVPN server setup complete!"
echo "Client configuration file saved as ~/client.ovpn"
