# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
dev_packages:
  fedora: &default
    vim: 
      alias: gvim -v
      pkg: vim-X11
    clipboard: 
      alias: xclip
      pkg: xclip
    git-subtree:
      alias: ''
      pkg: git-subtree
    tmux:
      alias: ''
      pkg: tmux
  default:
    <<: *default
