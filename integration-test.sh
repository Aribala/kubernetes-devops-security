#!/bin/bash

sleep 5

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

echo $PORT
echo $applicationURL:$PORT$applicationURI

if [[ ! -z "$PORT" ]]; then
    response=$(curl -s $applicationURL:$PORT$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)
    if [[ "$response" == 100 ]]; then
        echo "Increment Test Passed"
    else
        echo "Increment Test Failed"
        exit 1;
    fi;

    if [[ "$http_code" == 200 ]]; then
        echo "Http Status Code Test Passed"
    else
        echo "Http Status Code Test Failed"
        exit 1;
    fi;
else
    echo "Service doesn't have a NodePort"
    exit 1;
fi;