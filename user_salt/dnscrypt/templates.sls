# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set dns_template = pillar['dnscrypt']['template_suffix'] + '-dns' %}

prepare_dns_template:
{% if grains['id'] == dns_template %}
  pkg.installed:
    - pkgs:
{% for p in pillar['dnscrypt']['required_pkgs'] %}
      - {{ p }}
{% endfor %}
  file.directory:
    - name: {{ pillar['dnscrypt']['home'] }}
    - user: {{ pillar['dnscrypt']['user'] }}
    - group: {{ pillar['dnscrypt']['user'] }}
    - dir_mode: 700
    - file_mode: 600
    - require:
      - pkg: prepare_dns_template
      - user: prepare_dns_template
  service.dead:
    - name: dnscrypt-proxy
    - enable: False
    - require:
      - pkg: prepare_dns_template
  user.present:
    - name: {{ pillar['dnscrypt']['user'] }}
    - usergroup: True
    - system: True
    - home: {{ pillar['dnscrypt']['home'] }}
    - shell: '/bin/false'
    - password_lock: True

clean_template:
  pkg.purged:
    - name: systemd-resolved
  file.absent:
    - name: /etc/dnscrypt-proxy
{% else %}
  test.nop: []
{% endif %}


{% if grains['id'] == 'dom0' %}
install_root_template:
  qvm.template_installed:
    - name: {{ pillar['dnscrypt']['root_template'] }}
  # really only update on first install, qubes update should handle it after that
  cmd.run:
    - name: qubes-dom0-update -y {{ pillar['dnscrypt']['root_template'] }}
    - unless:
      - qvm-template list --installed | grep {{ pillar['dnscrypt']['root_template'] }}
    - require:
      - qvm: install_root_template

clone_template:
  qvm.clone:
    - name: {{ dns_template }}
    - source: {{ pillar['dnscrypt']['root_template'] }}
    - unless: 'qvm-template list --installed | grep {{ dns_template }}'
    - require:
      - install_root_template
{% set salt_mgmt_pkg = 'qubes-mgmt-salt-vm-connector' %}
  #{{ salt_mgmt_pkg }} is required for salt to run on any qube correctly,
  #can't even use salt to install this package
  cmd.run:
    - name: qvm-run -u root {{ dns_template }} 'yes | dnf install {{ salt_mgmt_pkg }}'
    - unless: qvm-run -u root {{ dns_template }} 'dnf list installed | grep {{ salt_mgmt_pkg }}'
    - require:
      - qvm: clone_template

{{ dns_template }}-dvm:
  qvm.vm:
    - present:
      - template: {{ dns_template }}
      - label: yellow
    - prefs:
      - template-for-dispvms: True
    - require:
      - clone_template

{{ pillar['dnscrypt']['sys_dns_name'] }}:
  qvm.vm:
    - present:
      - template: {{ dns_template }}-dvm
      - class: DispVM
      - label: red
    - prefs:
      - netvm: {{ pillar['dnscrypt']['sys-dns']['network_vm'] }}
      - provides-network: True
    - require:
      - {{ dns_template }}-dvm

{% else %}
#just do something(nothing) so it don't bitch or blow up
dns_templates_nop:
  test.nop: []
{% endif %} 

