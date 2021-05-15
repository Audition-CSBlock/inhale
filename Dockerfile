FROM python:3.9-slim-buster

ENV YARA_VERSION=4.1.0

COPY requirements.txt .

RUN  apt update && apt install --assume-yes apt-utils \
    && apt install --assume-yes wget git build-essential apt-transport-https procps automake libtool make gcc jq curl pkg-config libssl-dev libmagic-dev\
    # Download yara
    && wget https://github.com/VirusTotal/yara/archive/v${YARA_VERSION}.tar.gz \
    # Install yara
    && tar xvzf v${YARA_VERSION}.tar.gz \
    && cd yara-${YARA_VERSION}/ \
    && ./bootstrap.sh \
    && ./configure --enable-magic --enable-dotnet \
    && make && make install && cd / \
    && sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf' && ldconfig \
    # Download radare2 and binwalk
    && git clone https://github.com/radare/radare2 \
    && git clone https://github.com/ReFirmLabs/binwalk \
    # Install radare2
    && cd radare2 && sys/install.sh && cd / \
    # Install binwalk
    && cd binwalk && python3 setup.py install \
    # Install python dependencies
    && cd / && python3 -m pip install -r requirements.txt \
    # Clean up
    && cd / && rm -rf binwalk v${YARA_VERSION}.tar.gz v${YARA_VERSION} \
    && apt purge --assume-yes git build-essential apt-transport-https automake make gcc apt-utils \
    && apt autoremove --assume-yes && apt clean
workdir /app