# This builds the base images that we can use for development at Blueshift.
# Tensorflow 2.0 by default, but we can override the image when we call docker.
#
# docker build -t gcr.io/blueshift-playground/blueshift:cpu -f- . <Dockerfile
#
# docker push gcr.io/blueshift-playground/blueshift:cpu
#
# docker build --build-arg BASE_IMAGE=tensorflow/tensorflow:2.0.0-gpu-py3 -t gcr.io/blueshift-playground/blueshift:gpu -f- . <Dockerfile
#
# docker push gcr.io/blueshift-playground/blueshift:gpu
#
#  https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/assembler.py

ARG BASE_IMAGE=tensorflow/tensorflow:2.0.0-py3

FROM $BASE_IMAGE

# TODO figure out how to wire this in.... should work now that it's after the
# FROM. Try wiring it in below.
ARG NODE_VERSION=13

LABEL maintainer="samritchie@google.com"

# Install git so that users can declare git dependencies, and python3 plus
# python3-virtualenv so we can generate an isolated Python environment inside
# the container.
#
# TODO we COULD use venv, the new python3 business. No urgency at all to change
# this as this is hidden from the user now.
RUN apt-get update && apt-get install \
  -y --no-install-recommends git python3 python3-virtualenv

COPY scripts/bashrc /etc/bash.bashrc

# This follows the style laid out here to set up a fresh, activated virtualenv
# inside the image:
# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m virtualenv --python=/usr/bin/python3 $VIRTUAL_ENV

# There may be a better way - but this allows a user to install packages in the
# virtualenv once it launches.
RUN chmod -R 757 $VIRTUAL_ENV && mkdir /.cache && chmod -R 757 /.cache

# This is equivalent to activating the env.
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
