# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
rootless_docker_install:
  cmd.run:
    - name: dockerd-rootless-setuptool.sh --skip-iptables install
    - runas: {{ pillar['global']['user'] }}
    - cwd: {{ pillar['global']['home'] }}
    - unless: test -e {{ pillar['global']['home'] }}/.config/systemd/user/docker.service
  file.blockreplace:
    - name:  {{ pillar['global']['home'] }}/.bashrc
    - marker_start: "#START -  DOCKER ENV, managed by docker salt state, DO NOT EDIT"
    - marker_end: "#END -  DOCKER ENV, managed by docker salt state, DO NOT EDIT"
    - content: "export DOCKER_HOST=unix:///run/user/1000/docker.sock"
    - append_if_not_found: True
    #See bash_it, this will "ensure"(hopefully) that bash_it runs before this such that bash_it doesn't clobber the .bashrc file
    #might need to figure out how to do some .bashrc foo if this gets too unwieldy
    - order: {{ pillar['global']['bashrc']['priority']['low'] }}

rootless_docker:
  cmd.run:
    - name: loginctl enable-linger {{ pillar['global']['user'] }}
    - require:
      - rootless_docker_install

