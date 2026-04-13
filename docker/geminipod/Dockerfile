ARG DEVPOD_BASE_IMAGE=devpod
ARG NODE_IMAGE=node:20-bookworm-slim
FROM ${NODE_IMAGE} AS node-runtime

FROM ${DEVPOD_BASE_IMAGE} AS geminipod-base

COPY --from=node-runtime /usr/local/ /usr/local/

COPY runtime/geminipod /opt/runtime/geminipod
RUN OPENPOD_PREFIX=/opt/geminipod OPENPOD_BIN_DIR=/usr/local/bin OPENPOD_CONFIG_HOME=/root/.gemini \
      bash /opt/runtime/geminipod/install-harness.sh

# Sync flavor config into devpod-skel for --user support
RUN cp -a /root/.gemini /opt/devpod-skel/.gemini \
    && chmod -R a+rX /opt/devpod-skel

ENV OPENPOD_GEMINI_VERSION=0.37.1
