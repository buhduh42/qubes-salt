# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
global:
  user: user
  home: /home/user
  def_dev_template: fedora-38-xfce
  bashrc:
    priority:
      high: 1 #currently, bash_it clobbers .bashrc, so it's the only thing that gets high
      low: 2 #everything else
