# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% if grains.get('os') == 'Fedora' %}
  {% set pkg_key = 'fedora' %}
{% else %}
  ##just the default, only using fedora for now
  {% set pkg_key = 'default' %}
{% endif %}

development_packages:
  pkg.latest:
    - pkgs: 
{% for pkg, data in pillar['dev_packages'].get(pkg_key).items() %}
      - {{ data['pkg'] }}
{% endfor -%}
