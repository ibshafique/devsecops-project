#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y needrestart
sudo sed -i 's/^#\$nrconf{restart} = .*/\$nrconf{restart} = "a";/' /etc/needrestart/needrestart.conf
sudo needrestart -r a

# Install Java (required for Elasticsearch and Logstash)
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Add the Elasticsearch GPG key and repository
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list

# Install Elasticsearch
sudo apt update
sudo apt install -y elasticsearch
sudo systemctl enable --now elasticsearch

# Install Logstash
sudo apt install -y logstash
sudo systemctl enable --now logstash

# Install Kibana
sudo apt install -y kibana
sudo systemctl enable --now kibana
echo "server.port: 5601" >> /etc/kibana/kibana.yml
echo 'server.host: "0.0.0.0"' | sudo tee -a /etc/kibana/kibana.yml > /dev/null
echo "xpack.security.enabled: false" >> /etc/kibana/kibana.yml > /dev/null
# Install Filebeat
sudo apt install -y filebeat
sudo systemctl enable --now filebeat

# Configure Filebeat to send logs to Logstash
sudo bash -c 'cat > /etc/filebeat/filebeat.yml << EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log

output.logstash:
  hosts: ["localhost:5044"]
EOF'

# Restart Filebeat to apply the configuration
sudo systemctl restart filebeat

echo "ELK stack and Filebeat installation completed successfully."