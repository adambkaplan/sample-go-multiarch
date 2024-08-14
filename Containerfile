FROM registry.access.redhat.com/ubi9/go-toolset:1.21.11 as builder

COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

COPY cmd/ cmd/
COPY internal/ internal/

RUN go build -o server cmd/main.go

FROM registry.access.redhat.com/ubi9/ubi-micro:9.4
COPY --from=builder /opt/app-root/src/server /server

USER 65532:65532
ENTRYPOINT [/server]
