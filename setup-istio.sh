cd ~/Downloads/istio-1.2.5
gcloud container clusters create istio-test   --cluster-version latest   --num-nodes 1 --preemptible --enable-network-policy --enable-autoscaling --max-nodes=10 --min-nodes=3 --zone us-central1
sleep 60
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)
sleep 5
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
sleep 5
kubectl apply -f install/kubernetes/istio-demo.yaml
sleep 5
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

sleep 10
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl -s http://${GATEWAY_URL}/productpage
