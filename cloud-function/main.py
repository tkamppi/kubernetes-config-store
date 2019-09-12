import os

import google.auth
from google.cloud.container_v1 import ClusterManagerClient
from kubernetes import client
from flask import jsonify


def configmap_fetcher(request):
    """Gets configuration from a config-map in a GKE cluster."""

    cluster_region = os.environ.get("GKE_CLUSTER_REGION", "europe-west1")
    cluster_name = os.environ.get("GKE_CLUSTER_NAME", "config-cluster")
    namespace = os.environ.get("KUBERNETES_NAMESPACE", "default")

    # GCP_PROJECT env is set automatically by Cloud Function runtime.
    project_id = os.environ.get("GCP_PROJECT")

    credentials, _ = google.auth.default()

    cluster_manager_client = ClusterManagerClient(credentials=credentials)
    cluster_resource_name = (
        f"projects/{project_id}/locations/{cluster_region}/clusters/{cluster_name}"
    )
    cluster = cluster_manager_client.get_cluster("", "", "", name=cluster_resource_name)

    configuration = client.Configuration()
    configuration.host = f"https://{cluster.endpoint}:443"
    configuration.verify_ssl = False
    configuration.api_key = {"authorization": "Bearer " + credentials.token}
    client.Configuration.set_default(configuration)

    v1 = client.CoreV1Api()
    configmaps = v1.list_namespaced_config_map(namespace, watch=False)

    return jsonify(configmaps.to_dict())
