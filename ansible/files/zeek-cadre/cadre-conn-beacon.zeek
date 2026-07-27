##! cadre-conn-beacon.zeek
##!
##! Detects connections exceeding configurable byte and duration thresholds.
##! Complements RITA at the Zeek level — catches long connections that
##! aren't FFT-beacon-detectable.
##!
##! Concept source: ShowMeThePackets long_conns.zeek + threshold.zeek concept
##! All code original — CADRE project.

module CADRE_ConnBeacon;

export {
    redef enum Log::ID += { LOG };

    const byte_threshold: table[string] of count = {
        ["http"]    = 10485760,
        ["ssl"]     = 1048576,
        ["dns"]     = 65536,
        ["smb"]     = 52428800,
        ["krb"]     = 1048576,
        ["unknown"] = 10485760,
    } &redef;

    const duration_threshold: table[string] of interval = {
        ["http"]    = 300sec,
        ["ssl"]     = 600sec,
        ["dns"]     = 30sec,
        ["smb"]     = 3600sec,
        ["krb"]     = 60sec,
        ["unknown"] = 600sec,
    } &redef;

    const notice_interval = 3600sec &redef;

    redef enum Notice::Type += {
        Long_Connection_Alert,
    };
}

global notice_suppress: table[addr, addr] of time &create_expire=notice_interval;

event connection_state_remove(c: connection)
{
    if (! c?$conn)
        return;

    local src = c$id$orig_h;
    local dst = c$id$resp_h;
    local svc = c$conn?$service ? c$conn$service : "unknown";
    local dur = c$conn$duration;

    if (dur == 0sec)
        return;

    local orig_bytes = c$conn$orig_bytes;
    local resp_bytes = c$conn$resp_bytes;
    local total_bytes = orig_bytes + resp_bytes;

    local b_thresh = byte_threshold["unknown"];
    local d_thresh = duration_threshold["unknown"];
    if (svc in byte_threshold)
        b_thresh = byte_threshold[svc];
    if (svc in duration_threshold)
        d_thresh = duration_threshold[svc];

    local now = network_time();
    local alerted = F;

    if (total_bytes > b_thresh) {
        if ([src, dst] in notice_suppress && notice_suppress[src, dst] + notice_interval > now)
            return;
        notice_suppress[src, dst] = now;

        NOTICE([
            $note=Long_Connection_Alert,
            $msg=fmt("Long connection %s -> %s:%s (%s): %s bytes over %s (trigger: byte_threshold)",
                      src, dst, c$id$resp_p, svc, total_bytes, dur),
            $src=src,
            $dst=dst,
            $conn=c,
            $identifier=cat(src, dst, svc, "bytes"),
            $suppress_for=notice_interval
        ]);
        alerted = T;
    }

    if (dur > d_thresh) {
        if (alerted)
            return;
        if ([src, dst] in notice_suppress && notice_suppress[src, dst] + notice_interval > now)
            return;
        notice_suppress[src, dst] = now;

        NOTICE([
            $note=Long_Connection_Alert,
            $msg=fmt("Long connection %s -> %s:%s (%s): %s bytes over %s (trigger: duration_threshold)",
                      src, dst, c$id$resp_p, svc, total_bytes, dur),
            $src=src,
            $dst=dst,
            $conn=c,
            $identifier=cat(src, dst, svc, "duration"),
            $suppress_for=notice_interval
        ]);
    }
}
