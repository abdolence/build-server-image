FROM debian:13-slim

RUN apt-get update && apt-get install -y \
	curl gcc g++ make libssl-dev pkg-config locales rubygems ruby-dev git git-lfs wget \
	apt-transport-https ca-certificates gnupg-agent java-common \
	libclang-dev libsqlite3-dev libopenblas-dev libyajl-dev libicu-dev liblapack-dev liblapacke-dev cmake unzip

# Fonts (for converting SVGs mostly)
RUN apt-get install -y libfontconfig sed \
	fonts-roboto* fonts-cantarell fonts-lato* fonts-ubuntu* \
	lmodern ttf-bitstream-vera ttf-sjfonts tv-fonts

# Locales
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Langs
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

RUN mkdir -pv /usr/share/man/man1


# Java
RUN curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list
RUN apt-get update && apt-get install -y java-25-amazon-corretto-jdk

ENV JAVA_HOME /usr/lib/jvm/java-25-amazon-corretto

# SBT
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --dearmor -o /usr/share/keyrings/scalasbt.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/scalasbt.gpg] https://repo.scala-sbt.org/scalasbt/debian all main" > /etc/apt/sources.list.d/sbt.list && \
    apt-get update && \
    apt-get install -y sbt

# NodeJS PPA
RUN curl -sL https://deb.nodesource.com/setup_24.x | bash -
RUN apt-get install -y nodejs && npm install npm -g

# Yarn
RUN npm install -g yarn

# Image converting tools
RUN apt-get install -y webp

# Firebase
RUN npm install -g firebase-tools
ADD firebase.bash /usr/bin
RUN chmod +x /usr/bin/firebase.bash

# Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com trixie main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform

# Google GCS FUSE
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt gcsfuse-trixie main" > /etc/apt/sources.list.d/gcsfuse.list && \
    apt-get update && apt-get install -y gcsfuse

# Google Protobuf
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v36.1/protoc-36.1-linux-x86_64.zip && unzip protoc-36.1-linux-x86_64.zip -d /usr/local && rm protoc-36.1-linux-x86_64.zip

ENV PROTOC /usr/local/bin/protoc

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
ENV PATH="/root/.cargo/bin:/root/.local/bin:$PATH"

# Cargo tools
RUN cargo install cargo-chef
RUN cargo install cargo-audit
RUN cargo install refinery_cli
