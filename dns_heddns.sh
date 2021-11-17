#!/usr/bin/env sh
#
# Author: Robert Socha, 2021
# Add supports for Hurricane Electric Free DNS Hosting Dynamic DNS
# API provided by HE is quite limited (or more secure) -> you can only change registred records
# But this is official API (supported method -> I hope so ;)
#
# You need to set env HEDDNS_ACME_CHALLENGE_DOMAIN to key/password you set via https://dns.he.net
# For example for domain test.example.com this will be HEDDNS_ACME_CHALLENGE_TEST_EXAMPLE_COM
#
# This is not supported (due HE API limitation):
#  https://github.com/acmesh-official/acme.sh/issues/1261
#
# License: public domain
#

dns_heddns_add() {
  fulldomain=$1
  txtvalue=$2
  _info "Using heddns"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  heenv_name=$(echo "${fulldomain}" | sed 's/-/_/g' | sed 's/\./_/g' | _upper_case)
  if [ -z "${heenv_name}" ]; then
    _err "Error..."
    return 1
  fi
  heenv_name="HEDDNS${heenv_name}"
  _debug "Looking for \$${heenv_name} env variable"
  eval "he_password=\${${heenv_name}}"
  if [ -z "${he_password}" ]; then
    _debug "Looking for saved ${heenv_name} value"
    he_password=$(_readaccountconf_mutable "${heenv_name}")
    if [ -z "${he_password}" ]; then
      _err "You need to set ${heenv_name} env with your HE DDNS key/password"
      return 1
    fi
    _debug "Found saved ${heenv_name} value"
  fi
  _debug "Executing DDNS update via https://dyn.dns.he.net/nic/update"
  data="hostname=${fulldomain}&password=${he_password}&txt=${txtvalue}"
  if ! response=$(_post "${data}" "https://dyn.dns.he.net/nic/update"); then
    _err "_post error"
    return 1
  fi
  if _startswith "$response" "badauth"; then
    _err "HE DDNS auth error"
    return 1
  fi
  if _startswith "$response" "nochg" || _startswith "$response" "good"; then
    _saveaccountconf_mutable "${heenv_name}" "${he_password}"
    return 0
  fi
  _err "Error/unknow respone: $response"
  return 1
}

# This is API limitation (we can change rr value, but not remove rrset at all)
dns_heddns_rm() {
  _info "Removing not supported for heddns (this is OK)"
  return 0
}
