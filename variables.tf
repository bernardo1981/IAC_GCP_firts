# Configurar el proveedor de GCP
provider "google" {
  project = "your-gcp-project-id"   # Reemplaza con tu ID de proyecto
  region  = "us-central1"            # Reemplaza con tu región preferida
}

# Definir la red
resource "google_compute_network" "vpc_network" {
  name = "my-vpc-network"
}

# Definir la subred
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"  # Asegúrate de que coincida con la región del proveedor
}

# Definir la VM
resource "google_compute_instance" "vm_instance" {
  name         = "my-vm"
  machine_type = "e2-medium"  # Tipo de máquina, puedes cambiarlo según tus necesidades

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # Imagen del SO, puedes cambiarlo según tus necesidades
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name

    access_config {
      # Incluye acceso público con una IP externa
    }
  }

  tags = ["http-server"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOT
}

# Permitir tráfico HTTP en el firewall
resource "google_compute_firewall" "default" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
