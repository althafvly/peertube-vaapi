ARG VERSION=v6.1.0
FROM chocobozzz/peertube:${VERSION}-bookworm

# Enable non-free repos (Intel VAAPI)
RUN set -eux; \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
    echo "deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# Install VAAPI / Intel media deps
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        wget \
        libva-dev \
        vainfo \
        intel-media-va-driver-non-free \
        libmfx1 \
        libmfx-tools \
        libmfx-dev; \
    rm -rf /var/lib/apt/lists/*

# Disable stream copy when scaling
RUN sed -i \
    's/(scaleFilterValue/(scaleFilterValue \&\& !builderResult.result.copy/' \
    ./packages/ffmpeg/dist/shared/presets.js

# Fix VAAPI device permissions at startup
RUN sed -i \
    '/find \/data ! -user peertube -exec  chown peertube:peertube {} \\;/a \
    if [ -e "/dev/dri/renderD128" ]; then\n\
        chmod 777 /dev/dri/renderD128\n\
    fi' \
    /usr/local/bin/entrypoint.sh

