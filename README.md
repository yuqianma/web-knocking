# web-knocking

[Port knocking](https://en.wikipedia.org/wiki/Port_knocking) is an interesting method to secure a server.

Here I use iptables and a web page to implement "port knocking".

This work's initial purpose is to limit the public access to an openwrt router. So the implement is specific to openwrt.

However, the mechanism has no significant difference on any machine with iptables.

> **Attention**
>
> "Port knocking" is deprecated as an authorization way.
>
> Please use other technology such as https if you do provide public services.

## Openwrt

#### Step 1
Open http://YOURIP/cgi-bin/luci/admin/network/firewall/custom

Add:
``` shell
# Three ports should NOT be duplicated or ordered.
/root/create-knocking-rules.sh 1111 3333 2222

# optional
ipset -exist add passed {Permanent IP} timeout 0
```

#### Step 2
Revise /etc/config/firewall
``` shell
config include
	option path '/etc/firewall.user'
	# add following lines, or it has no effect after restart
	option type 'script'
	option reload '1' 
```

Then open the web page (config by queries)

for example:

https://yuqianma.github.io/web-knocking/index.html?hostname=foo.com&webport=443
