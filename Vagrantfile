Vagrant.configure("2") do |config|
  # Use Ubuntu 18.04 (Bionic Beaver)
  config.vm.box = "ubuntu/jammy64"

  # Configure the virtual machine's RAM and CPU
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"
    vb.cpus = 2
  end

  # Forward port 9090 from the VM to the host machine (Prometheus)
  config.vm.network "forwarded_port", guest: 9090, host: 9090
  # Forward port 3000 from the VM to the host machine (Grafana)
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  # Forward port 8080 from the VM to the host machine (Jenkins)
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  # Forward port 8080 from the VM to the host machine (SonarQube)
  config.vm.network "forwarded_port", guest: 9000, host: 9000
  # Forward port 9080 from the VM to the host machine (Netflix App)
  config.vm.network "forwarded_port", guest: 9080, host: 9080
  # Forward port 5601 from the VM to the host machine (Kibana)
  config.vm.network "forwarded_port", guest: 5601, host: 5601
  # Forward port 9200 from the VM to the host machine (ElasticSearch)
  config.vm.network "forwarded_port", guest: 9200, host: 9200

  # Sync and execute the script
  config.vm.provision "file", source: "./prom_graf.sh", destination: "/home/vagrant/prom_graf.sh"


  # Provision the web server and Jenkins
  config.vm.provision "shell", inline: <<-SHELL
    # Update and Upgrade
    sudo apt-get update
    sudo apt-get upgrade -y

    #Installing Prometheus and Grafana using shell script
    chmod +x /home/vagrant/prom_graf.sh
    /home/vagrant/prom_graf.sh

    # Installing Jenkis and related packages
    sudo apt-get install -y openjdk-17-jdk
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins -y
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    
    # Installing Docker 
    sudo apt install docker.io -y
    sudo systemctl enable --now docker.service
    sudo groupadd docker
    sudo usermod -aG docker vagrant
    newgrp docker

    # Running Sonarqube container
    docker run -d --name sonarqube \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_logs:/opt/sonarqube/logs \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    --restart unless-stopped \
    sonarqube:lts-community

    # Installing Trivy and related packages
    sudo apt-get install wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy -y

    git clone https://github.com/N4si/DevSecOps-Project/ /home/vagrant/DevSecOps-Project
    sudo chown vagrant:vagrant /home/vagrant/DevSecOps-Project
  SHELL
end