output "vpc_name" {
  value = google_compute_network.case-study-vpc-network.name
}

output "subnet_name" {
  value = google_compute_subnetwork.case-study-subnet.name
}

output "vm_name" {
  value = google_compute_instance.case-study-instance3.name
}
