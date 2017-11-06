#!/usr/bin/env bash

JETBRAINS_USER_NAME=jetbrains
JETBRAINS_USER_ID=2000

# create user if not exist
if [ $(getent passwd ${JETBRAINS_USER_NAME}) ]; then
    echo "user ${JETBRAINS_USER_NAME} already exists"
else
    echo "creating user ${JETBRAINS_USER_NAME}"
    groupadd --gid ${JETBRAINS_USER_ID} ${JETBRAINS_USER_NAME}
    useradd --system --uid ${JETBRAINS_USER_ID} --gid ${JETBRAINS_USER_NAME} ${JETBRAINS_USER_NAME}
fi

# create directories if not exist
if [ -d teamcity/.BuildServer ]; then
    echo "directory teamcity/.BuildServer already exist"
else
    mkdir --mode 770 --verbose --parents teamcity/.BuildServer/lib/jdbc
    curl "https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar" -o teamcity/.BuildServer/lib/jdbc/postgresql-9.4.1212.jar
fi

if [ -d postgres/data ]; then
    echo "directory postgres/data already exist"
else
    mkdir --mode 770 --verbose --parents postgres
fi

chmod --recursive 770 teamcity
chmod --recursive 770 postgres
chown --changes --verbose --recursive ${JETBRAINS_USER_NAME}:${USER} teamcity
chown --changes --verbose --recursive ${JETBRAINS_USER_NAME}:${USER} postgres

#run docker
docker-compose up -d --force-recreate