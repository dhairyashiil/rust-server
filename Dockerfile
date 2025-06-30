# Use newer Rust version that supports 2024 edition
FROM rust:1.75 as builder

# Install MUSL for static linking
RUN apt-get update && apt-get install -y musl-tools
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app
COPY . .

# Build with MUSL
RUN cargo build --target x86_64-unknown-linux-musl --release

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/rust /usr/local/bin/rust
ENV PORT=3000
EXPOSE $PORT
CMD ["rust"]

# # Use official Rust image
# FROM rust:latest as builder

# # Create app directory
# WORKDIR /usr/src/app

# # Copy source files
# COPY . .

# # Build release
# RUN cargo install --path .

# # Final stage
# FROM debian:bullseye-slim
# RUN apt-get update && apt-get install -y \
#     ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

# # Copy binary from builder
# COPY --from=builder /usr/local/cargo/bin/rust /usr/local/bin/rust

# # Set environment variables
# ENV RUST_LOG=info
# ENV PORT=3000

# # Expose port
# EXPOSE $PORT

# # Run binary
# CMD ["rust"]