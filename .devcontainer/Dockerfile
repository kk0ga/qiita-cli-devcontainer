FROM mcr.microsoft.com/devcontainers/javascript-node:22

WORKDIR /workspace

RUN apt update && apt install -y gh && \
    npm install -g npm@latest @qiita/qiita-cli @github/copilot

