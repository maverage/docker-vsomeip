FROM ubuntu:bionic as build
# inspired by https://devblogs.microsoft.com/cppblog/using-multi-stage-containers-for-c-development/

MAINTAINER https://github.com/maverage/docker-vsomeip

LABEL description="Build vsomeip"
 
RUN apt-get update && apt-get install -y \
    binutils cmake curl gcc g++ git libboost-all-dev libtool make tar

# the following content is inspired by https://github.com/YOURLS/docker-yourls/blob/master/fpm-alpine/Dockerfile

ENV VSOMEIP_VERSION 2.14.16
ENV VSOMEIP_SHA256 TBD

RUN set -eux; \
# download
    curl -o vsomeip.tar.gz -fsSL "https://github.com/GENIVI/vsomeip/archive/${VSOMEIP_VERSION}.tar.gz"; \
    # echo "$VSOMEIP_SHA256 *vsomeip.tar.gz" | sha256sum -c -; \
# upstream tarballs include ./vsomeip-${VSOMEIP_VERSION}/ so this gives us /usr/src/vsomeip-${VSOMEIP_VERSION}
    tar -xf vsomeip.tar.gz -C /tmp/; \
# cleanup download
    rm vsomeip.tar.gz; \
# build
    mv /tmp/vsomeip-${VSOMEIP_VERSION} /tmp/vsomeip; \
    cd /tmp/vsomeip; \
    mkdir build && cd build; \
    cmake ..; \
    make;

#### RUNTIME ####
FROM ubuntu:bionic as runtime
 
LABEL description="runtime of vsomeipd"


COPY --from=build /tmp/vsomeip/build/daemon/vsomeipd /usr/bin/
COPY --from=build /tmp/vsomeip/build/*.so* /usr/lib/

RUN apt-get update && apt-get install -y --no-install-recommends \
    libboost-log-dev net-tools && ifconfig


WORKDIR /usr/bin/

CMD ldconfig
CMD ./vsomeipd

#EXPOSE TBD
