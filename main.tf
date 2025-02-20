# 1️⃣ Create the GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "default"
  subnetwork = "default"
}

# 2️⃣ Create a node pool for the cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# 3️⃣ Install Helm and Harness Delegate using a Kubernetes provider
provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# 4️⃣ Add the Helm provider
provider "helm" {
  kubernetes {
    host                   = google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# 5️⃣ Install the Harness delegate using Helm
resource "helm_release" "harness_delegate" {
  name       = "helm-delegate"
  repository = "https://app.harness.io/storage/harness-download/delegate-helm-chart/"
  chart      = "harness-delegate-ng"
  namespace  = "harness-delegate-ng"

  create_namespace = true

  set {
    name  = "delegateName"
    value = "helm-delegate"
  }

  set {
    name  = "accountId"
    value = "your-account-id"
  }

  set {
    name  = "delegateToken"
    value = "your-delegate-token"
  }

  set {
    name  = "managerEndpoint"
    value = "https://app.harness.io"
  }

  set {
    name  = "delegateDockerImage"
    value = "harness/delegate:25.01.85000"
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "upgrader.enabled"
    value = "true"
  }
}

# 6️⃣ Get GCP client configuration
data "google_client_config" "default" {}
