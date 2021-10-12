# acme-sh-dnsapi-heddns
Hurricane Electric Free DNS acme.sh DDNS api module

Installation
```
wget --show-progress -qO ~/.acme.sh/dnsapi/dns_heddns.sh https://github.com/rjsocha/acme-sh-dnsapi-heddns/raw/main/dns_heddns.sh
```

Usage:
```
HEDDNS_ACME_CHALLENGE_TEST_EXAMPLE_COM=secret ~/.acme.sh/acme.sh --issue --dns dns_heddns -d test.example.com
```
