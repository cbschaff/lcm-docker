# Base image is library/ubuntu:16.04
FROM ubuntu:16.04

# set default VERSION
ENV VERSION "1.3.1"

# set default LCM_DEFAULT_URL
ENV LCM_DEFAULT_URL "udpm://239.255.76.67:7667?ttl=1"

# set default installation dir
ENV LCM_INSTALL_DIR "/usr/local/lib"

# update apt lists and install system libraries, then clean the apt cache
RUN apt-get update && apt-get install -y \
    apt-utils \
    wget \
    build-essential \
    libglib2.0-dev \
    python-dev \
    unzip \
    net-tools \
    # clean the apt cache
    && rm -rf /var/lib/apt/lists/*

# pull lcm
RUN wget https://github.com/lcm-proj/lcm/releases/download/v$VERSION/lcm-$VERSION.zip

# open up the source
RUN unzip lcm-$VERSION.zip

# configure, build, install, and configure LCM
RUN cd lcm-$VERSION; ./configure; make; make install; ldconfig

# delete source code
RUN rm -rf lcm-$VERSION.zip lcm-$VERSION

# set the Kernel UDP buffer size to 10MB
RUN echo 'net.core.rmem_max=10485760' >> /etc/sysctl.conf
RUN echo 'net.core.rmem_default=10485760' >> /etc/sysctl.conf

# copy examples
COPY assets/examples /root/examples

# build examples
RUN cd /root/examples/publisher; lcm-gen -p example_t.lcm
