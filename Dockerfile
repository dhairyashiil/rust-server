# Build stage - using newer Rust version
FROM rust:1.77 as builder

# Install MUSL for static linking
RUN apt-get update && \
    apt-get install -y musl-tools && \
    rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

# Copy only what's needed for dependencies
COPY Cargo.toml Cargo.lock .
RUN mkdir -p src && \
    echo 'fn main() {}' > src/main.rs && \
    cargo build --target x86_64-unknown-linux-musl --release && \
    rm -rf target/x86_64-unknown-linux-musl/release/deps/rust*

# Now copy real source
COPY src ./src
RUN cargo build --target x86_64-unknown-linux-musl --release

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/rust /usr/local/bin/
ENV PORT=3000
EXPOSE $PORT
CMD ["rust"]