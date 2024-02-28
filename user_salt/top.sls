# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
# because I couldn't get grains.set[val] or any incantation to persist, im going to bake targetting data into the id
# following a taxonomic scheme, currently:
# <language>-<repo>, may need to extend it further, but this should be adequate for now

user:
 'go-*':
    - git
    - go
    - vim

