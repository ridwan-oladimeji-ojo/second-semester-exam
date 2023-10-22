#!/bin/bash

# Variables
MASTER="192.168.33.10"
SLAVE="192.168.33.11"

# Install Vagrant if not already installed
if ! command -v vagrant &>/dev/null; then
  echo "Vagrant is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install vagrant -y
fi

# Initialize Vagrant environment
vagrant init

# Defining the VMs
cat <<EOF >> Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.define "Master" do |master|
    master.vm.network "private_network", type: "dhcp"
    master.vm.network "private_network", type: "static", ip: "${MASTER_IP}"
  end

  config.vm.define "Slave" do |slave|
    slave.vm.network "private_network", type: "dhcp"
    slave.vm.network "private_network", type: "static", ip: "${SLAVE_IP}"
  end
end
EOF

# Start and provision the VMs
vagrant up

echo "Provisioning is complete."
echo "Master IP: ${MASTER_IP}"
echo "Slave IP: ${SLAVE_IP}"

#Automating the deployment of LAMP

# Update the package lists
sudo apt-get update

# Install Apache, MySQL, and PHP
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Secure MySQL installation
sudo mysql_secure_installation

# Configure Apache to serve PHP files
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf

# Restart Apache to apply changes
sudo systemctl restart apache2

# Create a test PHP file
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

echo "LAMP stack installation and configuration complete."

# Provide information on how to access the PHP info page
echo "You can access the PHP info page at http://$MASTER_IP/info.php"