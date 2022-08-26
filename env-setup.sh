echo " "
echo "-------------------"
echo "Setting up Docker"
echo "-------------------"
echo " "

sudo apt update && sudo apt install docker.io docker-compose jq net-tools apache2-utils -y

echo " "
echo "-------------------------------------"
echo "Adding current User to Docker Group"
echo "-------------------------------------"
echo " "

sudo usermod -aG docker $USER

echo " "
echo "--------------------------------------------------------------------------------------"
echo "Might need to logout and log back in for change to take affect if not using root user"
echo "--------------------------------------------------------------------------------------"
echo " "

echo " "
echo "----------------"
echo "Setting up k3d"
echo "----------------"
echo " "

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo " "
echo "--------------------"
echo "Installing Kubectl"
echo "--------------------"
echo " "

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo " "
echo "-----------------"
echo "Installing Helm"
echo "-----------------"
echo " "

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo " "
echo "---------------------------"
echo "Adding aliases to .bashrc"
echo "---------------------------"
echo " "

echo "alias k='kubectl'" >> ~/.bashrc
echo "alias h='helm'" >> ~/.bashrc
source ~/.bashrc
