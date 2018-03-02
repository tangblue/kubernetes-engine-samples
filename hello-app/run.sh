#! /bin/bash

if [ -z ${VERSION+x} ]; then
    GCR_HOST="asia.gcr.io"
    IMAGE="hello-app"

    GIT_SHA=`git describe --tags --always --dirty`
    BUILD_DATE=`date -u +"%Y/%m/%d %H:%M:%S"`
    VERSION="Version: ${GIT_SHA}, build at: ${BUILD_DATE}"

    export GIT_SHA BUILD_DATE VERSION
fi

function check_project_ID()
{
    if [ -z ${PROJECT_ID+x} ]; then
        echo "Error: Unkown project ID. Set project ID by:"
        echo -e "\texport PROJECT_ID=\"\$(gcloud config get-value project -q)\""
        exit 1
    fi

    echo "Project ID: ${PROJECT_ID}, Image: ${IMAGE}, Git SHA: ${GIT_SHA}"
    export DOCKER_IMAGE="${GCR_HOST}/${PROJECT_ID}/${IMAGE}:${GIT_SHA}"
}

COMMAND=$1
shift 1

case ${COMMAND} in
    "build")
        echo "${VERSION}"
        CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags "-X \"main.version=${VERSION}\"" $@
        ;;
    "docker")
        check_project_ID
        ACTION="${1}"
        shift 1
        case ${ACTION} in
            "build")
                docker build . --build-arg VERSION="${VERSION}" -t ${DOCKER_IMAGE} $@
                ;;
            "run")
                docker run --rm -p 8080:8080 ${DOCKER_IMAGE} $@
                ;;
            "push")
                gcloud docker -- push ${DOCKER_IMAGE}
                ;;
            "*")
                echo "Error: Unkown docker args: $@"
                exit 1
                ;;
        esac
        ;;
    "deploy")
        check_project_ID
        ACTION="${1:-test}"
        if [ ${ACTION} == "apply" ]; then
            ACTION="kubectl apply -f -"
        elif [ ${ACTION} == "delete" ]; then
            ACTION="kubectl delete -f -"
        elif [ ${ACTION} == "test" ]; then
            ACTION="cat -"
        else
            echo "Error: Unkown deploy args: $@"
            exit 1
        fi
        envsubst < manifests/helloweb-deployment.yaml | ${ACTION}
        ;;
    * )
        echo "Unkown command: ${COMMAND}"
        ;;
esac
