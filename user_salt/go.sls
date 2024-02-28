# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{{ pillar['go']['base_dir'] }}:
  file.directory:
    - user:  {{ pillar['global_user'] }}
    - group:  {{ pillar['global_user'] }}
    - dir_mode: 755
    - file_mode: 644

{{ pillar['go']['base_dir'] }}/{{ pillar['go']['version'] }}:
  archive.extracted:
    - source: {{ pillar['go']['src'] }}
    - source_hash: {{ pillar['go']['hash'] }}
    - require:
      - {{ pillar['go']['base_dir'] }}

goroot:
  file.symlink:
    - name: {{ pillar['go']['base_dir'] }}/goroot
    - target: {{ pillar['go']['base_dir'] }}/{{ pillar['go']['version'] }}/go
    - force: True
    - require:
      - {{ pillar['go']['base_dir'] }}/{{ pillar['go']['version'] }}

gopath:
  file.directory:
    - name: {{ pillar['global_home'] }}/gopath
    - user: {{ pillar['global_user'] }}
    - group: {{ pillar['global_user'] }}
    - dir_mode: 755
    - file_mode: 644

go_env:
  file.blockreplace:
    - name: {{ pillar['global_home'] }}/.bashrc
    - marker_start: "#START -  GO ENV, managed by go salt state, DO NOT EDIT"
    - marker_end: "#END -  GO ENV, managed by go salt state, DO NOT EDIT"
    - content: |-
        export GOPATH="{{ pillar['global_home'] }}/gopath"
        export GOROOT="{{ pillar['go']['base_dir'] }}/goroot"
        export PATH="${PATH}:${GOROOT}/bin"
    - append_if_not_found: True
    - require:
      - goroot
      - gopath
