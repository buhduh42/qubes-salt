# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

install_rust:
  file.managed:
    - name: {{ pillar['global']['home'] }}/rustup.sh
    - user: {{ pillar['global']['user'] }}
    - group: {{ pillar['global']['user'] }}
    - mode: 755
    - source: salt://rust/files/rustup.sh
    - unless: su -c 'which rust' - {{ pillar['global']['user'] }}
  cmd.run:
    - name: {{ pillar['global']['home'] }}/rustup.sh -y
    - runas: {{ pillar['global']['user'] }}
    - cwd: {{ pillar['global']['home'] }}
    - require:
      - file: install_rust

rust_remove_install_script:
  cmd.run:
    - name: rm {{ pillar['global']['home'] }}/rustup.sh
    - runas: {{ pillar['global']['user'] }}
    - cwd: {{ pillar['global']['home'] }}
    - require:
      - cmd: install_rust
