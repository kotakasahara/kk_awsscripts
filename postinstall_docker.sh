#!/bin/bash

set -exo pipefail

echo "
###################################
# BEGIN: post-install docker
###################################
"

OS=$(. /etc/os-release; echo $NAME)

if [ "${OS}" = "Amazon Linux" ]; then
    yum -y update
    yum search docker
    yum info docker
    yum -y install docker
    chgrp docker $(which docker)
    chmod g+s $(which docker)
    systemctl enable docker.service
    systemctl start docker.service
elif [ "${OS}" = "Ubuntu" ]; then
    apt-get -y update
    apt-get -y install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get -y update
    apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    chgrp docker $(which docker)
    chmod g+s $(which docker)

    ## kk 2024.01.25
    ## install nvidia-container-toolkit
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
	    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
	    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    ##

    systemctl enable docker.service
    systemctl start docker.service

else
        echo "Unsupported OS: ${OS}" && exit 1;
fi

echo "
###################################
# END: post-install docker
###################################
"
