#!/usr/bin/env bash
set -ex

apt-get autoremove -y
apt-get autoclean -y

rm -rf \
  /tmp \
  /var/lib/apt/lists/* \
  /var/tmp/*
mkdir -m 1777 /tmp
