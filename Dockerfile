# Build stage
FROM rust:1.75 as builder

# Install MUSL for static linking
RUN apt-get update && \
    apt-get install -y musl-tools && \
    rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app
COPY . .

# Build release with MUSL
RUN cargo build --target x86_64-unknown-linux-musl --release

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/rust /usr/local/bin/
ENV PORT=3000
EXPOSE $PORT
CMD ["rust"]