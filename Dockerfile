FROM debian:stable-slim
RUN apt-get update && apt-get install -y \
	curl gcc g++ make libssl-dev pkg-config locales rubygems ruby-dev git git-lfs wget \
	apt-transport-https ca-certificates gnupg-agent software-properties-common java-common

# Fonts (for converting SVGs mostly)
RUN apt-get install -y libfontconfig sed \
	fonts-roboto* fonts-cantarell fonts-lato* fonts-ubuntu* \	
	lmodern ttf-aenigma ttf-georgewilliams ttf-bitstream-vera ttf-sjfonts tv-fonts

# Locales
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Langs
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

RUN mkdir -pv /usr/share/man/man1

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
ENV PATH="/root/.cargo/bin:/root/.local/bin:$PATH"

# Java
RUN curl https://apt.corretto.aws/corretto.key | apt-key add -
RUN add-apt-repository 'deb https://apt.corretto.aws stable main'
RUN apt-get update && apt-get install -y java-1.8.0-amazon-corretto-jdk

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-amazon-corretto

# SBT
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \ 
    apt-get update && \
    apt-get install sbt

# NodeJS PPA
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
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

