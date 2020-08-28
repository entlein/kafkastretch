#!/bin/sh 

for CTX in akszk aksyellow aksorange; do 
	kubectl config use-context ${CTX} > /dev/null
	if [ "$CTX" = "akszk" ]; then 
		kubectl get svc prometheus-server -n zookeeper -o jsonpath="{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}" 2>/dev/null; echo
	else
		kubectl get svc prometheus-server -n kafka -o jsonpath="{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}" 2>/dev/null; echo
	fi
done
