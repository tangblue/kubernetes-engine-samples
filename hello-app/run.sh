#! /bin/bash

app_name="hello-app"
gcr_host="asia.gcr.io"
gip_name="ingress-${app_name}"
rip_name="service-${app_name}"

if [ -z ${APP_VERSION:+x} ]; then
    git_sha=$(git describe --tags --always --dirty)
    APP_VERSION="Version: ${git_sha}, build at: $(date -u +'%Y-%m-%dT%H:%M:%S%z')"
    echo "${APP_VERSION}"
fi

function check_project()
{
    if [ -z ${PROJECT_ID:+x} ]; then
        echo "Error: Unkown project ID. Set project ID by:"
        echo -e "  $ export PROJECT_ID=\"\$(gcloud config get-value project -q)\""
        exit 1
    fi
    if [ -z ${PROJECT_REGION:+x} ]; then
        echo "Error: Unkown region. Set region by:"
        echo -e "  $ export PROJECT_REGION=\"\$(gcloud config get-value compute/region -q)\""
        exit 1
    fi

    echo "Project ID: ${PROJECT_ID}, Image: ${app_name}, Git SHA: ${git_sha}"
    export DOCKER_IMAGE="${gcr_host}/${PROJECT_ID}/${app_name}:${git_sha}"
}

COMMAND=$1
shift 1

case ${COMMAND} in
    "build")
        CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags "-X \"main.version=${APP_VERSION}\"" $@
        ;;

    "docker")
        check_project
        action="${1}"
        shift 1
        case ${action} in
            "build")
                docker build . --build-arg APP_VERSION="${APP_VERSION}" -t ${DOCKER_IMAGE} $@
                ;;
            "run")
                docker run --rm -p 8080:8080 ${DOCKER_IMAGE} $@
                ;;
            "push")
                gcloud docker -- push ${DOCKER_IMAGE}
                ;;
            *)
                echo "Error: Unkown docker args: $@"
                exit 1
                ;;
        esac
        ;;

    "deploy")
        check_project
        action="${1:-describe}"
        case ${action} in
            "apply" | "delete" | "describe")
                action="kubectl ${action} -f -"
                ;;
            "test")
                action="cat -"
                ;;
            *)
                echo "Error: Unkown deploy args: $@"
                exit 1
                ;;
        esac
        GIT_SHA=${git_sha} envsubst < manifests/helloweb-deployment.yaml | ${action}
        ;;

    "ip")
        check_project
        action="${1:-describe}"
        case ${action} in
            "create" | "delete" | "describe")
                case ${2} in
                    "global")
                        gcloud compute addresses ${action} ${gip_name} --global
                        ;;
                    "region")
                        gcloud compute addresses ${action} ${rip_name} --region ${PROJECT_REGION}
                        ;;
                    *)
                        echo "Error: Unkown ip args: $@"
                        exit 1
                        ;;
                esac
                ;;
            *)
                echo "Error: Unkown ip args: $@"
                exit 1
                ;;
        esac
        ;;

    "service")
        check_project
        action="${1:-describe}"
        rip=""
        case ${action} in
            "apply")
                action="kubectl ${action} -f -"
                ;;
            "delete" | "describe")
                rip="NO_IP"
                action="kubectl ${action} -f -"
                ;;
            "test")
                action="cat -"
                ;;
            *)
                echo "Error: Unkown service args: $@"
                exit 1
                ;;
        esac
        if [ -z ${rip:+x} ]; then
            rip="$(gcloud compute addresses describe ${rip_name} --region ${PROJECT_REGION} | grep -Eo '([0-9]*\.){3}[0-9]*')"
            if [ -z ${rip:+x} ]; then
                echo "Error: No region IP. Exiting ..."
                exit 1
            fi
        fi
        REGION_STATIC_IP=${rip} envsubst < manifests/helloweb-service-static-ip.yaml | ${action}
        ;;

    "ingress")
        check_project
        action="${1:-describe}"
        case ${action} in
            "apply" | "delete" | "describe")
                action="kubectl ${action} -f -"
                ;;
            "test")
                action="cat -"
                ;;
            *)
                echo "Error: Unkown service args: $@"
                exit 1
                ;;
        esac
        GLOBAL_STATIC_IP_NAME=${gip_name} envsubst < manifests/helloweb-ingress-static-ip.yaml | ${action}
        ;;

    *)
        echo "Unkown command: ${COMMAND}"
        ;;
esac
