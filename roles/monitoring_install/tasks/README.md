# Kubernetes Monitoring: Prometheus & Grafana Debug Toolkit

This document consolidates the full set of commands and steps used to install, troubleshoot, and operate **Prometheus** and **Grafana** in a Kubernetes cluster using `kubectl`, `Helm`, and secret handling mechanisms.

---

## 1. Kubernetes Essentials

### 1.1. General Resource Inspection

```bash
kubectl get all -n <namespace>
kubectl get pods -n <namespace>
kubectl get svc -n <namespace>
kubectl get ingress -n <namespace>
```

### 1.2. Pod & DaemonSet Details

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl describe daemonset prometheus-prometheus-node-exporter -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl get pods -n <namespace> --field-selector spec.nodeName=rpi-node0
```

---

## 2. Access & Port Forwarding

```bash
kubectl port-forward -n <namespace> svc/prometheus-kube-prometheus-prometheus 9090:9090
kubectl port-forward -n <namespace> svc/prometheus-grafana 3000:80
```

---

## 3. Grafana Email Alert Troubleshooting

### 3.1. Logs & Configuration

```bash
kubectl logs deploy/monitor-stack-grafana -n <namespace>
kubectl exec -it -n <namespace> deploy/monitor-stack-grafana -- sh
# cat /etc/grafana/grafana.ini
```

### 3.2. SMTP Secret Handling

```bash
kubectl get secret grafana-smtp-secret -n <namespace> -o yaml
kubectl delete secret grafana-smtp-secret -n <namespace>
kubectl create secret generic grafana-smtp-secret \
  --from-literal=smtp-password='your_app_specific_token_here' \
  -n <namespace>
```

### 3.3. Read Secret from CLI

```bash
kubectl get secret grafana-smtp-secret -n <namespace> -o jsonpath="{.data.smtp-password}" | base64 -d && echo
```

### 3.4. Restart Grafana Deployment

```bash
kubectl rollout restart deployment monitor-stack-grafana -n <namespace>
kubectl rollout status deployment monitor-stack-grafana -n <namespace>
```

### 3.5. SMTP Connectivity Test Pod

```bash
kubectl run smtp-debug --rm -i -t --restart=Never --image=alpine:3.18 -- sh
# apk add busybox-extras
# telnet smtp.gmail.com 587
```

---

## 4. Helm Operations

### 4.1. Install / Upgrade Prometheus Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --version 45.7.1 -n <namespace> --create-namespace \
  -f /tmp/prometheus_values.yaml
```

### 4.2. Helm Status, Values, History

```bash
helm get values prometheus -n <namespace>
helm history prometheus -n <namespace>
```

### 4.3. Helm Rollback / Uninstall

```bash
helm rollback prometheus <revision> -n <namespace>
helm uninstall prometheus -n <namespace>
```

### 4.4. Clean Helm Cache (optional)

```bash
rm -rf ~/.cache/helm ~/.config/helm ~/.local/share/helm
```

---

## 5. Node Exporter DaemonSet & Metrics Debugging

### 5.1. DaemonSet Management

```bash
kubectl rollout restart daemonset prometheus-prometheus-node-exporter -n <namespace>
kubectl rollout status daemonset prometheus-prometheus-node-exporter -n <namespace>
kubectl get daemonset prometheus-prometheus-node-exporter -n <namespace> -o yaml
```

### 5.2. Restart or Delete Pods

```bash
kubectl get pods -n <namespace> | grep node-exporter
kubectl delete pod -n <namespace> <pod-name>
```

### 5.3. Check Metrics

```bash
kubectl exec -n <namespace> -it <node-exporter-pod> -- /bin/sh
ls -l /var/lib/node_exporter/textfile_collector/
curl http://<pod-ip>:9100/metrics
```

---

## 6. Systemd Node Exporter Management

### 6.1. Start / Stop / Restart

```bash
sudo systemctl restart node_exporter
sudo systemctl stop node_exporter
sudo systemctl status node_exporter
```

### 6.2. Uninstall Node Exporter

```bash
sudo systemctl disable node_exporter
sudo rm /etc/systemd/system/node_exporter.service
sudo rm /usr/local/bin/node_exporter
sudo rm -rf /var/lib/node_exporter /etc/node_exporter
sudo systemctl daemon-reload
```

---

## 7. Secret & Vault Handling

### 7.1. Grafana SMTP Password Secret

```bash
kubectl create secret generic grafana-smtp-secret \
  --from-literal=smtp-password='your_app_specific_token_here' \
  -n <namespace>

kubectl get secret grafana-smtp-secret -n <namespace> -o jsonpath="{.data.smtp-password}" | base64 -d
```

### 7.2. Vault Integration (for Ansible)

Use `ansible-vault` to manage sensitive values:

```bash
ansible-vault encrypt vars/secrets.yml
ansible-vault decrypt vars/secrets.yml
```

Include secrets in playbooks:

```yaml
vars_files:
  - vars/secrets.yml
```

---

## 8. Version Check

```bash
helm version --short
kubectl version
```

