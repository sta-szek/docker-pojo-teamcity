FROM openjdk:8-alpine
MAINTAINER Piotr Joński <p.jonski@pojo.pl>

ARG TEAMCITY_VERSION=2017.1.5
ARG USER_ID=2000
ARG USER_NAME=jetbrains

ENV PORT=8111
ENV TEAMCITY_DATA_PATH=/teamcity/.BuildServer

RUN apk --update add shadow curl bash

RUN groupadd --gid ${USER_ID} ${USER_NAME} && \
    useradd --create-home --home-dir /teamcity --uid ${USER_ID} --gid ${USER_NAME} ${USER_NAME} && \
    chown --changes ${USER_NAME}:${USER_NAME} /teamcity

USER ${USER_NAME}
WORKDIR /teamcity

RUN mkdir .BuildServer && \
    curl --location "https://download.jetbrains.com/teamcity/TeamCity-${TEAMCITY_VERSION}.tar.gz" > teamcity.tar.gz && \
    tar -xf teamcity.tar.gz && \
    rm -f teamcity.tar.gz && \
    mv TeamCity/* . && \
    rm -rf TeamCity && \
    rm -rf devPackage

EXPOSE ${PORT}
CMD [ "/bin/bash", "/teamcity/bin/teamcity-server.sh", "run" ]
