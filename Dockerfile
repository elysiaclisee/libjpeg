# Dockerfile for libjpeg-turbo vulnerability research & ASan testing
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install core build dependencies, compilers, sanitizers, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    clang \
    llvm \
    cmake \
    nasm \
    git \
    wget \
    curl \
    ca-certificates \
    valgrind \
    gdb \
    python3 \
    python3-pip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Build and install zzuf from source
RUN git clone --depth 1 https://github.com/samhocevar/zzuf.git /tmp/zzuf \
    && cd /tmp/zzuf \
    && ./bootstrap \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/zzuf

# Build and install Radamsa
RUN git clone --depth 1 https://gitlab.com/akihe/radamsa.git /tmp/radamsa \
    && cd /tmp/radamsa \
    && make \
    && make install \
    && rm -rf /tmp/radamsa || true

# Set up working directory
WORKDIR /workspace

# Copy local source code and configs
COPY . /workspace/

# Copy and ensure build script is executable
RUN chmod +x /workspace/build_asan.sh

# Run compilation for both versions with AddressSanitizer (ASan)
RUN /workspace/build_asan.sh

# Create directories for fuzzing seeds and crash artifacts
RUN mkdir -p /workspace/seeds /workspace/crashes

CMD ["/bin/bash"]
