#!/bin/bash
curl -sL https://deb.nodesource.com/setup_13.x | bash -
apt-get install -y nodejs
npm install -g newman@4.5.7 newman-reporter-htmlextra@1.9.2
npm cache clean --force
