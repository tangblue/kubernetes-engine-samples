#! /bin/sh

GIT_SHA=`git describe --tags --always --dirty`
BUILD_DATE=`date -u +"%Y/%m/%d %H:%M:%S"`
VERSION="Version: ${GIT_SHA}, build at: ${BUILD_DATE}"

export GIT_SHA BUILD_DATE VERSION

COMMAND=$1
shift 1

case ${COMMAND} in
    "build")
        CGO_ENABLED=0 GOOS=linux go build -ldflags "-linkmode external -extldflags -static -X \"main.version=${VERSION}\"" -a $@
        ;;
    "docker")
        docker build . $@
        ;;
    "deploy")
        envsubst < manifests/helloweb-deployment.yaml | cat - $@
        ;;
    * )
        echo "Unkown command: ${COMMAND}"
        ;;
esac
