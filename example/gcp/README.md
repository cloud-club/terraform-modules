# GCP

## Infra 생성하기

0. placeholder 채우기

- example/gcp/config.tf 의 "project-id" 는 gcp 에서 확인한 자신의 project id 로 교체 (e.g., myproject-a1b2c)
- gcp/config.yaml 의 ${PROJECT_ID} 를 위와 동일한 값으로 교체

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

1. network endpoint groups 조회하기

```sh
gcloud compute network-endpoint-groups list
```

2. placeholder 채우기

- example/gcp/config.yaml 의 domains 에 서브도메인 입력하기 (e.g., example.your-domain.com, grafana.your-domain.com)
- assets/demo/ingress.yaml 에 서브 도메인 입력하기 (e.g., example.your-domain.com)

3. terraform을 활용해서 main.tf에 loadbalancer 부분 주석 해제하기

> [!NOTE]  
> 웹 콘솔로 접속 - [Cloud DNS](https://console.cloud.google.com/net-services/dns/zones) - 구매한 도메인 이름으로 Zone 등록 - NS 레코드에 있는 값들을 도메인 구입했던 사이트에 가서 입력 (네임서버 교체) - 다시 Cloud DNS 로 돌아와서, A 레코드로 서브 도메인 등록 (example.your-domain.com, grafana.your-domain.com 의 2개를 권장) - A 레코드의 target ip 는 'nginx-ingress-forwarding-rule' 항목으로 연결

## 참고자료

- https://codemongers.wordpress.com/2022/12/26/securely-ingress-to-gke-using-negs/

- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity?authuser=2&hl=ko&_gl=1*h4rj70*_ga*MjEzMDQxNzA0MC4xNzExNzIyOTc1*_ga_WH2QY8WWF5*MTcyMDk1NDgxNy4yMi4xLjE3MjA5NTU1MDUuMTkuMC4w#gcloud

# Observility

## Metric

### grafana 설치하기

### Prometheus Operator 설치하기

0. helm chart 설치하기

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

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

6. Prometheus Operator 설치하기

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

0. helm chart 설치하기

```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

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

## linkerd

1. step-cli를 활용해서 tls 인증서 발급하기 및 secrets 등록하기

```sh
step certificate create root.linkerd.cluster.local control_plane_ca.crt control_plane_ca.key --profile root-ca --no-password --insecure &&
kubectl create secret tls linkerd-trust-anchor --cert=control_plane_ca.crt --key=control_plane_ca.key --namespace=linkerd

step certificate create webhook.linkerd.cluster.local webhook_ca.crt webhook_ca.key --profile root-ca --no-password --insecure --san webhook.linkerd.cluster.local &&
kubectl create secret tls webhook-issuer-tls --cert=webhook_ca.crt --key=webhook_ca.key --namespace=linkerd &&
kubectl create secret tls webhook-issuer-tls --cert=webhook_ca.crt --key=webhook_ca.key --namespace=linkerd-viz
```

2. cert-manager를 활용해서 issuer와 certificate 생성하기
3. helm 추가하기

```sh
helm repo add linkerd https://helm.linkerd.io/edge
```

4. crd 설치하기

```sh
helm install linkerd-crds -n linkerd linkerd/linkerd-crds --set enableHttpRoutes=false
```

5. control plane 설치하기

```sh
kubectl label namespace linkerd \
  linkerd.io/is-control-plane=true \
  config.linkerd.io/admission-webhooks=disabled \
  linkerd.io/control-plane-ns=linkerd
kubectl annotate namespace linkerd linkerd.io/inject=disabled

helm upgrade -i -n linkerd linkerd-control-plane -f assets/service-mesh/linkerd/control-plane.values.yaml linkerd/linkerd-control-plane
```

6. viz 설치하기

```sh
helm upgrade -i -n linkerd linkerd-viz -f assets/service-mesh/linkerd/viz.values.yaml linkerd/linkerd-viz
```

7. emojivoto 설치하기

```sh
kubectl apply -f assets/service-mesh/linkerd/emojivoto.yaml
```
