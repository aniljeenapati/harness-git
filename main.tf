provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  initial_node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = 30
  }

  remove_default_node_pool = false
}

resource "null_resource" "install_harness_delegate" {
  depends_on = [google_container_cluster.primary]

  provisioner "local-exec" {
    command = <<EOT
      gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}

      helm repo add harness-delegate https://app.harness.io/storage/harness-download/delegate-helm-chart/
      helm repo update harness-delegate

      helm upgrade -i helm-delegate --namespace harness-delegate-ng --create-namespace \
      harness-delegate/harness-delegate-ng \
      --set delegateName=helm-delegate \
      --set accountId=ucHySz2jQKKWQweZdXyCog \
      --set delegateToken=NTRhYTY0Mjg3NThkNjBiNjMzNzhjOGQyNjEwOTQyZjY= \
      --set managerEndpoint=https://app.harness.io \
      --set delegateDockerImage=harness/delegate:25.01.85000 \
      --set replicas=1 --set upgrader.enabled=true
    EOT
  }
}
