# HoneyO Installation

## Utils packages

To correctly install the HoneyO solution, certain services and packages must be pre-installed. You have the flexibility to install these packages manually or use different software, as long as they meet the requirements of the HoneyO solution. For convenience, we provide a Helm chart that will automatically install all the necessary pre-requisites.

1. **Private Registry**: A private registry is required to upload all the necessary container images for the HoneyO services. We use Harbor to achieve this goal.
2. **Container Native Storage (CNS)**: CNS software is needed to accommodate Persistent Volume Claims (PVCs) from some services. We use OpenEBS for this purpose.
3. **Load Balancer**: A load balancer capable of assigning IP addresses is necessary. We use MetalLB to fulfill this requirement.

### Install utils package
```bash
helm install utils charts/utils --namespace utils --create-namespace -f values/utils-values.yaml
```

### Assign a ip range to the load balancer

#### **`ip-assignment.yaml`**
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: cluster-pool
spec:
  addresses:
  - "10.255.37.28-10.255.37.29" # The ip range to be assigned
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: cluster-l2-advertisement
spec:
  ipAddressPools:
  - cluster-pool
```

```bash
kubectl apply -f ip-assignment.yaml -n utils
```

### Upload container images to the private registry

1. Create 3 projects in Harbor
  - honeyo
  - ms
  - snapshots

2. Download container images
```bash
cd scripts
./download_images.sh "/honeyo/images" "https://github.com/HoneyO-UA/HoneyO/releases/download/v1.0.0/images.zip" # Download Images to /honeyo/images folder
```

3. Add insecure registry url to docker configuration
#### **`/etc/docker/daemon.json`**
```json
{"insecure-registries":["10.255.37.57:30002"]}
//{"insecure-registries":["{REGISTRY_URL}:{REGISTRY_PORT}"]}
```
```bash
sudo systemctl restart docker
```

4. Add insecure registry to k8s cluster (choose one)
  - K3S - https://docs.k3s.io/installation/private-registry
  - Containerd Directly - https://stackoverflow.com/questions/72419513/how-to-pull-docker-image-from-a-insecure-private-registry-with-latest-kubernetes

5. Upload the images to the private registry (requires docker)
```bash
cd scripts
./upload_images_to_registry.sh "/honeyo/images" "10.255.37.57:30002"
```


## Pypi server to expose required python packages

```bash
helm install pypi-server charts/pypi-server --namespace utils --create-namespace -f values/pypi-server-values.yaml
```

## ok


