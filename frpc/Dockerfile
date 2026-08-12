ARG BUILD_FROM=alpine:3.20
FROM ${BUILD_FROM}

ARG FRP_VERSION=0.61.1
ARG FRP_ARCH=arm64
ARG FRP_SHA256=af6366f2b43920ebfe6235dba6060770399ed1fb18601e5818552bd46a7621f8

# Download the OFFICIAL frp release, verify its sha256 against the pinned value, install
# only the frpc binary, then drop the download tooling. No runtime downloads.
RUN apk add --no-cache ca-certificates jq \
 && apk add --no-cache --virtual .dl curl tar \
 && cd /tmp \
 && curl -fsSL -o frp.tgz \
      "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz" \
 && echo "${FRP_SHA256}  frp.tgz" | sha256sum -c - \
 && tar xzf frp.tgz \
 && install -m 0755 "frp_${FRP_VERSION}_linux_${FRP_ARCH}/frpc" /usr/bin/frpc \
 && rm -rf /tmp/* \
 && apk del .dl

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
