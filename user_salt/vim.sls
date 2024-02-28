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

vim_known_hosts:
{% if not salt['file.contains_regex']('^github.com .+$') %}
  cmd.run:
    - name: 'ssh-keyscan github.com >> {{ pillar['global_home'] }}/.ssh/known_hosts'
    - cwd: {{ pillar['global_home'] }}/.vim
    - runas: {{ pillar['global_user'] }}
    - require:
      - git_ssh_known_hosts
{% else %}
  test.nop: []
{% endif %}

configure_vim:
{%- if salt['pkg.version'](vim_pkg) %}
  file.blockreplace:
    - name:  {{ pillar['global_home'] }}/.bashrc
    - marker_start: "#START -  VIM ENV, managed by vim salt state, DO NOT EDIT"
    - marker_end: "#END -  VIM ENV, managed by vim salt state, DO NOT EDIT"
    - content: alias vi="{{ vim_alias }}" 
    - append_if_not_found: True
  git.latest:
    - name: {{ pillar['vim']['repo'] }} 
    - target: {{ pillar['global_home'] }}/.vim
    - branch: {{ pillar['vim']['branch'] }}
    - user: {{ pillar['global_user'] }}
    - require:
      - git_ssh_config
      - vim_known_hosts
  cmd.run:
    - name: {{ pillar['global_home'] }}/.vim/pullSubtrees.sh
    - cwd: {{ pillar['global_home'] }}/.vim
    - runas: {{ pillar['global_user'] }}
    - require:
      - git: configure_vim
      - git_user_name
      - git_user_email
{% else %}
  test.nop: []
{%- endif %}
