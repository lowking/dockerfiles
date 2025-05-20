name: Test install.sh on major Linux distros

on:
  push:
    paths:
      - .github/workflows/test-install.yml
  pull_request:
    paths:
      - .github/workflows/test-install.yml
  workflow_dispatch:

jobs:
  test-matrix:
    name: Test install.sh on ${{ matrix.distro }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        distro:
          - ubuntu:24.04
          - ubuntu:22.04
          - debian:bookworm
          - debian:bullseye
          - fedora:latest
          - centos:7
          - archlinux:latest
          - alpine:latest
          - opensuse/leap
    steps:
      - name: Download install.sh from gist
        run: |
          curl -fsSL https://gist.githubusercontent.com/lowking/2ec5a67272df94235253632a10907ac4/raw/install.sh -o install.sh
          chmod +x install.sh

      - name: Set up docker container for ${{ matrix.distro }}
        run: |
          echo "FROM ${{ matrix.distro }}" > Dockerfile
          echo "COPY install.sh /install.sh" >> Dockerfile
          echo 'RUN chmod +x /install.sh' >> Dockerfile
          echo 'RUN export DEBIAN_FRONTEND=noninteractive' >> Dockerfile

          # Most distros need at least these for git, sudo, curl, wget, make, etc.
          echo 'RUN (command -v apt-get >/dev/null && apt-get update && apt-get install -y sudo git curl wget make gcc pkg-config build-essential || true)' >> Dockerfile
          echo 'RUN (command -v dnf >/dev/null && dnf install -y sudo git curl wget make gcc pkgconfig || true)' >> Dockerfile
          echo 'RUN (command -v yum >/dev/null && yum install -y sudo git curl wget make gcc pkgconfig || true)' >> Dockerfile
          echo 'RUN (command -v pacman >/dev/null && pacman -Sy --noconfirm sudo git curl wget make gcc pkgconf base-devel || true)' >> Dockerfile
          echo 'RUN (command -v zypper >/dev/null && zypper --non-interactive install sudo git curl wget make gcc pkgconf || true)' >> Dockerfile
          echo 'RUN (command -v apk >/dev/null && apk add --no-cache sudo git curl wget make gcc pkgconf build-base || true)' >> Dockerfile

          # Create a non-root user for testing compatibility
          echo 'RUN useradd -m testuser || adduser -D testuser || true' >> Dockerfile
          echo 'USER testuser' >> Dockerfile
          echo 'WORKDIR /home/testuser' >> Dockerfile

      - name: Build the test container
        run: docker build -t installsh-test:${{ matrix.distro }} .

      - name: Run install.sh in container
        run: docker run --rm installsh-test:${{ matrix.distro }} bash -c "cd /home/testuser && bash /install.sh"
