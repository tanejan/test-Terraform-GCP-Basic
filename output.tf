output "vpc_name" {
  value = google_compute_network.case_study_vpc_network.name
}

output "subnet_name" {
  value = google_compute_subnetwork.case_study_subnet.name
}

output "vm_name" {
  value = google_compute_instance.case_study_instance3.name
}
