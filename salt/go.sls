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
    - require: {{ pillar['go']['base_dir'] }}
