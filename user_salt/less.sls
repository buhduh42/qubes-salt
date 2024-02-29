# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

# stupid .bashrc hack to make less case insenstive to match my vim preferences

less_alias:
  file.blockreplace:
    - name:  {{ pillar['global']['home'] }}/.bashrc
    - marker_start: "#START -  LESS ENV, managed by less salt state, DO NOT EDIT"
    - marker_end: "#END -  LESS ENV, managed by less salt state, DO NOT EDIT"
    - content: alias less="less -i" 
    - append_if_not_found: True
    #See bash_it, this will "ensure"(hopefully) that bash_it runs before this such that bash_it doesn't clobber the .bashrc file
    #might need to figure out how to do some .bashrc foo if this gets too unwieldy
    - order: {{  pillar['global']['bashrc']['priority']['low'] }}
