module CADRE_DNSAnomaly;

export {
    redef enum Log::ID += { LOG };

    const nxdomain_threshold: count = 20 &redef;
    const nxdomain_window = 60sec &redef;
    const entropy_threshold: double = 0.08 &redef;
    const entropy_min_label: count = 8 &redef;

    redef enum Notice::Type += {
        DNS_Duplicate_TXID,
        DNS_High_Entropy_Domain,
        DNS_NXDOMAIN_Burst,
    };
}

global seen_txid: table[addr, count] of time &create_expire=60sec;
global nxdomain_counts: table[addr] of count &create_expire=nxdomain_window;
global nxdomain_notified: table[addr] of time &create_expire=nxdomain_window;

function index_of_coincidence(s: string): double
{
    local counts: table[string] of count = table();
    local len = |s|;
    if (len == 0)
        return 1.0;

    local i = 0;
    while (i < len) {
        local c = sub_bytes(s, i, 1);
        counts[c] = (c in counts ? counts[c] + 1 : 1);
        i += 1;
    }

    local sum = 0.0;
    for (c, cnt in counts)
        sum += cnt * (cnt - 1);

    return sum / (len * (len - 1));
}

function check_dga(query: string): bool
{
    if (/^\d/ in query || query == "" || |query| < entropy_min_label)
        return F;

    local q = query;
    local last_idx = |q| - 1;
    if (last_idx >= 0 && sub_bytes(q, last_idx, 1) == ".")
        q = sub_bytes(q, 1, |q|-1);

    local labels = split_string(q, /\./);
    if (|labels| < 2)
        return F;

    local check_label = labels[0];
    if (|check_label| < entropy_min_label)
        return F;

    if (/[^a-zA-Z0-9]/ in check_label)
        return F;

    local ic = index_of_coincidence(check_label);
    return ic < entropy_threshold;
}

event dns_request(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count)
{
    local src = c$id$orig_h;
    local dst = c$id$resp_h;
    local now = network_time();
    local txid = msg$id;

    # Detection 1: Duplicate TXID
    if ([src, txid] in seen_txid) {
        NOTICE([
            $note=DNS_Duplicate_TXID,
            $msg=fmt("Duplicate DNS TXID %d from %s (possible cache poisoning)", txid, src),
            $src=src,
            $dst=dst,
            $conn=c,
            $identifier=cat(src, txid),
            $suppress_for=300sec
        ]);
    }
    seen_txid[src, txid] = now;

    # Detection 2: DGA
    if (check_dga(query)) {
        local ic_val = index_of_coincidence(query);
        NOTICE([
            $note=DNS_High_Entropy_Domain,
            $msg=fmt("High-entropy DNS query from %s: %s (IC=%.4f)", src, query, ic_val),
            $src=src,
            $dst=dst,
            $conn=c,
            $identifier=cat(src, query),
            $suppress_for=3600sec
        ]);
    }
}

event dns_rejected(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count)
{
    local src = c$id$orig_h;
    local now = network_time();

    nxdomain_counts[src] = (src in nxdomain_counts ? nxdomain_counts[src] + 1 : 1);

    if (nxdomain_counts[src] >= nxdomain_threshold) {
        if (src !in nxdomain_notified || nxdomain_notified[src] + 3600sec < now) {
            nxdomain_notified[src] = now;
            NOTICE([
                $note=DNS_NXDOMAIN_Burst,
                $msg=fmt("NXDOMAIN burst from %s: %d queries in %s",
                          src, nxdomain_counts[src], nxdomain_window),
                $src=src,
                $identifier=cat(src, "nxdomain"),
                $suppress_for=3600sec
            ]);
        }
    }
}
