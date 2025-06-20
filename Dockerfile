FROM ubuntu:noble

SHELL ["/bin/bash", "-c"]

# ================================
# apt
# ================================
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt update && \
    apt install -y \
    curl \
    sudo \
    build-essential \
    make \
    locales \
    unzip \
    fontconfig \
    git \
    libncurses6 \
    libncurses-dev \
    binutils \
    unzip \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-13-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-13-dev \
    libxml2-dev \
    libncurses-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
    openssl \
    libssl-dev \
    inotify-tools \
    jq \
    uidmap \
    kmod \
    iptables \
    docker.io \
    && rm -r /var/lib/apt/lists/*

# ================================
# User
# ================================
RUN echo 'claude ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/claude
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /claude claude
RUN usermod -aG docker claude
USER claude:claude
WORKDIR /claude

# ================================
# Docker
# ================================
ENV DOCKER_HOST="unix:///var/run/docker.sock"

# ================================
# Open Tofu
# ================================
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
RUN chmod +x install-opentofu.sh
RUN ./install-opentofu.sh --install-method deb
RUN rm -f install-opentofu.sh

# ================================
# Setup Swift
# ================================
WORKDIR /swiftly
RUN NONINTERACTIVE=1 curl -O "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz" && \
    tar zxf "swiftly-$(uname -m).tar.gz" && \
    ./swiftly init --quiet-shell-followup && \
    . ${SWIFTLY_HOME_DIR:-~/.local/share/swiftly}/env.sh && \
    hash -r && \
    echo "source ${SWIFTLY_HOME_DIR:-~/.local/share/swiftly}/env.sh" >> /claude/.bashrc

# ================================
# Homebrew
# ================================
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo >> /claude/.bashrc
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /claude/.bashrc
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
RUN brew install vapor
RUN brew install git
RUN brew install swift-protobuf
RUN brew install aws-sam-cli
RUN brew install swift-format
RUN brew install tree
RUN brew install xh
RUN brew install oven-sh/bun/bun
RUN brew install deno
RUN brew install cloudflare-wrangler
RUN brew unlink swift

WORKDIR /claude/workspace

# ================================
# Permission
# ================================
RUN sudo chown -R claude:claude /swiftly
RUN sudo chown -R claude:claude /claude/workspace

# ================================
# Claude Code
# ================================
RUN bun install -g @anthropic-ai/claude-code
ENV PATH="/claude/.bun/bin:${PATH}"
RUN echo "alias claude-force='claude --dangerously-skip-permissions'" >> /claude/.bashrc

# ================================
# Playwright MCP
# ================================
RUN bunx playwright@latest install chromium
RUN bunx playwright@latest install-deps chromium

# ================================
# AWS MCP
# ================================
RUN brew install uv
RUN uv python install 3.10

# ================================
# Setup
# ================================
COPY setup.sh /claude/setup.sh
RUN sudo chmod +x /claude/setup.sh
ENTRYPOINT ["/claude/setup.sh"]
CMD ["/bin/bash"]
