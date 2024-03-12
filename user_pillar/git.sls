# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
git:
  personal: &personal
    name: Dale Owens
    email: dale.owens42@gmail.com
  land_title:
    <<: *personal
    repo: git@github.com:buhduh42/land_title.git
    dir: land_title
  kos:
    <<: *personal
    repo: git@github.com:buhduh42/kos.git
    dir: kos

