metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: /metrics
    prometheus.io/port: "8080"
spec:

so lets see what kafka has currently set up:

export POD_NAME=$(sudo microk8s.kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
sudo microk8s.kubectl --namespace monitoring port-forward $POD_NAME 9090

http://127.0.0.1:9090/targets

the helm people say to expose it via nodeport
$ helm upgrade prometheus stable/prometheus \
            --install \
            --namespace monitoring \
            --set server.service.type=NodePort \
            --set server.service.nodePort=30090 \
            --set server.persistentVolume.enabled=false


