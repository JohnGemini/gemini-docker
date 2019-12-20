#!/bin/bash

# Boto config
cat <<EOF > /etc/boto.cfg
[Boto]
debug = 0

http_socket_timeout = 5
num_retries = 2
EOF
