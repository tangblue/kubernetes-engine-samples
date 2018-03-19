FROM golang:1-alpine AS builder
ARG APP_VERSION=unknown
ARG APP_NAME=app
WORKDIR /build
ADD . /build
RUN /bin/sh ./run.sh build

FROM alpine:latest
ARG APP_NAME=app
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /build/${APP_NAME} .
ENV PORT 8080
RUN ln -s ./${APP_NAME} app.lnk
CMD ["./app.lnk"]
