#!/usr/bin/env bash

  cat > ~/kubernetes-config-store/scripts/configuration <<EOL

export PROJECT_ID=$PROJECT_ID

export GKE_CLUSTER_NAME=config-cluster
export GKE_CLUSTER_REGION=europe-west1

export CLOUD_FUNCTION_REGION=europe-west1

# If you change namespace you must create it yourself.
export KUBERNETES_NAMESPACE=default

EOL
