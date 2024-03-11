# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

#This is a funky state, basically don't change certain directories to user: dnscrypt when creating
#the home for qubes_bind_dirs
make_rw_pre_bind_dirs:
  file.directory:
    - name: |-
        /rw/bind-dirs{{ (pillar['dnscrypt']['home']).split('/')[:pillar['dnscrypt']['rw_user_path_idx']+1]|join('/') }}
    - makedirs: True

/rw/bind-dirs{{ pillar['dnscrypt']['cache_dir'] }}:
  file.directory:
    - makedirs: True
    - user: {{ pillar['dnscrypt']['user'] }}
    - group: {{ pillar['dnscrypt']['user'] }}
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - user
      - group
      - mode
    - require:
      - make_rw_pre_bind_dirs

/rw/config/qubes-bind-dirs/50_dnscrypt.conf:
  file.managed:
    - makedirs: True
    - contents:
      - binds+=('{{ pillar['dnscrypt']['home'] }}')
      - binds+=('{{ pillar['dnscrypt']['cache_dir'] }}')

dnscrypt_rc_local:
  file.blockreplace:
    - name: /rw/config/rc.local
    - append_if_not_found: True
    - marker_start: "#START DNSCRYPT - managed by dnscrypt.disp_vm salt state, DO NOT EDIT"
    - marker_end: "#END DNSCRYPT - managed by dnscrypt.disp_vm salt state, DO NOT EDIT"
    - content: |-
        nft='/usr/sbin/nft'

        #redirect dns requests to local host
        ${nft} flush chain ip qubes dnat-dns
        ${nft} 'add rule ip qubes dnat-dns ip daddr 10.139.1.1 udp dport 53 dnat to 127.0.0.1:53'
        ${nft} 'add rule ip qubes dnat-dns ip daddr 10.139.1.1 tcp dport 53 dnat to 127.0.0.1:53'
        ${nft} 'add rule ip qubes dnat-dns ip daddr 10.139.1.2 udp dport 53 dnat to 127.0.0.1:53'
        ${nft} 'add rule ip qubes dnat-dns ip daddr 10.139.1.2 tcp dport 53 dnat to 127.0.0.1:53'

        #allow downstream qubes to connect over 53
        ${nft} 'add rule ip qubes custom-input iifname "vif*" tcp dport 53 accept'
        ${nft} 'add rule ip qubes custom-input iifname "vif*" udp dport 53 accept'

        echo 'nameserver 127.0.0.1' > /etc/resolv.conf
        # https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-linux
        # https://wiki.archlinux.org/title/Dnscrypt-proxy#Enable_EDNS0
        echo 'options edns0' >> /etc/resolv.conf

        # allow redirects to localhost
        /usr/sbin/sysctl -w net.ipv4.conf.all.route_localnet=1

        ln -s /rw/dnscrypt-proxy /etc/dnscrypt-proxy

        ##wait until connectivity...., probably a smarter way to do this
        while ! $(curl -I -s https://google.com 2>&1 >/dev/null); do
          sleep 1
        done

        /usr/bin/systemctl start dnscrypt-proxy.service

        #bootstrapping dnscrypt requires dns requests for initial resolver resolution on non localhost
        #wait until dnscrypt-proxy is running before disabling non local dns requests
        sleep 2
        count=0
        max=10
        while ! test "$(systemctl is-active dnscrypt-proxy.service)" = "active"; do
          count=$((count+1))
          #just break out and hope for the best?
          if test ${count} -ge ${max}; then
            break
          fi
          sleep .5
        done

        #drop alternate host dns requests
        ${nft} 'insert rule ip qubes postrouting ip daddr != 127.0.0.1 tcp dport 53 counter drop'
        ${nft} 'insert rule ip qubes postrouting ip daddr != 127.0.0.1 udp dport 53 counter drop'

/rw/dnscrypt-proxy:
  file.directory:
    - user: {{ pillar['dnscrypt']['user'] }}
    - group: {{ pillar['dnscrypt']['user'] }}
    - dir_mode: 700
    - file_mode: 600

{% for f in pillar['dnscrypt']['etc_files'] %}
{{ '/rw/dnscrypt-proxy/' + f }}:
  file.managed:
    - source: salt://dnscrypt/files/etc/{{ f }}
    - user: {{ pillar['dnscrypt']['user'] }}
    - group: {{ pillar['dnscrypt']['user'] }}
    - mode: 600
    - require:
      - /rw/dnscrypt-proxy
{% endfor %}

/rw/dnscrypt-proxy/dnscrypt-proxy.toml:
  file.managed:
    - source: salt://dnscrypt/files/etc/dnscrypt-proxy.toml.jinja
    - user: {{ pillar['dnscrypt']['user'] }}
    - group: {{ pillar['dnscrypt']['user'] }}
    - mode: 600
    - template: jinja
    - context:
        listen_addresses: {{ pillar['dnscrypt']['listen_addresses']|json }}
        user: {{ pillar['dnscrypt']['user'] }}
        captive_portals: /etc/dnscrypt-proxy/captive-portals.txt
        blocked_names: /etc/dnscrypt-proxy/blocked-names.txt
        blocked_ips: /etc/dnscrypt-proxy/blocked-ips.txt
        resolvers: {{ pillar['dnscrypt']['resolvers']|yaml }}
