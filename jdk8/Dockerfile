FROM ubuntu:16.04

# Install AOSP dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y install git-core gnupg flex bison gperf build-essential \
      zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
      lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
      libgl1-mesa-dev libxml2-utils xsltproc unzip python

# Install JDK
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install openjdk-8-jdk

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo \
      -o /usr/local/bin/repo && \
    chmod +x /usr/local/bin/repo

# Set up workspace
RUN git config --global user.email "aosp-builder@example.com" && \
    git config --global user.name "AOSP builder" && \
    git config --global color.ui auto

# Volumes for AOSP source
VOLUME ["/aosp"]
VOLUME ["/mirror"]

# Build commands must be run in the AOSP source tree
WORKDIR /aosp

# Volume for external app source
VOLUME ["/app"]

# Volume for build artifacts
VOLUME ["/artifacts"]

# Set up entrypoint while working around docker/hub-feedback#811
ADD aosp.sh /usr/local/bin
RUN ln -s /usr/local/bin/aosp.sh /aosp.sh

# Show help by default
CMD ["/aosp.sh", "--help"]
