# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

git_ssh:
{% if not salt['file.directory_exists'](pillar['global']['home'] + '/.ssh') %}
  file.directory:
    - name: {{ pillar['global']['home'] }}/.ssh
    - user: {{ pillar['global']['user'] }}
    - group: {{ pillar['global']['user'] }}
    - dir_mode: 755
{% else %}
  test.nop: []
{% endif %}

{{ pillar['global']['home'] }}/.ssh/github:
  file.managed:
    - source: salt://files/github
    - user: {{ pillar['global']['user'] }}
    - group: {{ pillar['global']['user'] }}
    - mode: 600
    - require:
      - git_ssh 

git_ssh_config_file:
{% if not salt['file.file_exists'](pillar['global']['home'] + '/.ssh/config') %}
  file.managed:
    - name: {{ pillar['global']['home'] }}/.ssh/config
    - contents: ''
    - user: {{ pillar['global']['user'] }}
    - group: {{ pillar['global']['user'] }}
    - mode: 600
    - require:
      - git_ssh 
{% else %}
  test.nop: []
{% endif %}

git_ssh_known_hosts_file:
{% if not salt['file.file_exists'](pillar['global']['home'] + '/.ssh/known_hosts') %}
  file.managed:
    - name: {{ pillar['global']['home'] }}/.ssh/known_hosts
    - contents: ''
    - user: {{ pillar['global']['user'] }}
    - group: {{ pillar['global']['user'] }}
    - mode: 600
    - require:
      - git_ssh 
{% else %}
  test.nop: []
{% endif %}

git_ssh_known_hosts:
  cmd.run:
    - name: "ssh-keyscan github.com >> {{ pillar['global']['home'] }}/.ssh/known_hosts"
    - runas: {{ pillar['global']['user'] }}
    - unless: "grep github.com {{ pillar['global']['home'] }}/.ssh/known_hosts"
    - require:
      - git_ssh_known_hosts_file 

{% if salt['taxonomy.repo'] %}
{% set repo = salt['taxonomy.repo']() %}
{% else %}
{% set repo = False %}
{% endif %}

#This won't work for multiple users, repos, etc
git_user_name:
  git.config_set:
    - name: user.name
{% if repo %}
    - value: {{ pillar['git'][repo]['name'] }}
{% else %}
    - value: {{ pillar['git']['personal']['name'] }}
{% endif %}
    - user: {{ pillar['global']['user'] }}
    - global: True

git_user_email:
  git.config_set:
    - name: user.email
{% if repo %}
    - value: {{ pillar['git'][repo]['email'] }}
{% else %}
    - value: {{ pillar['git']['personal']['email'] }}
{% endif %}
    - user: {{ pillar['global']['user'] }}
    - global: True

git_ssh_config:
  file.blockreplace:
    - name: {{ pillar['global']['home'] }}/.ssh/config
    - marker_start: "#START -  SSH GIT CONFIG, managed by git salt state, DO NOT EDIT"
    - marker_end: "#END -  SSH GIT CONFIG, managed by git salt state, DO NOT EDIT"
    - content: |-
        Host github.com
          User git
          Hostname github.com
          IdentityFile {{ pillar['global']['home'] }}/.ssh/github
    - append_if_not_found: True
    - require:
      - git_ssh_config_file
      - {{ pillar['global']['home'] }}/.ssh/github

{% if repo %}
{{ pillar['git'][repo]['repo'] }}:
  git.cloned:
    - target: {{ pillar['global']['home'] }}/{{ pillar['git'][repo]['dir'] }}
    - user: {{ pillar['global']['user'] }}
    - require: 
      - git_ssh_config
      - git_user_name
      - git_user_email
      - git_ssh_known_hosts
{% endif %}
