# Example Dockerfile to build the worker image.
#
# The README includes GCP Cloud Build commands using buildpacks that are
# recommended as an easier option than this Dockerfile.
#
# To build this image, run the following from the repository root:
#
# docker build -t <image name> -f worker.Dockerfile .
FROM golang:1.25 AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o bin/worker ./cmd/worker

FROM debian:bookworm-slim
# Install root certificates for HTTPS.
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/bin/worker /worker
ENTRYPOINT ["/worker"]
