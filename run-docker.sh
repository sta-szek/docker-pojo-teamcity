#!/usr/bin/env bash

SERVICE_NAME=teamcity
JETBRAINS_USER_NAME=jetbrains
DIRS_TO_CREATE=(backups conf config data lib logs plugins system temp)
JETBRAINS_USER_ID=2000
PORT=8111

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
    if [ -d ${SERVICE_NAME}/.BuildServer/${item} ]; then
        echo "directory ${SERVICE_NAME}/.BuildServer/${item} already exist"
    else
        mkdir --mode 770 --verbose --parents ${SERVICE_NAME}/.BuildServer/${item}
    fi
done

chmod --recursive 770 ${SERVICE_NAME}
chown --changes --verbose --recursive ${JETBRAINS_USER_NAME}:pojo ${SERVICE_NAME}

is_running=`docker top docker-pojo-${SERVICE_NAME} &>/dev/null`
if [ !${is_running} ]; then
    docker stop docker-pojo-${SERVICE_NAME}
    sleep 5
fi

#run docker
docker run -p80:${PORT} \
           -v `pwd`/${SERVICE_NAME}/.BuildServer/backups:/${SERVICE_NAME}/.BuildServer/backups:rw \
           -v `pwd`/${SERVICE_NAME}/.BuildServer/data:/${SERVICE_NAME}/.BuildServer/data:rw \
           -v `pwd`/${SERVICE_NAME}/.BuildServer/logs:/${SERVICE_NAME}/.BuildServer/logs:rw \
           -v `pwd`/${SERVICE_NAME}/.BuildServer/conf:/${SERVICE_NAME}/.BuildServer/conf:rw \
           -v `pwd`/${SERVICE_NAME}/.BuildServer/temp:/${SERVICE_NAME}/.BuildServer/temp:rw \
           -v `pwd`/${SERVICE_NAME}/.BuildServer/plugins:/${SERVICE_NAME}/.BuildServer/plugins:rw \
           --name docker-pojo-${SERVICE_NAME} \
           --detach \
           --rm \
           pojo/docker-pojo-${SERVICE_NAME}:latest

#docker run -p80:8111 \
#           -v `pwd`/teamcity/.BuildServer/backups:/teamcity/.BuildServer/backups:rw \
#           -v `pwd`/teamcity/.BuildServer/data:/teamcity/.BuildServer/data:rw \
#           -v `pwd`/teamcity/.BuildServer/logs:/teamcity/.BuildServer/logs:rw \
#           -v `pwd`/teamcity/.BuildServer/conf:/teamcity/.BuildServer/conf:rw \
#           -v `pwd`/teamcity/.BuildServer/temp:/teamcity/.BuildServer/temp:rw \
#           -v `pwd`/teamcity/.BuildServer/plugins:/teamcity/.BuildServer/plugins:rw \
#           --name docker-pojo-teamcity \
#           --detach \
#           --rm \
#           pojo/docker-pojo-teamcity:latest