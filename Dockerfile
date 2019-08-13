FROM alpine:3.7 as build
# inspired by https://devblogs.microsoft.com/cppblog/using-multi-stage-containers-for-c-development/

MAINTAINER https://github.com/maverage/docker-vsomeip

LABEL description="Build vsomeip"
 
RUN apk update && apk add --no-cache \ 
    build-base binutils cmake curl gcc g++ git boost-dev libgcc libtool linux-headers make tar
    
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
    cd /tmp/vsomeip-${VSOMEIP_VERSION}; \
    mkdir build && cd build; \
    cmake ..; \
    make;
 
FROM alpine:3.7 as runtime
 
LABEL description="runtime of vsomeipd"

COPY --from=build /tmp/vsomeip-${VSOMEIP_VERSION}/build/*.so /usr/local/lib
COPY --from=build /tmp/vsomeip-${VSOMEIP_VERSION}/build/vsomeipd /usr/local/bin
 
WORKDIR /usr/local/bin

CMD ldconfig
CMD ./vsomeipd
 
#EXPOSE TBD
