# (C) Copyright IBM Corporation 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:14.04

MAINTAINER Gabriel Mancini <gmancini@br.ibm.com> (@new_biel)

# Install basics
RUN apt-get update \
    && apt-get install -y build-essential git-core wget unzip supervisor

# Install Java.
# add webupd8 repository
RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java7-installer oracle-java7-set-default \
    maven && \
    \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk7-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# Install NodeJS
ENV NODE_VERSION 0.10.29
RUN \
  wget -q  -O - "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  | tar xzf - --strip-components=1 --exclude="README.md" --exclude="LICENSE" \
  --exclude="ChangeLog" -C "/usr/local"

# Install node-gyp
RUN npm install -g node-gyp

# Install nodevisor
RUN git clone https://github.com/TAKEALOT/nodervisor.git /opt/nodervisor \
    && cd /opt/nodervisor \
    && npm install

# Install Mobile First Platform
ENV MFP_VERSION 7.0.0
RUN MFP_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/products/en/MobileFirstPlatform/mobilefirst_cli_installer_$MFP_VERSION.zip" \
    && wget -q $MFP_URL -U UA-IBM-WebSphere-Liberty-Docker -O "/tmp/mobilefirst_cli_installer_$MFP_VERSION.zip" \
    && unzip -q "/tmp/mobilefirst_cli_installer_$MFP_VERSION.zip" -d /tmp/mfp \
    && unzip -q "/tmp/mfp/mobilefirst-cli-installer-$MFP_VERSION/resources/mobilefirst-cli-$MFP_VERSION-install.zip" -d /opt/ibm \
    && rm -rf /tmp/mfp* \
    && cd /opt/ibm/mobilefirst-cli \
    && npm install
ENV PATH /opt/ibm/mobilefirst-cli:$PATH
ENV PATH node_modules/.bin:$PATH
ENV PATH node_modules/bin:$PATH

# Configure mfp
COPY mfp /opt/ibm/mobilefirst-cli/mfp

# Configure supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure WebSphere Liberty
RUN mfp create-server

EXPOSE 10080 3000
#WORKDIR /workspace
VOLUME /workspace

CMD ["/usr/bin/supervisord"]
#CMD ["mfp", "-d", "start"]
