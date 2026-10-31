# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Copy dependency files
COPY pyproject.toml .
COPY uv.lock .
COPY README.md .

# Copy the source code
COPY unraid_mcp/ ./unraid_mcp/

COPY LICENSE .

# Pin the interpreter uv provisions. requires-python is >=3.12, so the 3.11
# base image above is never used and uv downloads its own CPython; left
# unpinned it takes the newest, which broke the build on 2026-10-31 when
# CPython 3.15 appeared and httptools 0.7.1 had no cp315 wheel (no cc in
# python:3.11-slim to build one). 3.14 is the version the working image runs.
ENV UV_PYTHON=3.14

# Install dependencies and the package
RUN uv sync --frozen

# Make port UNRAID_MCP_PORT available to the world outside this container
# Defaulting to 6970, but can be overridden by environment variable
EXPOSE 6970

# Define environment variables (defaults, can be overridden at runtime)
ENV UNRAID_MCP_PORT=6970
ENV UNRAID_MCP_HOST="0.0.0.0"
ENV UNRAID_MCP_TRANSPORT="streamable-http"
ENV UNRAID_API_URL=""
ENV UNRAID_API_KEY=""
ENV UNRAID_VERIFY_SSL="true"
ENV UNRAID_MCP_LOG_LEVEL="INFO"

# Run unraid-mcp-server.py when the container launches
CMD ["uv", "run", "unraid-mcp-server"]
