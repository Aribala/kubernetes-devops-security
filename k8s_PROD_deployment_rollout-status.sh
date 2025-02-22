#!/bin/bash

sleep 60

if [[ $(kubectl -n prod rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} Rollout has failed."
    kubectl -n prod rollout undo deploy ${deploymentName}
    exit 1;
else
    echo "Deployment ${deploymentName} Rollout success."
fi;