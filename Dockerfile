ARG NODE_VERSION=12.18.3

FROM node:$NODE_VERSION as theia

ARG GITHUB_TOKEN
ARG version=latest

WORKDIR /home/theia

ADD $version.package.json ./package.json
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM node:$NODE_VERSION

COPY --from=theia /home/theia /home/theia

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

# See: https://github.com/theia-ide/theia-apps/issues/34
RUN adduser --disabled-password --gecos '' theia && \
    chmod g+rw /home && \
    mkdir -p /home/project && \
    mkdir -p /home/go && \
    mkdir -p /home/go-tools && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/project && \
    chown -R theia:theia /home/go && \
    chown -R theia:theia /home/go-tools;

USER theia

ENV GO_VERSION=1.15 \
    GOOS=linux \
    GOARCH=amd64 \
    GOROOT=/home/go \
    GOPATH=/home/go-tools
RUN echo $PATH
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
RUN echo $PATH

# Install Go
RUN curl -fsSL https://storage.googleapis.com/golang/go$GO_VERSION.$GOOS-$GOARCH.tar.gz | tar -C /home -xzv

# Install VS Code Go tools: https://github.com/Microsoft/vscode-go/blob/058eccf17f1b0eebd607581591828531d768b98e/src/goInstallTools.ts#L19-L45
RUN go get -u -v github.com/mdempsky/gocode && \
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get -u -v github.com/ramya-rao-a/go-outline && \
    go get -u -v github.com/acroca/go-symbols && \
    go get -u -v golang.org/x/tools/cmd/guru && \
    go get -u -v golang.org/x/tools/cmd/gorename && \
    go get -u -v github.com/fatih/gomodifytags && \
    go get -u -v github.com/haya14busa/goplay/cmd/goplay && \
    go get -u -v github.com/josharian/impl && \
    go get -u -v github.com/tylerb/gotype-live && \
    go get -u -v github.com/rogpeppe/godef && \
    go get -u -v github.com/zmb3/gogetdoc && \
    go get -u -v golang.org/x/tools/cmd/goimports && \
    go get -u -v github.com/sqs/goreturns && \
    go get -u -v winterdrache.de/goformat/goformat && \
    go get -u -v golang.org/x/lint/golint && \
    go get -u -v github.com/cweill/gotests/... && \
    go get -u -v github.com/alecthomas/gometalinter && \
    go get -u -v honnef.co/go/tools/... && \
    GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint && \
    go get -u -v github.com/mgechev/revive && \
    go get -u -v github.com/sourcegraph/go-langserver && \
    go get -u -v github.com/go-delve/delve/cmd/dlv && \
    go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get -u -v github.com/godoctor/godoctor

RUN go get -u -v -d github.com/stamblerre/gocode && \
    go build -o $GOPATH/bin/gocode-gomod github.com/stamblerre/gocode

# Configure Theia
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins  \
    # Configure user Go path
    GOPATH=/home/project
ENV PATH=$PATH:$GOPATH/bin

RUN echo $PATH
RUN git config --global user.email "theia@example.com" && \
    git config --global user.name "Theia"

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/cuda/bin
EXPOSE 3000
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
