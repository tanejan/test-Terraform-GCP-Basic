output "vpc_name" {
  value = google_compute_network.capstone_study_vpc_network.name
}

output "subnet_name" {
  value = google_compute_subnetwork.capstone_study_subnet.name
}

output "vm_name" {
  value = google_compute_instance.capstone_study_instance3.name
}
