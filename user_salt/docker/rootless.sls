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
  file.managed:
    - name: {{ pillar['global']['home'] }}/.config/systemd/user/docker.service
    - user: {{ pillar['global']['user'] }}
    - group: {{ pillar['global']['user'] }}
    - mode: 644
    - makedirs: True
    - contents: |-
        [Unit]
        Description=Docker Application Container Engine (Rootless)
        Documentation=https://docs.docker.com/go/rootless/

        [Service]
        Environment=PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin
        ExecStart=/usr/bin/dockerd-rootless.sh  --iptables=false
        ExecReload=/bin/kill -s HUP $MAINPID
        TimeoutSec=0
        RestartSec=2
        Restart=always
        StartLimitBurst=3
        StartLimitInterval=60s
        LimitNOFILE=infinity
        LimitNPROC=infinity
        LimitCORE=infinity
        TasksMax=infinity
        Delegate=yes
        Type=notify
        NotifyAccess=all
        KillMode=mixed

        [Install]
        WantedBy=default.target
    - require:
      - rootless_docker_install
  cmd.run:
    - name: loginctl enable-linger {{ pillar['global']['user'] }}
    - require:
      - rootless_docker_install

{{ pillar['global']['home'] }}/.config/systemd/user/default.target.wants/docker.service:
  file.symlink:
    - target: {{ pillar['global']['home'] }}/.config/systemd/user/docker.service
    - inherit_user_and_group: True
    - makedirs: True
    - require:
      - rootless_docker
