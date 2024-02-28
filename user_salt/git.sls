# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% grains['id'] | regex_search

git_ssh:
{% if not salt['file.directory_exists'](pillar['global_home'] + '/.ssh') %}
  file.directory:
    - name: {{ pillar['global_home'] }}/.ssh
    - user: {{ pillar['global_user'] }}
    - group: {{ pillar['global_user'] }}
    - dir_mode: 755
{% else %}
  test.nop: []
{% endif %}

{{ pillar['global_home'] }}/.ssh/github:
  file.managed:
    - source: salt://files/github
    - user: {{ pillar['global_user'] }}
    - group: {{ pillar['global_user'] }}
    - mode: 600
    - require:
      - git_ssh 

git_ssh_config_file:
{% if not salt['file.file_exists'](pillar['global_home'] + '/.ssh/config') %}
  file.managed:
    - name: {{ pillar['global_home'] }}/.ssh/config
    - contents: ''
    - user: {{ pillar['global_user'] }}
    - group: {{ pillar['global_user'] }}
    - mode: 600
    - require:
      - git_ssh 
{% else %}
  test.nop: []
{% endif %}

git_ssh_known_hosts:
{% if not salt['file.file_exists'](pillar['global_home'] + '/.ssh/known_hosts') %}
  file.managed:
    - name: {{ pillar['global_home'] }}/.ssh/known_hosts
    - contents: ''
    - user: {{ pillar['global_user'] }}
    - group: {{ pillar['global_user'] }}
    - mode: 600
    - require:
      - git_ssh 
{% else %}
  test.nop: []
{% endif %}

#This won't work for multiple users, repos, etc
git_user_name:
  git.config_set:
    - name: user.name
    - value: {{ pillar['git']['personal']['name'] }}
    - user: {{ pillar['global_user'] }}
    - global: True

git_user_email:
  git.config_set:
    - name: user.email
    - value: {{ pillar['git']['personal']['email'] }}
    - user: {{ pillar['global_user'] }}
    - global: True

git_ssh_config:
  file.blockreplace:
    - name: {{ pillar['global_home'] }}/.ssh/config
    - marker_start: "#START -  SSH GIT CONFIG, managed by git salt state, DO NOT EDIT"
    - marker_end: "#END -  SSH GIT CONFIG, managed by git salt state, DO NOT EDIT"
    - content: |-
        Host github.com
          User git
          Hostname github.com
          IdentityFile {{ pillar['global_home'] }}/.ssh/github
    - append_if_not_found: True
    - require:
      - git_ssh_config_file
      - {{ pillar['global_home'] }}/.ssh/github
