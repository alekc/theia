ARG NODE_VERSION=12.18.3

FROM theiaide/theia-full:1.12.1

USER root
# install docker
ENV DOCKERVERSION=20.10.2
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
    && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 -C /usr/local/bin docker/docker \
    && rm docker-${DOCKERVERSION}.tgz \
    && apt-get update \
    && apt install -y python3-pip vim \
    && pip3 install docker docker-compose \
    && apt-get clean autoclean \
    && apt-get autoremove --yes


WORKDIR /home/theia
ADD .bashrc /home/theia/.bashrc
ADD .bashrc /root/.bashrc

USER theia
ENTRYPOINT []
CMD [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
