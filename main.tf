resource "google_compute_network" "case-study-vpc-network" {
  project                                   = "neeraj"
  name                                      = "case-study-vpc-network"
  auto_create_subnetworks                   = false
}

resource "google_compute_subnetwork" "case_study_subnet" {
  name          = "case-study-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.case-study-vpc-network.id
}

resource "google_compute_instance" "case_study_instance3" {
  name         = "case-study-instance3"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.case_study_subnet.id
    access_config {}
  }

  labels = {
    environment = var.environment
    owner       = var.owner
    managedby   = "terraform"
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "<h1>Provisioned via Terraform</h1>" > /var/www/html/index.html
  EOT
}
