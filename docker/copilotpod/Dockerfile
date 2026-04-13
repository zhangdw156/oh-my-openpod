ARG DEVPOD_BASE_IMAGE=devpod
FROM ${DEVPOD_BASE_IMAGE}

RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm && rm -rf /var/lib/apt/lists/*

COPY runtime/copilotpod /opt/runtime/copilotpod
RUN OPENPOD_PREFIX=/opt/copilotpod OPENPOD_BIN_DIR=/usr/local/bin OPENPOD_CONFIG_HOME=/root/.copilot \
      bash /opt/runtime/copilotpod/install-harness.sh

# Sync flavor config into devpod-skel for --user support
RUN cp -a /root/.copilot /opt/devpod-skel/.copilot \
    && chmod -R a+rX /opt/devpod-skel

ENV OPENPOD_COPILOT_VERSION=1.0.24
