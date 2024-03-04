# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set home = '/run/dnscrypt-proxy' %}
{% set cache_dir = home + '/cache' %}
dnscrypt:
  root_template: fedora-39-minimal
  template_suffix: f39-m
  user: dnscrypt
  home: {{ home }}
  cache_dir: {{ cache_dir }}
  required_pkgs:
    - dnscrypt-proxy
    - qubes-core-agent-networking
  #when setting proper permissions on /rw/bind-dirs for home,
  #only set this index in home to the correct user off root
  #evaluates to: /rw/bind-dirs/run, since /run has index 1 in home
  rw_user_path_idx: 1
  etc_files:
    - blocked-ips.txt
    - blocked-names.txt
    - captive-portals.txt
  listen_addresses:
    - 127.0.0.1:53
  sys_dns_name: sys-dns-test

  resolvers:
    'sources.public-resolvers':
      urls:
        - https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md
        - https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md
      #sha256 sum of the above, both should be same
      src_hash: ddaadb81015d33c12d0e612d0ed1e1e4db033926ef53628481ec45909512854f
      cache_file: {{ cache_dir }}/public-resolvers.md
      minisign_key: RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3
      refresh_delay: 72
      prefix: ''
    'sources.relays':
      urls:
        - https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md
        - https://download.dnscrypt.info/resolvers-list/v3/relays.md
      #sha256 sum of the above, both should be same
      src_hash: d44363c44e35de2032f930ba7d3f63b280c2ba77e81617d5d95105bd0304fc6a
      cache_file: {{ cache_dir }}/relays.md
      minisign_key: RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3
      refresh_delay: 72
      prefix: ''

  sys-dns:
    network_vm: sys-firewall
