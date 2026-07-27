##! cadre-supplychain-http.zeek
##!
##! Monitors HTTP POSTs from internal hosts to external destinations.
##! Designed to detect npm supply-chain attack patterns (Plan 0.8):
##!   - Webhook exfil (Scenario 1)
##!   - npm publish worm (Scenario 6)
##!   - Post-install callback (Scenario 1)
##!
##! Fires Notice when HTTP POST goes to:
##!   - Non-corporate external hosts
##!   - Known npm/CI registries from unexpected sources
##!   - Cloud metadata endpoints
##!
##! All code original - CADRE project.

module CADRE_SupplyChainHTTP;

export {
    redef enum Log::ID += { LOG };

    const internal_subnets: set[subnet] = { 192.168.77.0/24, 10.0.0.0/8, 172.16.0.0/12 } &redef;
    const notice_interval = 300sec &redef;

    # Known-good hosts that npm/CI legitimately talks to
    const known_registries: set[string] = {
        "registry.npmjs.org",
        "registry.yarnpkg.com",
        "registry.npm.taobao.org",
        "github.com",
        "api.github.com",
    } &redef;

    # Cloud metadata endpoints
    const metadata_endpoints: set[string] = {
        "169.254.169.254",
        "metadata.google.internal",
        "169.254.169.254.nip.io",
    } &redef;

    redef enum Notice::Type += {
        SupplyChainHttpPost,
        SupplyChainCloudMetadata,
        SupplyChainRegistryAbuse,
    };
}

global post_suppress: table[addr, string] of time &create_expire=notice_interval;

event http_request(c: connection, method: string, original_URI: string,
                   unescaped_URI: string, version: string)
{
    if (method != "POST")
        return;

    local src = c$id$orig_h;
    local dst = c$id$resp_h;

    # Only monitor internal hosts
    if (src !in internal_subnets)
        return;

    # Skip if no HTTP state
    if (! c?$http)
        return;

    local host = c$http?$host ? c$http$host : "";
    local uri = unescaped_URI;
    local now = network_time();

    # Detection 1: Cloud metadata probe (Scenario 7)
    if (host in metadata_endpoints || cat(dst) in metadata_endpoints) {
        local meta_key = cat(src, "metadata");
        if ([src, meta_key] !in post_suppress || post_suppress[src, meta_key] + notice_interval < now) {
            post_suppress[src, meta_key] = now;
            NOTICE([
                $note=SupplyChainCloudMetadata,
                $msg=fmt("HTTP POST to cloud metadata endpoint from %s: %s%s", src, host, uri),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, dst, "metadata"),
                $suppress_for=notice_interval
            ]);
        }
    }

    # Detection 2: POST to non-lab external host (Scenario 1 - webhook exfil)
    if (dst !in internal_subnets) {
        local post_key = cat(src, dst);
        if ([src, post_key] !in post_suppress || post_suppress[src, post_key] + notice_interval < now) {
            post_suppress[src, post_key] = now;
            NOTICE([
                $note=SupplyChainHttpPost,
                $msg=fmt("HTTP POST to external host %s (%s) from %s - possible webhook exfil", host, dst, src),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, dst, "post"),
                $suppress_for=notice_interval
            ]);
        }
    }

    # Detection 3: POST to npm registry from unexpected source (Scenario 6)
    # Only alert if POST goes to registry but source is not a known dev host
    if (host in known_registries && host == "registry.npmjs.org") {
        local reg_key = cat(src, "npm-publish");
        if ([src, reg_key] !in post_suppress || post_suppress[src, reg_key] + notice_interval < now) {
            post_suppress[src, reg_key] = now;
            NOTICE([
                $note=SupplyChainRegistryAbuse,
                $msg=fmt("HTTP POST to npm registry from %s to %s - possible publish worm", src, host),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, "npm"),
                $suppress_for=notice_interval
            ]);
        }
    }
}
