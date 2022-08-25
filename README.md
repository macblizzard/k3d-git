# K3D Setup with Traefik and Pebble

## Installing Prerequisites
```bash
sudo apt update && sudo apt install docker.io docker-compose jq net-tools -y
```

## Adding current User to Docker Group
```bash
sudo usermod -aG docker $USER    # logout and log back in for change to take affect
```

## Setting up k3d
```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

## Installing kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```

## Creating k3d cluster
```bash
k3d cluster create --api-port 6550 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 2
```
or,
```bash
nano k3d.yaml
```
```ini
---
apiVersion: k3d.io/v1alpha2
kind: Simple
name: k3s-default
image: rancher/k3s:v1.24.3-k3s1
servers: 1
agents: 2
ports:
- port: 80:80
  nodeFilters:
  - loadbalancer
- port: 443:443
  nodeFilters:
  - loadbalancer
```

```bash
k3d cluster create k3s-default --config k3d.yaml
```
## Exporting KUBECONFIG
```bash
export KUBECONFIG=$(k3d kubeconfig write k3s-default)
```

## Applying Traefik Ingress
```bash
nano traefik-ingress.yaml
```
```ini
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik
  namespace: kube-system
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: traefik
            port:
              number: 80
```

```bash
kubectl apply -f traefik-ingress.yaml
```

## Installing Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Setting up Pebble (Let's Encrypt alternate for unreachable CI environment with Kubernetes!)
```bash
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm show values jupyterhub/pebble > /tmp/pebble-values.yaml
```
```bash
nano /tmp/pebble-values.yaml
```
```ini
uncomment the following lines and change "0" to "1"
- name: PEBBLE_VA_ALWAYS_VALID
      value: "1"

change the following line from "true" to "false"
coredns:
  enabled: false
```
now, install the pebble resource with modified values (needs to on same namespace as traefik)
```bash
helm install pebble jupyterhub/pebble --values /tmp/pebble-values.yaml -n kube-system
```
to update traefik:
```bash
helm show values traefik/traefik > /tmp/traefik-values.yaml
nano /tmp/traefik-values.yaml
```

```ini
find: 
volumes: []

change with:
volumes:
  - name: pebble
    mountPath: "/certs"
    type: configMap
---
find 
additionalArguments: []

change with:
additionalArguments:
  - --certificatesresolvers.pebble.acme.tlschallenge=true
  - --certificatesresolvers.pebble.acme.email=test@hello.com
  - --certificatesresolvers.pebble.acme.storage=/data/acme.json
  - --certificatesresolvers.pebble.acme.caserver=https://pebble/dir
---
find
env: []

change with:
env:
  - name: LEGO_CA_CERTIFICATES
    value: "/certs/root-cert.pem"
```

now update traefik with updated values file:
```bash
helm upgrade --install traefik traefik/traefik --values /tmp/traefik-values.yaml -n kube-system
```
### That's it, now try a manifest file from manifests directory, just make sure to change the host urls.

