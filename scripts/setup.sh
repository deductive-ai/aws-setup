#!/usr/bin/env bash
gCURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function brew_upsert() {
  local package=$1
  if ! brew list "$package" &>/dev/null; then
    echo "Installing $package..."
    brew install "$package"
  else
    echo "$package already installed"
  fi
}

function install_common_tools_mac() {
  echo "Setting up macOS tools..."
  for package in terraform go tflint; do
    brew_upsert "$package"
  done
}

function install_common_tools_debian() {
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y golang-go terraform
}

function install_common_tools_fedora() {
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install -y terraform golang
}

function install_common_tools_linux() {
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
}

function install_go_packages() {
    go install github.com/aquasecurity/tfsec/cmd/tfsec@v1.28.14
}

if [ "$(uname)" = "Darwin" ]; then
  install_common_tools_mac
else
  install_common_tools_linux
  if [ -f /etc/os-release ]; then
    id=$(grep ^ID= /etc/os-release | sed 's/ID=//')
    case "$id" in
    ubuntu|debian)
      install_common_tools_debian
      ;;
    fedora)
      install_common_tools_fedora
      ;;
    *)
      echo "Unsupported Linux distribution: $id"
      exit 1
      ;;
    esac
  else
    echo "Unknown operating system."
    exit 1
  fi
fi

install_go_packages

# configure go env path for bash, zsh and fish
# check current running session is bash, zsh or fish
_GO_BIN_PATH="$(go env GOPATH)/bin"
if [ -n "$BASH_VERSION" ]; then
    # check if the path is inside the .bashrc
    if grep -q "$_GO_BIN_PATH" ~/.bashrc; then
        echo "Go path already configured in .bashrc"
    else
        echo 'export PATH="$PATH:$(go env GOPATH)/bin"' >> ~/.bashrc
    fi
elif [ -n "$ZSH_VERSION" ]; then
    if grep -q "$_GO_BIN_PATH" ~/.zshrc; then
        echo "Go path already configured in .zshrc"
    else
        echo 'export PATH="$PATH:$(go env GOPATH)/bin"' >> ~/.zshrc
    fi
elif [ -n "$FISH_VERSION" ]; then
    if grep -q "$_GO_BIN_PATH" ~/.config/fish/config.fish; then
        echo "Go path already configured in config.fish"
    else
        echo 'set -x PATH "$PATH:$(go env GOPATH)/bin"' >> ~/.config/fish/config.fish
    fi
else
    echo "Unsupported shell."
    exit 1
fi

gROOT_DIR="$(cd -- "$(dirname -- "$BASH_SOURCE")/.." && pwd)"

# configure venv for checkov
$gCURRENT_DIR/setup-python-venv-uv.sh $gROOT_DIR

# run validation once
# get the script directory then the validate.sh is on the same folder
PATH="$PATH:$(go env GOPATH)/bin:${gROOT_DIR}/.venv/bin" "$gCURRENT_DIR/validate.sh"
