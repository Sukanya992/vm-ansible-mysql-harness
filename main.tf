provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "example" {
  name                    = "example-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "example" {
  name          = "example-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.example.id
}

resource "google_compute_firewall" "example" {
  name    = "example-firewall"
  network = google_compute_network.example.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.example.id
    subnetwork = google_compute_subnetwork.example.id
    access_config {} # Enables external IP (like public DNS/IP)
  }

  tags = ["example"]
}

output "hostname" {
  value = google_compute_instance.example.network_interface[0].access_config[0].nat_ip
}

output "privateIp" {
  value = google_compute_instance.example.network_interface[0].network_ip
}

output "subnetId" {
  value = google_compute_subnetwork.example.id
}

output "region" {
  value = var.region
}
