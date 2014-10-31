FROM ubuntu:14.04
MAINTAINER Simo Kinnunen

# Update
RUN export DEBIAN_FRONTEND=noninteractive && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install software-properties-common

# Install AOSP dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install build-essential && \
    apt-get -y install git gnupg ccache lzop flex bison gperf \
      build-essential zip curl zlib1g-dev zlib1g-dev:i386 libc6-dev \
      lib32bz2-1.0 lib32ncurses5-dev x11proto-core-dev libx11-dev:i386 \
      libreadline6-dev:i386 lib32z1-dev libgl1-mesa-glx:i386 \
      libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
      libxml2-utils xsltproc libreadline6-dev lib32readline-gplv2-dev \
      libncurses5-dev bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev \
      lib32bz2-dev squashfs-tools pngcrush schedtool dpkg-dev && \
    ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 \
      /usr/lib/i386-linux-gnu/libGL.so

# Install JDK
RUN export DEBIAN_FRONTEND=noninteractive && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | \
      sudo debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | \
      sudo debconf-set-selections && \
    apt-get -y install oracle-java6-installer oracle-java6-set-default

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

# Set up entrypoint
ADD aosp.sh /

# Show help by default
CMD ["/aosp.sh", "--help"]
