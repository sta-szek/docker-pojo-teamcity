#!/usr/bin/env bash

SERVICE_NAME=teamcity
JETBRAINS_USER_NAME=jetbrains
DIRS_TO_CREATE=(backups data logs temp conf)
JETBRAINS_USER_ID=2000
PORT=8080

# create user if not exist
if [ $(getent passwd ${JETBRAINS_USER_NAME}) ]; then
    echo "user ${JETBRAINS_USER_NAME} already exists"
else
    echo "creating user ${JETBRAINS_USER_NAME}"
    groupadd --gid ${JETBRAINS_USER_ID} ${JETBRAINS_USER_NAME}
    useradd --system --uid ${JETBRAINS_USER_ID} --gid ${JETBRAINS_USER_NAME} ${JETBRAINS_USER_NAME}
fi

# create directories if not exist
for item in ${DIRS_TO_CREATE[*]}
do
    if [ -d ${SERVICE_NAME}/${item} ]; then
        echo "directory ${SERVICE_NAME}/${item} already exist"
    else
        mkdir -v ${SERVICE_NAME}/${item}
    fi
done

chmod --recursive 770 ${SERVICE_NAME}
chown --changes --recursive ${JETBRAINS_USER_NAME}:pojo ${SERVICE_NAME}

is_running=`docker top ${SERVICE_NAME} &>/dev/null`
if [ !${is_running} ]; then
    docker stop ${SERVICE_NAME}
    sleep 5
fi

#run docker
docker run -p80:${PORT} \
           -v `pwd`/backups:/${SERVICE_NAME}/backups:rw \
           -v `pwd`/data:/${SERVICE_NAME}/data:rw \
           -v `pwd`/logs:/${SERVICE_NAME}/logs:rw \
           -v `pwd`/conf:/${SERVICE_NAME}/conf:rw \
           -v `pwd`/temp:/${SERVICE_NAME}/temp:rw \
           --name ${SERVICE_NAME} \
           --detach \
           --rm \
           pojo/${SERVICE_NAME}:latest