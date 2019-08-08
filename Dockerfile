FROM alpine:latest as build
# inspired by https://devblogs.microsoft.com/cppblog/using-multi-stage-containers-for-c-development/

MAINTAINER https://github.com/maverage/docker-vsomeip

LABEL description="Build vsomeip"
 
RUN apk update && apk add --no-cache \ 
    build-base binutils cmake gcc g++ git libgcc libtool linux-headers make tar -y
    
# the following content is inspired by https://github.com/YOURLS/docker-yourls/blob/master/fpm-alpine/Dockerfile

ENV VSOMEIP_VERSION 2.14.16
ENV VSOMEIP_SHA256 TBD

RUN set -eux; \
    curl -o vsomeip.tar.gz -fsSL "https://github.com/GENIVI/vsomeip/archive/${VSOMEIP_VERSION}.tar.gz"; \
    echo "$VSOMEIP_SHA256 *vsomeip.tar.gz" | sha256sum -c -; \
# upstream tarballs include ./vsomeip-${VSOMEIP_VERSION}/ so this gives us /usr/src/vsomeip-${VSOMEIP_VERSION}
    tar -xf vsomeip.tar.gz -C /usr/src/; \
# build
# clean up
    rm vsomeip.tar.gz; \
    rm -r "/usr/src/vsomeip-${VSOMEIP_VERSION}"; 
 

 
FROM alpine:latest as runtime
 
LABEL description="runtime of vsomeipd"

#COPY --from=build /src /target
 
WORKDIR /tbd
 
CMD ./vsomeipd
 
#EXPOSE TBD
