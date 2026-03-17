provider "google" {
  project = "neeraj-487004"
  region  = "us-central1"
}
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

resource "google_compute_instance" "capstone_study_instance3" {
  name         = "capstone-study-instance3"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.capstone_study_subnet.id
  }
  tags = ["app"]
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
resource "google_service_account" "app_sa" {
  account_id   = "app-sa"
  display_name = "Service Account to access cloudsql"
}

resource "google_project_iam_member" "app_sql_access" {
  project = "neeraj-487004"  
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.app_sa.email}"
}
resource "google_compute_firewall" "ssh_from_bastion" {
  name    = "allow-ssh-from-bastion"
  network = google_compute_network.capstone_study_vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Restrict to Bastion subnet
  source_ranges = [google_compute_subnetwork.capstone_study_public_subnet.ip_cidr_range]

  # Apply only to App VMs
  target_tags = ["app"]
}
resource "google_sql_database_instance" "cloussql" {
  name             = "master-instance"
  database_version = "POSTGRES_11"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.capstone_study_vpc_network.id
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}
resource "google_service_account" "bastion_sa" {
  account_id   = "bastion-host-sa"
  display_name = "Service Account for Bastion Host"
}
resource "google_project_iam_member" "bastion_os_login" {
  project = "neeraj-487004"
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.bastion_sa.email}"
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
  tags = ["bastion"]
  network_interface {
    subnetwork = google_compute_subnetwork.capstone_study_public_subnet.id
    access_config {}
  }
  service_account {
      email  = google_service_account.bastion_sa.email
      scopes = ["cloud-platform"]
    }
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.capstone_study_vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

resource "google_project_service" "service_networking" {
  service = "servicenetworking.googleapis.com"
}
resource "google_compute_global_address" "private_ip_range" {
  name          = "cloudsql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.capstone_study_vpc_network.id
}
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.capstone_study_vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}
