#!/bin/bash
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.10.1/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/bin/kubectl
mkdir -p /root/.kube
