#!/usr/bin/env bash

bold() {
  echo "=====>>>> $(tput bold)" "$*" "$(tput sgr0)";
}

CONFIGURATION_FILE="$HOME/kubernetes-config-store/scripts/configuration"

source "$CONFIGURATION_FILE"

REQUIRED_APIS="cloudfunctions.googleapis.com container.googleapis.com"

NUM_REQUIRED_APIS=$(wc -w <<< "$REQUIRED_APIS")
NUM_ENABLED_APIS=$(gcloud services list --project $PROJECT_ID \
  --filter="config.name:($REQUIRED_APIS)" \
  --format="value(config.name)" | wc -l)

if [ $NUM_ENABLED_APIS != $NUM_REQUIRED_APIS ]; then
  bold "Enabling required APIs ($REQUIRED_APIS)..."

  gcloud services --project $PROJECT_ID enable $REQUIRED_APIS
fi

bold "Provisioning GKE cluster..."

gcloud container clusters create $GKE_CLUSTER_NAME \
   --cluster-version latest \
   --num-nodes 1   \
   --region $GKE_CLUSTER_REGION \
   --project $PROJECT_ID

bold "Removing nodes from GKE cluster and leaving just the masters..."

gcloud container node-pools delete default-pool -q \
  --cluster $GKE_CLUSTER_NAME \
  --region $GKE_CLUSTER_REGION \
  --project $PROJECT_ID

bold "Provisioning Cloud Function..."

cd $HOME/kubernetes-config-store/cloud-function/
gcloud beta functions deploy configmap_fetcher \
  --quiet \
  --runtime python37 \
  --trigger-http \
  --project $PROJECT_ID \
  --region $CLOUD_FUNCTION_REGION \
  --set-env-vars KUBERNETES_NAMESPACE=$KUBERNETES_NAMESPACE,GKE_CLUSTER_NAME=$GKE_CLUSTER_NAME,GKE_CLUSTER_REGION=$GKE_CLUSTER_REGION

bold "Making sure the function is not public..."

ALL_USERS_HAS_ACCESS=$(gcloud beta functions get-iam-policy configmap_fetcher \
 --project $PROJECT_ID \
 --region $CLOUD_FUNCTION_REGION \
 --flatten="bindings[].members" \
 --format="table(bindings.role)" \
 --filter="allUsers")

if [ -n "$ALL_USERS_HAS_ACCESS" ]; then
  bold "Disabling public access..."
  gcloud beta functions remove-iam-policy-binding configmap_fetcher \
    --region $CLOUD_FUNCTION_REGION \
    --member allUsers \
    --role roles/cloudfunctions.invoker
fi

bold "Deployment completed."
