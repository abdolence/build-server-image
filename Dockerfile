FROM debian:11-slim

RUN apt-get update && apt-get install -y \
	curl gcc g++ make libssl-dev pkg-config locales rubygems ruby-dev git git-lfs wget \
	apt-transport-https ca-certificates gnupg-agent software-properties-common java-common \
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
RUN curl https://apt.corretto.aws/corretto.key | gpg --dearmor | dd of=/usr/share/keyrings/corretto.gpg && echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list
RUN apt-get update && apt-get install -y java-11-amazon-corretto-jdk

ENV JAVA_HOME /usr/lib/jvm/java-11-amazon-corretto

# SBT
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \ 
    apt-get update && \
    apt-get install sbt

# NodeJS PPA
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs && npm install npm -g

# Workbox
RUN npm install workbox-cli --global

# Yarn
RUN npm install -g yarn

# SASS
RUN npm install -g node-sass --unsafe-perm --force

# Image converting tools
RUN npm install -g svgexport --unsafe-perm --force
RUN apt install -y webp

# Firebase
RUN npm install -g firebase-tools
ADD firebase.bash /usr/bin
RUN chmod +x /usr/bin/firebase.bash

# Terraform
RUN curl -sL "https://apt.releases.hashicorp.com/gpg" | apt-key add && \ 
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install terraform -y

# Google GCS FUSE
RUN curl -sL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add && \ 
    apt-add-repository "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" && \
    apt-get update && apt-get install gcsfuse -y

# Google Protobuf
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v24.0/protoc-24.0-linux-x86_64.zip && unzip protoc-24.0-linux-x86_64.zip -d /usr/local

ENV PROTOC /usr/local/bin/protoc

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
ENV PATH="/root/.cargo/bin:/root/.local/bin:$PATH"

# Cargo tools
RUN cargo install cargo-chef
RUN cargo install cargo-audit
RUN cargo install refinery_cli
