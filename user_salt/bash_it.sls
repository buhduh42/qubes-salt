# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

install_bash_it:
  git.cloned:
    - name: https://github.com/Bash-it/bash-it.git
    - target: {{ pillar['global_home'] }}/bash-it
    - user: {{ pillar['global_user'] }}
  cmd.run:
    - name: yes | {{ pillar['global_home'] }}/bash-it/install.sh && touch {{ pillar['global_home'] }}/bash-it/installed
    - runas: {{ pillar['global_user'] }}
    - cwd: {{ pillar['global_home'] }}
    - unless: {{ salt['file.file_exists'](pillar['global_home'] + '/bash-it/installed') }}
    - require:
      - git: install_bash_it
