# Use official Rust image
FROM rust:latest as builder

# Create app directory
WORKDIR /usr/src/app

# Copy source files
COPY . .

# Build release
RUN cargo install --path .

# Final stage
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy binary from builder
COPY --from=builder /usr/local/cargo/bin/your-binary-name /usr/local/bin/your-binary-name

# Set environment variables
ENV RUST_LOG=info
ENV PORT=3000

# Expose port
EXPOSE $PORT

# Run binary
CMD ["your-binary-name"]