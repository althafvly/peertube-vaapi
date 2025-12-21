ARG VERSION=production
FROM chocobozzz/peertube:${VERSION}-trixie

# Enable non-free repos (Intel VAAPI)
RUN set -eux; \
    echo "deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware" > /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
    echo "deb https://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# Install VAAPI / Intel media deps
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        wget \
        libva-dev \
        vainfo \
        intel-media-va-driver-non-free \
        libvpl2 \
        libvpl-tools \
        libvpl-dev; \
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

