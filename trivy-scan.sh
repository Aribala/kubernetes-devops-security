#!/bin/bash

echo $imageName

docker run --rm -v $WORKSPACE:/root/.cache aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
docker run --rm -v $WORKSPACE:/root/.cache aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName

scan_result=$(curl -sSX POST --data-binary @k8s_deployment_service.yaml https://v2.kubesec.io/scan)
scan_message=$(curl -sSX POST --data-binary @k8s_deployment_service.yaml https://v2.kubesec.io/scan | jq .[0].message -r )
scan_score=$(curl -sSX POST --data-binary @k8s_deployment_service.yaml https://v2.kubesec.io/scan | jq .[0].score )

exit_code=$?
echo "Exit Code : $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Image Scanning Failed. Vulnerability Found"
    exit 1
else
    echo "Image Scanning Passed. No Vulnerability Found"
fi;