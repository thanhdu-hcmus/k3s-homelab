# Number of nodes — increase WORKER_COUNT to scale
MASTER_COUNT = 1
WORKER_COUNT = 2
BOX          = "bento/ubuntu-22.04"
K3S_TOKEN    = "homelab-secret-token-2024"

Vagrant.configure("2") do |config|
  config.vm.box = BOX

  # Disable update check for faster boot
  config.vm.box_check_update = false

  # ── Masters ──────────────────────────────────────────────
  (1..MASTER_COUNT).each do |i|
    config.vm.define "master#{i}" do |node|
      node.vm.hostname = "master#{i}"
      node.vm.network "private_network", ip: "192.168.56.1#{i}"

      node.vm.provider "vmware_desktop" do |v|
        v.memory = 2048
        v.cpus   = 2
        v.gui    = false
      end

      node.vm.provision "shell",
        path: "scripts/install-master.sh",
        env: { "K3S_TOKEN" => K3S_TOKEN }
    end
  end

  # ── Workers ──────────────────────────────────────────────
  (1..WORKER_COUNT).each do |i|
    config.vm.define "worker#{i}" do |node|
      node.vm.hostname = "worker#{i}"
      node.vm.network "private_network", ip: "192.168.56.2#{i}"

      node.vm.provider "vmware_desktop" do |v|
        v.memory = 2048
        v.cpus   = 2
        v.gui    = false
      end

      node.vm.provision "shell",
        path: "scripts/install-worker.sh",
        env: { "K3S_TOKEN" => K3S_TOKEN }
    end
  end
end