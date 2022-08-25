echo "Setting up Docker"
sudo apt update && sudo apt install docker.io docker-compose jq net-tools -y

echo "Adding current User to Docker Group"
sudo usermod -aG docker $USER    

echo "Might need to logout and log back in for change to take affect if not using root user"

echo "Setting up k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "Installing Kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "Installing Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Adding aliases to .bashrc"
echo "alias k='kubectl'\nalias h='helm'" >> ~/.bashrc
source ~/.bashrc
