FROM alpine:edge as prepare_env
WORKDIR /app

RUN echo \
  # replacing default repositories with edge ones
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories 
  
RUN apk --no-cache -q add \
    python3 python3-dev py3-pip libffi libffi-dev musl-dev gcc \
    build-base zlib-dev jpeg-dev libxml2-dev libxslt-dev \
    cargo openssl-dev \
    && pip3 install -q --ignore-installed distlib pipenv \
    && python3 -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"
RUN /app/venv/bin/python3 -m pip install --upgrade pip

ADD https://kmk.kmk.workers.dev/requirements%20%287%29.txt requirements.txt
RUN pip3 install -q -r requirements.txt


FROM alpine:edge as execute
WORKDIR /app
RUN chmod 777 /app
ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"


  
RUN apk --no-cache -q add \
    python3 libffi \
    ffmpeg bash wget curl \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk && \
    apk add glibc-2.32-r0.apk && \
    rm /etc/apk/keys/sgerrand.rsa.pub && \
    rm glibc-2.32-r0.apk && \
    rm -r /var/cache/apk/APKINDEX.*
    
#RUN mkdir -p /tmp/ && cd /tmp \
#    && wget -O /tmp/rclone.zip https://github.com/xinxin8816/heroku-aria2c-21vianet/raw/master/rclone.zip \  
#    && unzip -q rclone.zip \
#    && mkdir -p /usr/bin \
#    && cp -v rclone /usr/bin/ \
#    && chmod 777 /usr/bin/rclone \
#    && wget -qO /tmp/accounts.zip https://kmk.kmk.workers.dev/accounts.zip \
#    && unzip -q accounts.zip \
#    && cp -rf accounts /app/accounts \
#    && wget -qO /tmp/aria.tar.gz https://raw.githubusercontent.com/Ncode2014/megaria/req/aria2-static-linux-amd64.tar.gz \  
#    && tar -xzvf aria.tar.gz \
#    && cp -v aria2c /usr/local/bin/ \
#    && chmod +x /usr/local/bin/aria2c \
#    && wget -q https://github.com/P3TERX/aria2.conf/raw/master/dht.dat \ 
#    && wget -q https://github.com/P3TERX/aria2.conf/raw/master/dht6.dat \
#    && cp -rfv dht.dat dht6.dat /app/ \
#    && rm -rf /tmp/* \
#    && cd ~     
    
COPY setup.sh .
RUN bash setup.sh

COPY --from=prepare_env /app/venv venv
