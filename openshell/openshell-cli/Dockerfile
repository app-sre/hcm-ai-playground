FROM debian:bookworm-slim

USER root

# Install dependencies and OpenShell CLI
RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -LsSf https://raw.githubusercontent.com/NVIDIA/OpenShell/main/install.sh | sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1001 openshell

USER 1001

ENTRYPOINT ["openshell"]
CMD ["--help"]
