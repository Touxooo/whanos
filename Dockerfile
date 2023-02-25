FROM jenkins/jenkins:lts
USER root
RUN apt-get update -y \
    && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3.9 \
    python3-pip

RUN pip3 install pyyaml

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  xenial stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update -y
RUN apt-get install -y \
    docker-ce docker-ce-cli containerd.io

COPY jenkins/plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt
COPY jenkins /jenkins
COPY images /images
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /jenkins/config.yml

RUN echo "installing gcloud sdk"
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-419.0.0-linux-x86_64.tar.gz
RUN tar -xvf google-cloud-cli-419.0.0-linux-x86_64.tar.gz
RUN /google-cloud-sdk/install.sh
RUN /google-cloud-sdk/bin/gcloud components install kubectl
