# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

download_yq:
  tar.extracted:
    - name: /usr/bin
    - source: {{ pillar['yq']['version'] }}/v{{ pillar['yq']['version'] }}/yq_linux_amd64.tar.gz
    - source_hash: {{ pillar['yq']['sha256'] }}
  cmd.run:
    - name: mv yq_linux_amd64 /usr/bin/yq
    - cwd: /usr/bin
    - onchanges:
      - tar: download_yq
