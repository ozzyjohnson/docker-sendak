# Google mirrors are very fast.
FROM google/debian:wheezy

MAINTAINER Ozzy Johnson <ozzy.johnson@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Update and install minimal.
RUN \
  apt-get update \
            --quiet && \
  apt-get install \ 
            --yes \
            --no-install-recommends \
            --no-install-suggests \
          build-essential \
          ca-certificates \
          curl \
          git-core \
          openssh-client \
          python \
          python-dev \
          python-pip \
          python-virtualenv \
          unzip \
          vim \
          wget && \

# Clean up packages.
  apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Google Cloud SDK CLI tools.
RUN wget \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip \
      --ca-certificate /usr/local/share/certs/ca-root-nss.crt && \
    unzip google-cloud-sdk.zip && \
    rm google-cloud-sdk.zip && \
    google-cloud-sdk/install.sh \
      --bash-completion=true \
      --disable-installation-options \
      --path-update=true \
      --rc-path=/.bashrc \
      --usage-reporting=true

# Install the AWS CLI and ansible.
RUN pip install \
      awscli \
      ansible

# Install Python packages to support Ansible modules.
RUN pip install \
      apache-libcloud \
      boto \
      docker-py 

# Fabric to support Sendak.
RUN pip install \
      fabric

# Node to support Sendak.
# Taken from: https://github.com/docker-library/node/blob/master/0.11/Dockerfile
ENV NODE_VERSION 0.11.14
ENV NPM_VERSION 2.1.2

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
        && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
        && npm install -g npm@"$NPM_VERSION" \
        && npm cache clear

# Get Sendak and install node dependencies.
RUN git clone git://github.com/ozzyjohnson/Sendak.git && \
    cd Sendak && \
    npm install

# Add command completion for the AWS CLI.
RUN echo "\n# Command completion for the AWS CLI.\ncomplete -C '/usr/local/bin/aws_completer' aws" >> \
      /.bashrc

# Add a working volume mount point.
VOLUME ["/data"]

# Add volumes for tool configuration.
VOLUME ["/.ansible.cfg", "/.aws", "/.boto", "/.config", "/.gce"]

# Environment for Ansible gce module.
ENV PYTHONPATH /.gce

# Default command.
CMD ["bash"]
