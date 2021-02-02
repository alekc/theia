FROM theiaide/theia-go:1.9.0

USER root
ENV DOCKERVERSION=20.10.2
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
    && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 -C /usr/local/bin docker/docker \
    && rm docker-${DOCKERVERSION}.tgz \
    && apt-get update \
    && apt install -y python3-pip vim \
    && pip3 install docker docker-compose \
    && apt-get clean autoclean \
    && apt-get autoremove --yes
ADD .bashrc /home/theia/.bashrc
ADD .bashrc /root/.bashrc

RUN git config --global user.email "theia@example.com" && \
    git config --global user.name "Theia"

USER theia
