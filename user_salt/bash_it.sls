# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

install_bash_it:
  git.cloned:
    - name: https://github.com/Bash-it/bash-it.git
    - target: {{ pillar['global']['home'] }}/bash-it
    - user: {{ pillar['global']['user'] }}
  cmd.run:
    - name: yes | {{ pillar['global']['home'] }}/bash-it/install.sh && touch {{ pillar['global']['home'] }}/bash-it/installed
    - runas: {{ pillar['global']['user'] }}
    - cwd: {{ pillar['global']['home'] }}
    - unless: {{ salt['file.file_exists'](pillar['global']['home'] + '/bash-it/installed') }}
    #Clobbers .bashrc file, any file that modifies .bashrc needs to have a higher order than this(lower priority)
    - order: {{ pillar['global']['bashrc']['priority']['high'] }}
    - require:
      - git: install_bash_it
