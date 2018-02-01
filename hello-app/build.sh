#! /bin/sh

GIT_SHA=`git describe --tags --always --dirty`
BUILD_DATE=`date -u +"%Y/%m/%d %H:%M:%S"`
VERSION="Version: ${GIT_SHA}, build at: ${BUILD_DATE}"

export GIT_SHA BUILD_DATE VERSION

case $1 in
    "build")
        go build -ldflags "-X \"main.version=${VERSION}\"" main.go
        ;;
    "docker")
        docker build . --build-arg VERSION="${VERSION}"
        ;;
    "deploy")
        envsubst < manifests/helloweb-deployment.yaml | cat -
        ;;
    * )
        echo "Unkown command: ${1}"
        ;;
esac
