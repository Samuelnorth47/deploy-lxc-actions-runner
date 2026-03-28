terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://cluster.proxmox.home.arpa:8006/api2/json"
  pm_api_token_id = "root@pam!terraform-token"
  pm_tls_insecure = "true"
}

resource "proxmox_lxc" "gh-actions" {
  target_node  = "saturn"
  hostname     = "gh-actions"
  ostemplate   = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  unprivileged = true

  cores = 1
  memory = 2048
  start = true

  ssh_public_keys = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCv7OVeUsXnds8CNYb6tY90FXy7tA1Q/3HUhVl7BbnL6l1jA7/sHBL56sooXnKq5jqfXWxcCmnnPhUqAUtOJIffnduQZA0V3VFX78ZZui3BhYBi1YjEU3p4svIfAEl7bIIQn0AOdG1D3AyBE7n1n988JmDkRsS4wgfH+1QgGjezf8ySPqQhMza7uvzoi+AFo8HOEAbKyFZDIAGOMrogaSDFQ5/RBXdVWQnthN2mEIasKOnZtS0ppVjn1SiQCVovaVTgOGWq3oLpPqbOaatYv1BhNyxLf6TO+FN5JNW581UPbJTbpTc0TwecfnZQE51fxNq71Nj7DWF+hC/StQlfm9PmiR3krRsjZrch5WVCS7uB1CNvqaYgWP9ME8aQa589ieOtCXjQ3f1pWYQXuDHjzaN3w/d+4J9fSdNq9o3Bys6kBTfaSGE2Lg0vnwyopDtly+dBnp9BjDANNb6K8vcDNim+a7NSwiI79pqs4BLDSf5O2aSy0gHiw8dTEkmCwxlJg6bQAccsmZV2NsDRIpr3PT7RR3N/GbhooOGFSK/iBGwkk3218jvDt3kVlpPW8fd1VdaKtqX94RM4f6PHQssPQDDv89i4/RIHeMPNUP8V0R1SaoKUIYNg8g52rfK1NKp1TlZaLTAe+mlCbWXNeh56xMIE3ENPJ83ndyhPtp63J1NfAw== samuelnorth47@fedora
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFzJnSzXYIO3Wio9jgaKyYujOsLTuKzmATVtXm6CQub samuelnorth47@gmail.com
    EOT

  rootfs {
    storage = "local"
    size    = "25G"
  }

  nameserver = "192.168.20.1"

  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = "192.168.20.1"
    ip     = "192.168.20.55/24"
  }
}

resource "null_resource" "install_ssh" {
  depends_on = [proxmox_lxc.gh-actions]
    provisioner "local-exec" {
  command = <<EOF
    ssh root@192.168.20.11 "pct exec ${proxmox_lxc.gh-actions.vmid} -- bash -c '
    set -e
    apt update
    apt install -y openssh-server
    systemctl enable --now ssh
    '"
    EOF
    }
}