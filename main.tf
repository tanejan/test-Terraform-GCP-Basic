resource "google_compute_network" "capstone_study_vpc_network" {
  project                                   = "neeraj-487004"
  name                                      = "capstone-study-vpc-network"
  auto_create_subnetworks                   = false
}
resource "google_compute_subnetwork" "capstone_study_subnet" {
  name          = "capstone-study-subnet"
  ip_cidr_range = "10.4.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.capstone_study_vpc_network.id
}

resource "google_compute_subnetwork" "capstone_study_public_subnet" {
  name          = "capstone-study-public-subnet"
  ip_cidr_range = "10.5.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.capstone_study_vpc_network.id
}

resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = google_compute_network.capstone_study_vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]
}
resource "google_compute_instance" "capstone_study_instance3" {
  name         = "capstone-study-instance3"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.capstone_study_subnet.id
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
resource "google_sql_database_instance" "cloussql" {
  name             = "master-instance"
  database_version = "POSTGRES_11"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}
resource "google_compute_instance" "bastion" {
  name         = "bastion-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.capstone_study_public_subnet.id
    access_config {}
  }
}
