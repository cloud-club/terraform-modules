# GCP

## Infra 생성하기

1. terraform apply 하기

```sh
terraform apply --auto-approve
```

## kubernetes 접근하기

1. gcloud auth를 통해 인증 진행

```sh
gcloud auth application-default login
```

2. cluster gredentials 발급받기

```sh
 gcloud container clusters get-credentials demo --region asia-northeast3
```

3. kubectl 명령어 입력해보기

```sh
kubectl get pods
```

## 참고 자료

- https://www.googlecloudcommunity.com/gc/Workspace-Developer/Are-GCP-project-ID-and-numbers-sensitive/m-p/409804

# Ingress

## Nginx Ingress Controller

1. helm repo 추가하기

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

2. helm 설치하기

```sh
helm upgrade --install -f ./assets/ingress/ingress-nginx-values.yaml nginx-ingress ingress-nginx/ingress-nginx -n nginx-ingress --create-namespace
```

## Gke NEG 사용하기

1. neetwork endpoint groups 조회하기

```sh
gcloud compute network-endpoint-groups list
```

2. terraform을 활용해서 main.tf에 loadbalancer 부분 주석 해제하기

## 참고자료

- https://codemongers.wordpress.com/2022/12/26/securely-ingress-to-gke-using-negs/

- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity?authuser=2&hl=ko&_gl=1*h4rj70*_ga*MjEzMDQxNzA0MC4xNzExNzIyOTc1*_ga_WH2QY8WWF5*MTcyMDk1NDgxNy4yMi4xLjE3MjA5NTU1MDUuMTkuMC4w#gcloud

# Observility

## Metric

### grafana 설치하기

### Prometheus Operator 설치하기

1. node-exporter 설치하기

```sh
helm upgrade -i -n kube-system node-exporter prometheus-community/prometheus-node-exporter
```

2. kube-state-metrics 설치하기

```sh
helm upgrade -i -n kube-system kube-state-metrics prometheus-community/kube-state-metrics
```

3. Prometheus Operator ServiceAccount 생성하기

```sh
kubectl apply -f assets/metrics/namespace.yaml
kubectl apply -f assets/metrics/serviceaccount.yaml
```

4. Prometheus Operator ClusterRole 생성 및 ClusterRoleBinding 하기

```sh
kubectl apply -f assets/metrics/clusterrole.yaml
kubectl apply -f assets/metrics/clusterrole-binding.yaml
```

5. Prometheus Operator CRD 설치하기

```
curl -L https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.74.0/stripped-down-crds.yaml | kubectl apply --server-side -f -
```

6. Pro,etheus Operator 설치하기

```sh
kubectl apply -f assets/metrics/operator.yaml
```

7. Prometheus 설치하기

```sh
kubectl apply -f assets/metrics/prometheus.yaml
```

8. ServiceMonitor 등록하기

```sh
kubectl apply -f assets/metrics/servicemonitor.yaml
```

## Tracing

### tempo 사용해보기

1. helm 설치하기

```sh
helm upgrade -i tempo grafana/tempo -n monitoring -f assets/tracing/tempo.yaml
```

### Jaeger Operator 설치해보기

1. cert-manager 설치하기

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.yaml
```

2. Operator 설치하기

```sh
kubectl apply -f assets/tracing/namespace.yaml

kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.57.0/jaeger-operator.yaml -n observability
```

1. all-in-one 배포해보기

```sh
kubectl apply -f assets/tracing/all-in-one.yaml
```

### 참고

- https://github.com/grafana/helm-charts/issues/3197

## Logging

### loki-distributed 설치하기

1. helm repo 추가하기

```sh
helm repo add grafana https://grafana.github.io/helm-charts
```

2. loki distributed 설치하기

```sh
 helm upgrade --install -f ./assets/loki-distributed.yaml loki grafana/loki-distributed -n monitoring
```

### fluentd 설치하기

1. helm repo 추가하기

```sh
helm repo add fluent https://fluent.github.io/helm-charts
```

2. fluentd 설치하기

```sh
helm upgrade -i -n monitoring fluentd fluent/fluentd -f assets/logging/fluentd.yaml --version 0.3.9
```

# Service Mesh

## Istio
