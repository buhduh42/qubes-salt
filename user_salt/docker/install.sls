# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
dnf-plugins-core:
  pkg.installed: []

configure_docker_pkgs:
  #pkgrepo.managed didn't seem to be correctly adding the repo, just manually do it with dnf in fedora
  cmd.run:
    - name: 'dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo'
    - unless: 'test -e /etc/yum.repos.d/docker-ce.repo'
    - require:
      - dnf-plugins-core
  pkg.latest:
    - pkgs:
      - docker-ce 
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
      - fuse-overlayfs
    - require:
      - cmd: configure_docker_pkgs

disable_root_docker_service:
  service.dead:
    - name: docker.service
    - enable: False
    - require:
      - configure_docker_pkgs

disable_root_docker_socket:
  service.dead:
    - name: docker.socket
    - enable: False
    - require:
      - configure_docker_pkgs
