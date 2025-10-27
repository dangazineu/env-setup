#!/bin/bash

set -e

source functions.sh
install_command curl

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=mac ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64"|"aarch64") ARCH=arm64 ;;
  "x86_64"|"amd64") ARCH=amd64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

case $OS in
  "linux")
    echo "Installing Docker Engine on Linux..."

    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      DISTRO=$ID
      VERSION_CODENAME=$VERSION_CODENAME
    else
      echo "Cannot detect Linux distribution"
      exit 1
    fi

    # Currently supports Ubuntu and Debian
    case $DISTRO in
      "ubuntu"|"debian")
        echo "Detected $DISTRO distribution"

        # Remove old versions
        echo "Removing old versions of Docker..."
        apt remove -y docker docker-engine docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true

        # Install prerequisites
        echo "Installing prerequisites..."
        install_command ca-certificates curl

        # Add Docker's official GPG key
        echo "Adding Docker GPG key..."
        if ! is_sudo ; then
          sudo install -m 0755 -d /etc/apt/keyrings
          sudo curl -fsSL https://download.docker.com/linux/$DISTRO/gpg -o /etc/apt/keyrings/docker.asc
          sudo chmod a+r /etc/apt/keyrings/docker.asc
        else
          install -m 0755 -d /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/$DISTRO/gpg -o /etc/apt/keyrings/docker.asc
          chmod a+r /etc/apt/keyrings/docker.asc
        fi

        # Add Docker repository
        echo "Adding Docker repository..."
        DOCKER_REPO="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DISTRO $VERSION_CODENAME stable"

        if ! is_sudo ; then
          echo "$DOCKER_REPO" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
          sudo apt update
        else
          echo "$DOCKER_REPO" | tee /etc/apt/sources.list.d/docker.list > /dev/null
          apt update
        fi

        # Install Docker Engine
        echo "Installing Docker Engine, CLI, and plugins..."
        install_command docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Configure Docker group
        echo "Configuring Docker group..."
        if ! is_sudo ; then
          sudo groupadd docker 2>/dev/null || true
          sudo usermod -aG docker "$USER"
          echo "Note: You may need to log out and back in for group changes to take effect"
        else
          groupadd docker 2>/dev/null || true
          if [ -n "$SUDO_USER" ]; then
            usermod -aG docker "$SUDO_USER"
            echo "Note: User $SUDO_USER added to docker group. Log out and back in for changes to take effect"
          fi
        fi

        # Enable Docker service
        echo "Enabling Docker service..."
        if ! is_sudo ; then
          sudo systemctl enable docker
          sudo systemctl start docker 2>/dev/null || true
        else
          systemctl enable docker
          systemctl start docker 2>/dev/null || true
        fi

        echo "Docker Engine installed successfully"
        docker --version
        ;;
      *)
        echo "Unsupported Linux distribution: $DISTRO"
        echo "This script currently supports Ubuntu and Debian"
        exit 1
        ;;
    esac
    ;;

  "mac")
    echo "Installing Docker on macOS..."
    echo "Docker Desktop will be installed via Homebrew..."

    # Check if Homebrew is available
    if ! command -v brew &> /dev/null; then
      echo "Homebrew is required but not installed"
      echo "Please install Homebrew from https://brew.sh/ and try again"
      exit 1
    fi

    # Install Docker Desktop via Homebrew Cask
    echo "Installing Docker Desktop..."
    brew install --cask docker

    echo "Docker Desktop installed successfully"
    echo "Note: You may need to start Docker Desktop from Applications folder"
    echo "After starting Docker Desktop, run 'docker --version' to verify installation"
    ;;
esac

echo "Docker installation complete!"
