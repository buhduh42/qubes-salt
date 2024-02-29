# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
# because I couldn't get grains.set[val] or any incantation to persist, im going to bake targetting data into the id
# following a taxonomic scheme, currently:
# <type>-<language>-<repo>, may need to extend it further, but this should be adequate for now
# currently, type can be one of app or disp
# haven't settled on a generic scheme yet

user:
  '*-go-*':
    - less
    - git
    - vim
    - bash_it
    - go
    - docker.rootless
  'f38-x-dev':
    - dev_packages
    - docker.install
