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
