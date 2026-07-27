##! cadre-outbound.zeek
##!
##! Detects internal hosts initiating connections to unknown external IPs.
##! Raises a Notice for each unique (src_ip, dst_ip) pair per hour.
##!
##! Concept source: ShowMeThePackets outbound.zeek (detection primitive)
##! All code original — CADRE project.

module CADRE_Outbound;

export {
    redef enum Log::ID += { LOG };

    const internal_subnets: set[subnet] = { 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12 } &redef;
    const known_external: set[addr] = {} &redef;
    const notice_interval = 3600sec &redef;

    redef enum Notice::Type += {
        Outbound_Connection_To_Unknown_External,
    };
}

global notice_suppress: table[addr, addr] of time &create_expire=notice_interval;

event new_connection(c: connection)
{
    local src = c$id$orig_h;
    local dst = c$id$resp_h;

    if (src !in internal_subnets)
        return;
    if (dst in internal_subnets)
        return;
    if (dst in known_external)
        return;

    local now = network_time();
    if ([src, dst] in notice_suppress && notice_suppress[src, dst] + notice_interval > now)
        return;
    notice_suppress[src, dst] = now;

    NOTICE([
        $note=Outbound_Connection_To_Unknown_External,
        $msg=fmt("Internal host %s connected to unknown external %s:%s (%s)",
                  src, dst, c$id$resp_p, c$conn?$service ? c$conn$service : "unknown"),
        $src=src,
        $dst=dst,
        $conn=c,
        $identifier=cat(src, dst),
        $suppress_for=notice_interval
    ]);
}
