# syntax=docker/dockerfile:1

ARG KALI_TAG=latest

##############################################################################
# Common base
##############################################################################
FROM kalilinux/kali-rolling:${KALI_TAG} AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

##############################################################################
# Stage 1: compile the Go and Rust tooling
##############################################################################
FROM base AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    golang \
    cargo \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libpcap-dev && \
    rm -rf /var/lib/apt/lists/*

# Binaries land straight in /out/bin, nothing to move around afterwards.
ENV GOBIN=/out/bin \
    GOPATH=/root/go \
    PATH=/usr/local/go/bin:/out/bin:$PATH

# -s -w strips DWARF/symbol tables (~25-30% off each Go binary),
# -trimpath keeps build paths out of them.
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/go/pkg/mod \
    set -eux; \
    for mod in \
    github.com/tomnomnom/hacks/tok@latest \
    github.com/tomnomnom/unfurl@latest \
    github.com/tomnomnom/qsreplace@latest \
    github.com/tomnomnom/anew@latest \
    github.com/tomnomnom/hacks/inscope@latest \
    github.com/lc/gau@latest \
    github.com/d3mondev/puredns/v2@latest \
    github.com/hueristiq/xsubfind3r/cmd/xsubfind3r@latest \
    github.com/projectdiscovery/pdtm/cmd/pdtm@latest \
    github.com/hahwul/dalfox/v2@latest \
    github.com/assetnote/kiterunner/cmd/kiterunner@latest \
    github.com/mk990/aquatone@latest \
    github.com/PentestPad/subzy@latest \
    ; do \
    go install -trimpath -ldflags="-s -w" "$mod"; \
    done

# ProjectDiscovery tools (prebuilt release binaries fetched by pdtm).
RUN set -eux; \
    pdtm -ia; \
    mv /root/.pdtm/go/bin/* /out/bin/; \
    rm -rf /root/.pdtm

ENV CARGO_PROFILE_RELEASE_STRIP=symbols \
    CARGO_TARGET_DIR=/root/target

RUN --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/target \
    cargo install --root /out ripgen rustscan x8

##############################################################################
# Stage 2: build the Python tooling into standalone pipx venvs
##############################################################################
FROM base AS pytools

ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    pipx \
    python3 \
    python3-dev \
    python3-venv \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    pipx install git+https://github.com/randixploit/crlfuzzer.git; \
    pipx install git+https://github.com/r0oth3x49/ghauri.git; \
    pipx install git+https://github.com/xnl-h4ck3r/waymore.git; \
    pipx install git+https://github.com/xnl-h4ck3r/urless.git; \
    rm -rf /root/.cache

##############################################################################
# Stage 3: runtime image - no compilers, no headers, no build caches
##############################################################################
FROM base AS runtime

ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PATH=/opt/pipx/bin:/root/.local/bin:$PATH

WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    unzip \
    jq \
    nmap \
    sqlmap \
    dnsutils \
    masscan \
    massdns \
    chromium \
    fonts-liberation \
    zsh \
    tmux \
    libpcap0.8 \
    ruby \
    dnsenum \
    seclists \
    wordlists \
    net-tools \
    default-jre-headless \
    fd-find \
    ripgrep \
    neovim \
    vim \
    fzf \
    command-not-found \
    eza \
    zoxide \
    pydf \
    htop \
    fastfetch \
    python-is-python3 \
    ffuf \
    assetfinder \
    amass \
    proxychains && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/bin/ /usr/local/bin/
COPY --from=pytools /opt/pipx/ /opt/pipx/

RUN nuclei -update-templates && touch /root/.hushlogin

COPY zshrc_extra /etc/zshrc_extra
RUN cat /etc/zshrc_extra >> /root/.zshrc

CMD ["bash"]
