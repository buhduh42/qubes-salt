# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

#wget https://github.com/mikefarah/yq/releases/download/v4.42.1/yq_linux_amd64.tar.gz -O - | tar xz && sudo mv yq_linux_amd64 /usr/bin/yq

{% set version = '4.42.1' %}

yq:
  version: {{ version }}
  sha256: 99fc7fd4874daaceb8a718264afccc8f777413fa655c7e16063cfa87d39efe3a
  base_url: https://github.com/mikefarah/yq/releases/download
