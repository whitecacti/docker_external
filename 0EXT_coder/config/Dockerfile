FROM codercom/enterprise-base:ubuntu

USER root

# Base dependencies
RUN apt-get update && apt-get install -y \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev \
    wget curl llvm libncursesw5-dev xz-utils \
    tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
    liblzma-dev net-tools git unzip dnsutils \ 
    traceroute iputils-ping nmap hping3 \
    ncat \
    && rm -rf /var/lib/apt/lists/* \
    && apt upgrade -y 

# C#
RUN add-apt-repository -y ppa:dotnet/backports \
    && apt-get update -y \
    && apt-get install -y dotnet-sdk-9.0

# Go (installed to /usr/local, accessible to all users)
ENV PATH="/usr/local/go/bin:$PATH"
RUN curl -LO https://go.dev/dl/go1.25.5.linux-arm64.tar.gz \
    && tar -C /usr/local -xzf go1.25.5.linux-arm64.tar.gz \
    && rm go1.25.5.linux-arm64.tar.gz

# pyenv + Python (install globally, make accessible to all users)
ENV PYENV_ROOT=/opt/pyenv
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
RUN curl https://pyenv.run | bash \
    && eval "$(pyenv init -)" \
    && pyenv install 3.11.10 \
    && pyenv global 3.11.10 \
    && pyenv virtualenv 3.11.10 main_env \ 
    && pyenv global main_env \
    && chmod -R 755 /opt/pyenv

# Add paths to global profile so all users (including coder) get them
RUN echo 'export PYENV_ROOT=/opt/pyenv' >> /etc/profile.d/dev-tools.sh \
    && echo 'export PATH="/opt/pyenv/bin:/opt/pyenv/shims:/usr/local/go/bin:$PATH"' >> /etc/profile.d/dev-tools.sh \
    && echo 'eval "$(pyenv init -)"' >> /etc/profile.d/dev-tools.sh \
    && chmod +x /etc/profile.d/dev-tools.sh

# nvm and node (user-specific install for coder)
USER coder
WORKDIR /home/coder
ENV NVM_DIR=/home/coder/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 22 \
    && nvm use 22 \
    && nvm alias default 22 \
    && echo 'export NVM_DIR="/home/coder/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

USER root

RUN ln -sf /home/coder/.nvm/versions/node/v22.*/bin/node /usr/local/bin/node \
    && ln -sf /home/coder/.nvm/versions/node/v22.*/bin/npm /usr/local/bin/npm \
    && ln -sf /home/coder/.nvm/versions/node/v22.*/bin/npx /usr/local/bin/npx

# Security tools
RUN wget https://github.com/ffuf/ffuf/releases/download/v2.1.0/ffuf_2.1.0_linux_arm64.tar.gz \
    && tar -xzf ffuf_2.1.0_linux_arm64.tar.gz \
    && mv ffuf /usr/local/bin/ \
    && rm ffuf_2.1.0_linux_arm64.tar.gz

USER coder

SHELL ["/bin/bash", "-c"]