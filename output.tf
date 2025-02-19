output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "gke_cluster_region" {
  description = "The region of the GKE cluster"
  value       = google_container_cluster.primary.location
}
