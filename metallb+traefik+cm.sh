echo " "
echo "----------------------"
echo ">> Setting up MetalLB"
echo "----------------------"
echo " "

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.4/config/manifests/metallb-native.yaml
cat <<EOF | tee -a /tmp/ipaddresspool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.30.80-192.168.30.90
EOF

cat <<EOF | tee -a /tmp/l2advertisement.yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

echo " "
echo "-----------------------"
echo ">> Setting up Traefik"
echo "-----------------------"
echo " "

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
kubectl create namespace traefik
helm install --namespace=traefik traefik traefik/traefik --values=traefik/values.yaml
kubectl apply -f traefik/default-headers.yaml


echo " "
echo "----------------------------"
echo ">> Setting up Cert-Manager"
echo "----------------------------"
echo " "

helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager --values=cert-manager/values.yaml --version v1.9.1

echo " "
echo "------------------------------------------------------------------------------------------------------------------"
echo ">> Setup of MetalLB, Traefik and Cert-Manager completed"
echo ">> Now update secret-cf-token.yaml from inside Cert-Manager/issuers and apply that"
echo ">> Then update letsencrypt-staging.yaml from inside Cert-Manager/issuers and apply that"
echo ">> Finally rename and update local-example-com.yaml from inside Cert-Manager/certificates/staging and apply that"
echo ">> Check status of validation by kubectl get challenges"
echo ">> After that try applying some manifests from manifests directory. Remember to update the Host and secretName"
echo ">> To find the secretName use - kubectl get secrets"
echo ">> Once the staging certificate is tested to be working, use Cert-Manager/certificates/production and proceed"
echo "------------------------------------------------------------------------------------------------------------------"
echo " "

