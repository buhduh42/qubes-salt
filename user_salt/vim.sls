# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
{% if grains.get('os') == 'Fedora' %}
  {% set pkg_key = 'fedora' %}
{% else %}
  ##just the default, only using fedora for now
  {% set pkg_key = 'default' %}
{% endif %}
{% set vim_pkg = pillar['dev_packages'][pkg_key]['vim']['pkg'] %}
{% set vim_alias = pillar['dev_packages'][pkg_key]['vim']['alias'] %}

include:
  - git
  - bash_it

configure_vim:
{%- if salt['pkg.version'](vim_pkg) %}
  file.blockreplace:
    - name:  {{ pillar['global']['home'] }}/.bashrc
    - marker_start: "#START -  VIM ENV, managed by vim salt state, DO NOT EDIT"
    - marker_end: "#END -  VIM ENV, managed by vim salt state, DO NOT EDIT"
    - content: alias vi="{{ vim_alias }}" 
    - append_if_not_found: True
    #See bash_it, this will "ensure"(hopefully) that bash_it runs before this such that bash_it doesn't clobber the .bashrc file
    #might need to figure out how to do some .bashrc foo if this gets too unwieldy
    - order: {{  pillar['global']['bashrc']['priority']['low'] }}
  git.cloned:
    - name: {{ pillar['vim']['repo'] }} 
    - target: {{ pillar['global']['home'] }}/.vim
    - branch: {{ pillar['vim']['branch'] }}
    - user: {{ pillar['global']['user'] }}
    - require:
      - git_ssh_config
      - git_ssh_known_hosts
  cmd.run:
    - name: {{ pillar['global']['home'] }}/.vim/pullSubtrees.sh
    - cwd: {{ pillar['global']['home'] }}/.vim
    - runas: {{ pillar['global']['user'] }}
    - require:
      - git: configure_vim
      - git_user_name
      - git_user_email
{% else %}
  test.nop: []
{%- endif %}
