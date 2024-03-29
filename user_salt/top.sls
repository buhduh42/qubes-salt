# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
# because I couldn't get grains.set[val] or any incantation to persist, im going to bake targetting data into the id
# following a taxonomic scheme, currently:
# <type>-<language>-<repo>, may need to extend it further, but this should be adequate for now
# currently, type can be one of app or disp
# haven't settled on a generic scheme yet

base: &base
  - less
  - git
  - vim
  - bash_it

user:
  '*-go-*':
    <<: *base
    - go
    - docker.rootless
  '*-rust-*':
    <<: *base
    - rust
  'f38-x-dev':
    - dev_packages
    - docker.install
  'dom0':
    - dnscrypt.templates
  'f39-m-dns':
    - dnscrypt.templates
  'f39-m-dns-dvm':
    - dnscrypt.disp_vm
