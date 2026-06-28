# Step 1: Confirm that the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo or as the root user."
    exit 1
fi

# Step 2: Uninstall old versions and unofficial packages
apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Step 3: Add Docker's official GPG key
apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Step 4: Add the repository to Apt sources
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

# Step 5: Install Docker Engine, CLI, and Containerd
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin