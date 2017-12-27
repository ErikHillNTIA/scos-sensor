FROM ubuntu

# Update Ubuntu image
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install python prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            python-setuptools python-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install numpy build requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            python-all-dev libblas-dev liblapack-dev libatlas-base-dev gfortran && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GNURadio and UHD
# Reducing the number of packages installed per `apt-get install` call is necessary
# to avoid a network error, currently.
RUN apt-get update -q \
    && apt-get install -y --no-install-recommends \
        fontconfig fontconfig-config fonts-dejavu-core freeglut3 iso-codes \
        libasound2 libasound2-data libasyncns0 libatk1.0-0 libatk1.0-data libaudio2 \
        libavahi-client3 libavahi-common-data libavahi-common3 \
        libboost-date-time1.58.0 libboost-filesystem1.58.0 \
        libboost-program-options1.58.0 libboost-regex1.58.0 \
        libboost-serialization1.58.0 libboost-system1.58.0 libboost-thread1.58.0 \
    && apt-get install -y --no-install-recommends \
        libbsd0 libcaca0 libcairo2 libcodec2-0.4 libcomedi0 libcups2 libdatrie1 \
        libdbus-1-3 libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 \
        libdrm2 libedit2 libelf1 libfftw3-single3 libflac8 libfontconfig1 \
        libfreetype6 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri \
        libgl1-mesa-glx libglapi-mesa libglib2.0-0 libglu1-mesa \
        libgnuradio-analog3.7.9 libgnuradio-atsc3.7.9 libgnuradio-audio3.7.9 \
    && apt-get install -y --no-install-recommends \
        libgnuradio-blocks3.7.9 libgnuradio-channels3.7.9 libgnuradio-comedi3.7.9 \
        libgnuradio-digital3.7.9 libgnuradio-dtv3.7.9 libgnuradio-fcd3.7.9 \
        libgnuradio-fec3.7.9 libgnuradio-fft3.7.9 libgnuradio-filter3.7.9 \
        libgnuradio-noaa3.7.9 libgnuradio-pager3.7.9 libgnuradio-pmt3.7.9 \
        libgnuradio-qtgui3.7.9 libgnuradio-runtime3.7.9 libgnuradio-trellis3.7.9 \
        libgnuradio-uhd3.7.9 libgnuradio-video-sdl3.7.9 libgnuradio-vocoder3.7.9 \
    && apt-get install -y --no-install-recommends \
        libgnuradio-wavelet3.7.9 libgnuradio-wxgui3.7.9 libgnuradio-zeromq3.7.9 \
        libgnutls30 libgps22 libgraphite2-3 libgsl2 libgsm1 libgssapi-krb5-2 \
        libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgtk2.0-0 \
        libgtk2.0-common libharfbuzz0b libhogweed4 libice6 libicu55 libidn11 \
        libjack-jackd2-0 libjbig0 libjpeg-turbo8 libjpeg8 libjson-c2 libk5crypto3 \
        libkeyutils1 libkrb5-3 libkrb5support0 liblcms2-2 libllvm4.0 liblog4cpp5v5 \
    && apt-get install -y --no-install-recommends \
        libmng2 libnettle6 libnotify4 libogg0 liborc-0.4-0 libp11-kit0 \
        libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0 \
        libpixman-1-0 libpng12-0 libportaudio2 libpulse0 libqt4-dbus \
        libqt4-declarative libqt4-designer libqt4-help libqt4-network libqt4-opengl \
        libqt4-script libqt4-scripttools libqt4-sql libqt4-svg libqt4-test \
        libqt4-xml libqt4-xmlpatterns libqtassistantclient4 libqtcore4 libqtdbus4 \
    && apt-get install -y --no-install-recommends \
        libqtgui4 libqtwebkit4 libqwt5-qt4 libsamplerate0 libsdl1.2debian \
        libsensors4 libslang2 libsm6 libsndfile1 libsodium18 libtasn1-6 libthai-data \
        libthai0 libtiff5 libuhd003 libusb-1.0-0 libvolk1-bin libvolk1.1 libvorbis0a \
        libvorbisenc2 libwrap0 libwxbase3.0-0v5 libwxgtk3.0-0v5 libx11-6 libx11-data \
        libx11-xcb1 libxau6 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 \
        libxcb-render0 libxcb-shm0 libxcb-sync1 libxcb1 libxcomposite1 libxcursor1 \
    && apt-get install -y --no-install-recommends \
        libxdamage1 libxdmcp6 libxext6 libxfixes3 libxi6 libxinerama1 libxml2 \
        libxrandr2 libxrender1 libxshmfence1 libxslt1.1 libxt6 libxxf86vm1 libzmq5 \
        python-cairo python-cheetah python-gobject-2 python-gtk2 python-lxml \
        python-opengl python-qt4 python-sip python-wxgtk3.0 python-wxversion \
        python-zmq qdbus qtchooser qtcore4-l10n shared-mime-info ucf x11-common \
        gnuradio uhd-host \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN /usr/lib/uhd/utils/uhd_images_downloader.py

ENV PYTHONUNBUFFERED 1
RUN mkdir -p /src
WORKDIR /src
COPY ./src/requirements.txt /src
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src /src
COPY ./gunicorn /gunicorn
COPY ./config /config

RUN mkdir -p /entrypoints
COPY ./entrypoints/api_entrypoint.sh /entrypoints
COPY ./entrypoints/testing_entrypoint.sh /entrypoints

RUN mkdir -p /scripts
COPY ./scripts/create_superuser.py /scripts

RUN chmod +x /entrypoints/api_entrypoint.sh
RUN chmod +x /entrypoints/testing_entrypoint.sh # for jenkins CI

# Args are passed in via docker-compose during build time
ARG DEBUG
ARG DOMAINS
ARG IPS
ARG SECRET_KEY