#! /bin/sh

if [ -z ${VERSION+x} ]; then
    GIT_SHA=`git describe --tags --always --dirty`
    BUILD_DATE=`date -u +"%Y/%m/%d %H:%M:%S"`
    VERSION="Version: ${GIT_SHA}, build at: ${BUILD_DATE}"

    export GIT_SHA BUILD_DATE VERSION
fi

COMMAND=$1
shift 1

case ${COMMAND} in
    "build")
        CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-X \"main.version=${VERSION}\"" $@
        ;;
    "docker")
        docker build . --build-arg VERSION="${VERSION}" $@
        ;;
    "deploy")
        envsubst < manifests/helloweb-deployment.yaml | cat - $@
        ;;
    * )
        echo "Unkown command: ${COMMAND}"
        ;;
esac
