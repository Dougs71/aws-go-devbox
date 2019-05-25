#!/bin/bash

# Sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# Install python for ansible
sudo yum install -y python
