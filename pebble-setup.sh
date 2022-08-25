echo " "
echo "------------------"
echo "Setting up Pebble"
echo "------------------"
echo " "

helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm show values jupyterhub/pebble > /tmp/pebble-values.yaml

sed -i s/"# - name: PEBBLE_VA_ALWAYS_VALID"/"- name: PEBBLE_VA_ALWAYS_VALID"/ /tmp/pebble-values.yaml
sed -i s/'#   value: "0"'/'  value: "1"'/ /tmp/pebble-values.yaml
sed -i s/"enabled: true"/"enabled: false"/ /tmp/pebble-values.yaml

helm install pebble jupyterhub/pebble --values /tmp/pebble-values.yaml -n kube-system

echo " "
echo "------------------"
echo "Updating Traefik"
echo "------------------"
echo " "

helm show values traefik/traefik > /tmp/traefik-values.yaml

sed -i 's/volumes:/#volumes:/' /tmp/traefik-values.yaml
sed -i 's/additionalArguments:/#additionalArguments:/' /tmp/traefik-values.yaml
sed -i 's/env:/#env:/' /tmp/traefik-values.yaml

cat <<EOF | tee -a /tmp/traefik-values.yaml
# Pebble Modifications
volumes:
  - name: pebble
    mountPath: "/certs"
    type: configMap
additionalArguments:
  - --certificatesresolvers.pebble.acme.tlschallenge=true
  - --certificatesresolvers.pebble.acme.email=test@hello.com
  - --certificatesresolvers.pebble.acme.storage=/data/acme.json
  - --certificatesresolvers.pebble.acme.caserver=https://pebble/dir
env:
  - name: LEGO_CA_CERTIFICATES
    value: "/certs/root-cert.pem"
EOF

helm upgrade --install traefik traefik/traefik --values /tmp/traefik-values.yaml -n kube-system

echo " "
echo "----------------------------------------------------------------------------------"
echo "Pebble Setup completed. Now try applying some manifests from manifests directory"
echo "----------------------------------------------------------------------------------"
echo " "