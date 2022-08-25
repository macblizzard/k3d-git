echo "Make sure to configure k3d.yaml file properly"
k3d cluster create k3s-default --config k3d.yaml

echo "Exporting KUBECONFIG"
export KUBECONFIG=$(k3d kubeconfig write k3s-default)

echo "Applying Traefik Ingress"
kubectl apply -f manifests/traefik-ingress.yaml

