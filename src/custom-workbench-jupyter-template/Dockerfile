# Build the base image from the local workbench-jupyter Dockerfile for testing.
# Switch back to the pinned remote digest once the Node 24 change is merged and
# a new image has been published to the artifact registry.
FROM workbench-jupyter-base

# Install jupyter extensions
RUN --mount=type=bind,from=jupyter-extension-builder,source=/dist,target=/tmp/extensions \
    /tmp/extensions/setup.sh
