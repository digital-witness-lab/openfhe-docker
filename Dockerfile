FROM python:3.11-bookworm

ARG devtag=v1.1.1
ARG pythontag=v0.8.2
ARG CC_param=/usr/bin/gcc
ARG CXX_param=/usr/bin/g++

ENV DEBIAN_FRONTEND=noninteractive
ENV CC $CC_param
ENV CXX $CXX_param

#install pre-requisites for OpenFHE
RUN apt update && \
    apt install -y git \
                   build-essential \
                   gcc \
                   g++ \
                   cmake \
                   autoconf \
                   libomp5 \
                   libomp-dev \
                   doxygen \
                   graphviz \
                   libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /app/build

WORKDIR /openfhe/build

RUN git clone https://github.com/openfheorg/openfhe-development.git && \
    cd openfhe-development && \
    git checkout $devtag && \
    git submodule sync --recursive && \
    git submodule update --init  --recursive

RUN mkdir openfhe-development/build && \
    cd openfhe-development/build && \
    cmake .. && \
    make -j $(( $(nproc) * 3 / 4 )) && \
    make install

RUN git clone https://github.com/openfheorg/openfhe-python.git && \
    cd openfhe-python && \
    git checkout $pythontag && \
    pip install "pybind11[global]"  && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j $threads && \
    make install

ENV PYTHONPATH=/usr/local/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
