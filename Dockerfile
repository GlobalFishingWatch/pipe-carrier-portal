FROM python:3.7

# Configure the working directory
RUN mkdir -p /opt/project
WORKDIR /opt/project


# Download and install google cloud. See the dockerfile at
# https://hub.docker.com/r/google/cloud-sdk/~/dockerfile/
ENV CLOUD_SDK_VERSION="335.0.0"

RUN \
  export CLOUD_SDK_APT_DEPS="curl gcc python-dev python-setuptools apt-transport-https lsb-release openssh-client git" && \
  export CLOUD_SDK_PIP_DEPS="crcmod" && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -qqy $CLOUD_SDK_APT_DEPS && \
  pip pip install -U $CLOUD_SDK_PIP_DEPS && \
  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 && \
  gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image \
  apt-get -y autoremove && \
  rm -rf /var/lib/apt/lists/* \

# Setup a volume for configuration and auth data
VOLUME ["/root/.config"]

# Download and install the cloudssql proxy and the client libraries
RUN \
  wget -q https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy && \
  chmod +x /usr/local/bin/cloud_sql_proxy && \
  apt-get -y install postgresql-client

# Install some commandline utilities for the scripts we run here
RUN apt-get install -y uuid-runtime netcat jshon zip

# Setup local application dependencies
COPY . /opt/project

# install
RUN pip install -r requirements.txt
RUN pip install -e .

# Setup the entrypoint for quickly executing the pipelines
ENTRYPOINT ["scripts/run"]

