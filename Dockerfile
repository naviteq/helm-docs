FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build inside the container so the binary matches the target platform.
RUN set -eu; \
    export CGO_ENABLED=0; \
    export GOOS="${TARGETOS}"; \
    export GOARCH="${TARGETARCH}"; \
    if [ -n "${TARGETVARIANT:-}" ]; then \
      export GOARM="${TARGETVARIANT#v}"; \
    fi; \
    go build -o /out/helm-docs ./cmd/helm-docs

FROM alpine:3.23

COPY --from=builder /out/helm-docs /usr/bin/

WORKDIR /helm-docs

ENTRYPOINT ["helm-docs"]
