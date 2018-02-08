FROM golang:1.8-alpine AS builder
ARG VERSION
WORKDIR /go/src/hello-app
ADD . /go/src/hello-app
RUN /bin/sh ./run.sh build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/hello-app/hello-app .
ENV PORT 8080
CMD ["./hello-app"]
