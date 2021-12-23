FROM alpine

LABEL AUTHOR="lowking" \
      VERSION=0.1

ENV PATH=/usr/local/bin:$PATH LANG=C.UTF-8

RUN set -ex \
        && apk update \
        && apk upgrade \
        && apk add --no-cache bash tzdata git moreutils curl jq openssh-client npm \
        && rm -rf /var/cache/apk/* \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && mkdir -p /root/.ssh \
        && npm config set registry https://registry.npm.taobao.org

COPY ./docker-entrypoint.sh /usr/local/bin

RUN set -ex \
        chmod 600 /root/.ssh/id_rsa

WORKDIR /surgio
CMD ["master"]
ENTRYPOINT ["docker-entrypoint.sh"]
