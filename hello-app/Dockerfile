FROM golang:1.8-alpine
ARG VERSION
ADD . /go/src/hello-app
RUN go install -ldflags "-X \"main.version=${VERSION}\"" hello-app

FROM alpine:latest
COPY --from=0 /go/bin/hello-app .
ENV PORT 8080
CMD ["./hello-app"]
