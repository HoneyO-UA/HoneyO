# HoneyO Installation

## 1. Utils packages (Helm Chart)

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
  - "10.255.37.27-10.255.37.29" # The ip range to be assigned
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
  - services (where the honeypots container images are, check https://github.com/HoneyO-UA/Honeypots)

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


## 2. Pypi server to expose required python packages (Helm Chart)

```bash
helm install pypi-server charts/pypi-server --namespace utils --create-namespace -f values/pypi-server-values.yaml
```

## 3. Install GlusterFS in the honeynet k8s cluster (Ansible playbooks)

Change glusterfs/vars.yaml accordingly before executing the playbooks

### Install GlusterFS Server
```bash
cd glusterfs && ./deploy.sh server 10.255.37.65,
# ./deploy.sh server <glusterfs_server_ip>
```


### Mount Remote FileSystem in k8s cluster nodes for tracee storage
```bash
cd glusterfs && ./deploy.sh client 10.255.37.64,10.255.37.63,10.255.37.62,
# ./deploy.sh client <Honeynet k8s nodes IP>
```


## 4. Install required services for the honeynet k8s cluster (Helm Chart)
```bash
helm install honeynet honeynet -f honeynet-values.yaml -n honeynet --create-namespace
```

Create a Token secret to communicate with the kube api server (required for the Management system)

Default honeynet namespace is **default**, if you are deploying the honeypots in another namespace change the namespace fields in the provided k8s manifests
```bash
kubectl apply -f https://github.com/HoneyO-UA/HoneyO/releases/download/v1.0.0/secret.yaml

# Get token
kubectl describe secrets honeynet-k8sapi-token
```


## 5. Install Management System in another k8s cluster (Helm Chart)
```bash
helm install ms ms -f ms-values.yaml -n ms --create-namespace
```

### Upload honeypots k8s manifest 
  See https://github.com/HoneyO-UA/Honeypots 

## 6. Install Haproxy and required services for the loadBalancer (Ansible playbooks)

Change glusterfs/vars.yaml and glusterfs/vars/*.yaml accordingly before executing the playbooks

### Install HAProxy
```bash
cd loadbalancer && ./deploy.sh haproxy 10.255.37.61,
# ./deploy.sh haproxy <Load balancer VM IP>
```

### Install Haproxy Config file watchdog
```bash
cd loadbalancer && ./deploy.sh watchdog 10.255.37.61,
# ./deploy.sh watchdog <Load balancer VM IP>
```

### Install Haproxy network rules worker
```bash
cd loadbalancer && ./deploy.sh worker 10.255.37.61,
# ./deploy.sh worker <Load balancer VM IP>
```

### Create backend entries to be assigned to the honeypots
```bash
cd loadbalancer && ./deploy.sh backend_entries 10.255.37.61,
# ./deploy.sh backend_entries <Load balancer VM IP>
```
Wait a few minutes to ensure that every backend entry is stored in the management system

## 7. Install monitoring agents in loadBalancer

### Create Elastic Search, Map View and Kibana services
```bash
helm install emk emk -f emk-values.yaml -n emk --create-namespace
```

Upload kibana data views to create all the necessary dashboards
```bash
wget "https://github.com/HoneyO-UA/HoneyO/releases/download/v1.0.0/kibana.zip"
7z x kibana.zip
curl -X POST "http:<kibana_url>/api/saved_objects/_import" -F "file=@dashboard.ndjson" -H "kbn-xsrf: true"
curl -X POST "http:<kibana_url>/api/saved_objects/_import" -F "file=@live-map.ndjson" -H "kbn-xsrf: true"
```

### Install monitoring agents at loadBalancer
```bash
cd loadbalancer && ./deploy.sh tshark 10.255.37.61,
# ./deploy.sh tshark <Load balancer VM IP>
cd loadbalancer && ./deploy.sh logstash 10.255.37.61,
# ./deploy.sh logstash <Load balancer VM IP>
```