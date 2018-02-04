#! /bin/sh

if [ -z ${VERSION+x} ]; then
    PROJECT_ID="google-samples"
    IMAGE="hello-app"

    GIT_SHA=`git describe --tags --always --dirty`
    BUILD_DATE=`date -u +"%Y/%m/%d %H:%M:%S"`
    VERSION="Version: ${GIT_SHA}, build at: ${BUILD_DATE}"

    DOCKER_IMAGE="gcr.io/${PROJECT_ID}/${IMAGE}:${GIT_SHA}"

    export GIT_SHA BUILD_DATE VERSION DOCKER_IMAGE
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
    "push")
        gcloud docker -- push ${DOCKER_IMAGE}
        ;;
    "deploy")
        envsubst < manifests/helloweb-deployment.yaml
        ;;
    * )
        echo "Unkown command: ${COMMAND}"
        ;;
esac
