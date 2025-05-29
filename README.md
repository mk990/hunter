# Kali-Based Offensive Security & Recon Toolkit Docker Image

This repository provides a powerful and extensible Docker image built on top of the official `kalilinux/kali-rolling` image. It is tailored for penetration testing, bug bounty hunting, and reconnaissance tasks, combining popular tools written in Go, Rust, Python, and more.

## 🧰 Features

- **Base Image**: Kali Linux (Rolling)
- **Preinstalled Tools**:
  - 🧪 Penetration Testing: `nmap`, `sqlmap`, `masscan`, `amass`, `dalfox`, `nuclei`
  - 🔎 Reconnaissance: `assetfinder`, `ffuf`, `gau`, `unfurl`, `subzy`, `xsubfind3r`
  - 🧰 Utility Tools: `tmux`, `zsh`, `fzf`, `eza`, `zoxide`, `htop`, `proxychains`, `neovim`, `vim`
  - 🦀 Rust Tools: `ripgen`, `rustscan`, `x8`
  - 🐍 Python Tools: `waymore`, `urless`, `crlfuzzer`, `ghauri`
  - 🐹 Go Tools via `go install`: preinstalled and relocated to `/usr/local/bin`
  - 🛠 PDTM for Go binary management and updates

## 📦 Installation

Clone this repository and build the Docker image:

```bash
git clone https://raw.githubusercontent.com/mk990/hunter.git
cd hunter
docker build -t hunter .
```

Or run it directly from Quay

```bash
docker run --rm -it --hostname hunter -v ./save:/root/save quay.io/mk990/hunter zsh
```
