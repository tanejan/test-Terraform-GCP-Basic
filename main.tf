resource "google_compute_network" "case_study_vpc_network" {
  project                                   = "neeraj-487004"
  name                                      = "case-study-vpc-network"
  auto_create_subnetworks                   = false
}

resource "google_compute_subnetwork" "case_study_subnet" {
  name          = "case-study-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.case_study_vpc_network.id
}

resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = google_compute_network.case_study_vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]
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
  tags = ["web"]
  labels = {
    environment = var.environment
    owner       = var.owner
    managedby   = "terraform"
  }
# startup script
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Update package list and install Apache
    apt-get update
    apt-get install -y apache2
    
    systemctl start apache2
    systemctl enable apache2
    
    # Create the custom index file
    echo "<h1>Provisioned via Terraform</h1>" > /var/www/html/index.html
  EOT

}
