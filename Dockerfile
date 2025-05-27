FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin:/root/.cargo/bin:/root/.pdtm/go/bin:/root/.local/bin

WORKDIR /root

# Update and install essential packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    golang \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    pipx \
    unzip \
    jq \
    nmap \
    sqlmap \
    dnsutils \
    masscan \
    massdns \
    chromium \
    zsh \
    npm \
    tmux \
    build-essential \
    libssl-dev \
    libffi-dev \
    libpcap-dev \
    cargo \
    ruby-full \
    dnsenum \
    seclists \
    wordlists \
    net-tools \
    default-jdk \
    fd-find \
    ripgrep \
    zsh \
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

# Install Go tools
RUN go install github.com/tomnomnom/hacks/tok@latest && \
    go install github.com/tomnomnom/unfurl@latest && \
    go install github.com/tomnomnom/qsreplace@latest && \
    go install github.com/tomnomnom/anew@latest && \
    go install github.com/tomnomnom/hacks/inscope@latest && \
    go install github.com/lc/gau@latest && \
    go install github.com/d3mondev/puredns/v2@latest && \
    go install github.com/hueristiq/xsubfind3r/cmd/xsubfind3r@latest && \
    go install github.com/projectdiscovery/pdtm/cmd/pdtm@latest && \
    go install github.com/hahwul/dalfox/v2@latest && \
    go install github.com/assetnote/kiterunner/cmd/kiterunner@latest && \
    go install github.com/mk990/aquatone@latest && \
    go install github.com/PentestPad/subzy@latest && \
    mv /root/go/bin/* /usr/local/bin && \
    rm -rf /root/go && \
    rm -rf .cache/go-build

RUN cargo install ripgen && \
    cargo install rustscan && \
    cargo install x8 && \
    mv /root/.cargo/bin/* /usr/local/bin && \
    rm -rf /root/.cargo

RUN pdtm -ia && \
    mv /root/.pdtm/go/bin/* /usr/local/bin && \
    rm -rf /root/go && \
    rm -rf /root/.pdtm && \
    rm -rf .cache/go-build

RUN pipx install git+https://github.com/randixploit/crlfuzzer.git && \
    pipx install git+https://github.com/r0oth3x49/ghauri.git && \
    pipx install git+https://github.com/xnl-h4ck3r/waymore.git && \
    pipx install git+https://github.com/xnl-h4ck3r/urless.git

RUN apt-get update && nuclei

COPY zshrc_extra  /etc/zshrc_extra
RUN cat /etc/zshrc_extra >> /root/.zshrc

CMD ["bash"]
