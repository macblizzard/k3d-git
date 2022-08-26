echo " "
echo "-------------------------------------------------"
echo ">> Make sure to configure k3d.yaml file properly"
echo "-------------------------------------------------"
echo " "

k3d cluster create k3s-default --config k3d.yaml --wait

echo "-------------------------------------------------"
echo ">> Exporting KUBECONFIG"
echo "-------------------------------------------------"
echo " "

sleep 10
export KUBECONFIG=$(k3d kubeconfig write k3s-default)
echo "KUBECONFIG=$(k3d kubeconfig write k3s-default)" >> ~/.bashrc
source ~/.bashrc

