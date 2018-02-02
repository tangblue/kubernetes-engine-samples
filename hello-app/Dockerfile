FROM golang:1.8-alpine AS builder
WORKDIR /go/src/hello-app
ARG VERSION
ADD . /go/src/hello-app
RUN ./run.sh build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/hello-app/hello-app .
ENV PORT 8080
CMD ["./hello-app"]
