##! cadre-quic-c2.zeek
##!
##! Detects long-lived UDP/443 connections as a QUIC proxy indicator.
##! QUIC event handlers not available in Zeek 8.0; uses conn.log heuristics.
##! Only ~0.14% of legitimate QUIC connections exceed 1 hour (FOR572 research).
##!
##! Concept source: FOR572 "C2 over QUIC" guide (Faan Rossouw)
##! All code original — CADRE project.

module CADRE_QUICC2;

export {
    redef enum Log::ID += { LOG };

    const quic_port: port = 443/udp &redef;
    const duration_threshold: interval = 3600sec &redef;
    const byte_threshold: count = 10485760 &redef;  # 10 MB
    const internal_subnets: set[subnet] = { 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12 } &redef;

    redef enum Notice::Type += {
        Long_UDP_Session,
        Large_UDP_Transfer,
    };
}

global dur_notice_suppress: table[addr, addr] of time &create_expire=86400sec;
global byte_notice_suppress: table[addr, addr] of time &create_expire=86400sec;

event connection_state_remove(c: connection)
{
    if (! c?$conn)
        return;

    local src = c$id$orig_h;
    local dst = c$id$resp_h;

    if (src !in internal_subnets)
        return;

    local svc = c$conn?$service ? c$conn$service : "";
    local dur = c$conn$duration;

    if (dur == 0sec)
        return;

    # Check for UDP on port 443 (QUIC) or long UDP sessions
    if (c$id$resp_p == quic_port || svc == "quic") {
        local total_bytes = c$conn$orig_bytes + c$conn$resp_bytes;
        local now = network_time();

        # Detection 1: Duration alert — QUIC connections persisting > 1 hour
        if (dur >= duration_threshold) {
            if ([src, dst] !in dur_notice_suppress ||
                dur_notice_suppress[src, dst] + 86400sec < now) {
                dur_notice_suppress[src, dst] = now;
                NOTICE([
                    $note=Long_UDP_Session,
                    $msg=fmt("Long UDP session on port 443: %s -> %s:%s for %s (%s bytes)",
                              src, dst, c$id$resp_p, dur, total_bytes),
                    $src=src,
                    $dst=dst,
                    $conn=c,
                    $identifier=cat(src, dst, "dur"),
                    $suppress_for=86400sec
                ]);
            }
        }

        # Detection 2: Byte threshold — >10 MB transferred over UDP/443
        if (total_bytes >= byte_threshold) {
            if ([src, dst] !in byte_notice_suppress ||
                byte_notice_suppress[src, dst] + 86400sec < now) {
                byte_notice_suppress[src, dst] = now;
                NOTICE([
                    $note=Large_UDP_Transfer,
                    $msg=fmt("Large UDP transfer on port 443: %s -> %s:%s (%s bytes over %s)",
                              src, dst, c$id$resp_p, total_bytes, dur),
                    $src=src,
                    $dst=dst,
                    $conn=c,
                    $identifier=cat(src, dst, "bytes"),
                    $suppress_for=86400sec
                ]);
            }
        }
    }
}
