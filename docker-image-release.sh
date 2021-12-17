#!/usr/bin/env bash
#
# script filename
SCRIPT_NAME=$(basename $BASH_SOURCE)
echo ""
echo ""

#
# check that we got two arguments in input
if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Usage ${SCRIPT_NAME} <account> (<tag>)"
    echo ""
    echo " prepare a docker image and push it to the dockerhub repo <account>/panosc-search-scoring"
    echo ""
    echo " arguments:"
    echo " - account = account on docker hub"
    echo " - tag     = git tag we would like to use to create the image"
    echo "             if not specified it uses the latest tag available on the main branch"
    echo ""
    exit 1
fi

# extract input argument
account=$1
#env=$2
gitTag=$2

# code repository and branch
gitRepo=https://github.com/panosc-eu/panosc-search-scoring.git
branch=master

# docker repository
dockerRepo=${account}/panosc-search-scoring

# retrieve latest git commit tag
if [ "-${gitTag}-" == "--" ]; then 
    gitTag=$(git describe --tags --abbrev=0)
fi


# docker image tag
dockerTag="${gitTag}"
dockerImage="${dockerRepo}:${dockerTag}"

#
# gives some feedback to the user
echo "Account          : ${account}"
echo "Environment      : ${env}"
echo "Git commit tag   : ${gitTag}"
echo "Docker image tag : ${dockerTag}"
echo "Docker image     : ${dockerImage}"
echo ""

#
# create docker image
# if it is already present, remove old image
if [[ "$(docker images -q ${dockerImage} 2> /dev/null)" != "" ]]; then
    echo "Image already present. Removing it and recreating it"
    docker rmi ${dockerImage}
    echo ""
fi
echo "Creating conf file with version"
sed "s/<VERSION>/${dockerTag}/" docker/config_template.json > ./docker/pss_config.json
echo "Creating image"
docker build -t ${dockerImage} -f ./docker/Dockerfile .
echo "Removing config file"
##rm -f ./docker/config.json
echo ""

# push image on docker hub repository
docker push ${dockerImage}
echo ""
echo "Done"
echo ""

