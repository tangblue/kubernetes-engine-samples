#! /bin/sh

SHA=`git describe --tags --always --dirty`
DATE=`date -u +"%Y/%m/%d %H:%M:%S"`
VERSION="Version: ${SHA}, build at: ${DATE}"

docker build . --build-arg VERSION="${VERSION}"

go build -ldflags "-X \"main.version=${VERSION}\"" main.go
