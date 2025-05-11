# syntax=docker/dockerfile:1.4
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=devuser \  
    PATH=$PATH:/home/devuser/.local/bin

# --- Dependencias base
RUN apt-get update && apt-get install -y \
    sudo curl wget git zip unzip make build-essential cmake net-tools \
    software-properties-common libssl-dev libffi-dev \
    libcurl4-openssl-dev libxml2-dev locales zlib1g-dev \
    zsh gnupg lsb-release ca-certificates apt-transport-https \
    docker.io python3.12 python3.12-venv python3.12-dev \
    python3-pip r-base gdebi-core \
    git-flow \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Instalar Node.js (vía NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g npm

# --- pipx + pipenv + poetry
RUN apt-get update && apt-get install -y pipx && \
    pipx ensurepath && \
    pipx install pipenv && \
    pipx install poetry

# --- uv
RUN python3.12 -m pip install uv --break-system-packages

# --- Crear usuario no-root (si no existe)
RUN if ! id -u ${USERNAME} > /dev/null 2>&1; then \
      useradd -m -s /bin/bash ${USERNAME} && \
      echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    fi

# --- Locale en_US.UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# --- Instalar Quarto
RUN wget https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    gdebi -n quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

# --- Instalar CmdStanR (como root, antes de cambiar de usuario)
RUN Rscript -e "install.packages('remotes', repos='https://cloud.r-project.org')" && \
    Rscript -e "remotes::install_github('stan-dev/cmdstanr')" && \
    Rscript -e "cmdstanr::install_cmdstan()"
    
COPY entrypoint.sh /home/${USERNAME}/entrypoint.sh
RUN chmod +x /home/${USERNAME}/entrypoint.sh
ENTRYPOINT ["/home/${USERNAME}/entrypoint.sh"]

# --- Usar devuser para que VSCode trabaje cómodamente
USER $USERNAME

# --- Configuración final
WORKDIR /workspaces
EXPOSE 8888

CMD ["bash"]


