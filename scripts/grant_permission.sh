#!/usr/bin/env bash

bold() {
  echo "=====>>>> $(tput bold)" "$*" "$(tput sgr0)";
}

CONFIGURATION_FILE="$HOME/kubernetes-config-store/scripts/configuration"

source "$CONFIGURATION_FILE"

ACTIVE_ACCOUNT=$(gcloud auth list \
  --format="value(account)" \
  --filter="status=ACTIVE")

gcloud beta functions add-iam-policy-binding configmap_fetcher \
     --region $CLOUD_FUNCTION_REGION \
     --member user:$ACTIVE_ACCOUNT \
     --role roles/cloudfunctions.invoker

bold "You may invoke the function by running:"
bold "curl https://$CLOUD_FUNCTION_REGION-$PROJECT_ID.cloudfunctions.net/configmap_fetcher \
  -H \"Authorization: bearer \$(gcloud auth print-identity-token)\""