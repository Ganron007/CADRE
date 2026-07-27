##! cadre-tcp-profile.zeek
##!
##! Detects connections between 192.168.77.x and other internal subnets.
##! Useful for spotting lateral movement to/from the lab's main segment.
##!
##! All code original - CADRE project.

module CADRE_TCPProfile;

export {
    redef enum Log::ID += { LOG };

    const lab_subnet: subnet = 192.168.77.0/24 &redef;
    const other_subnets: set[subnet] = { 10.0.0.0/8, 172.16.0.0/12 } &redef;
    const notice_interval = 3600sec &redef;

    redef enum Notice::Type += {
        Cross_Subnet_Connection,
    };
}

event new_connection(c: connection)
{
    local src = c$id$orig_h;
    local dst = c$id$resp_h;

    local src_in_lab = src in lab_subnet;
    local dst_in_lab = dst in lab_subnet;

    # Both in lab subnet — skip
    if (src_in_lab && dst_in_lab)
        return;

    # Neither in lab subnet — skip
    if (! src_in_lab && ! dst_in_lab)
        return;

    # One in lab subnet, one in other internal subnet — alert
    local other_in = F;
    if (src_in_lab && dst in other_subnets)
        other_in = T;
    if (dst_in_lab && src in other_subnets)
        other_in = T;

    if (other_in) {
        NOTICE([
            $note=Cross_Subnet_Connection,
            $msg=fmt("Cross-subnet connection: %s -> %s (%s)",
                      src, dst, c$conn?$service ? c$conn$service : "unknown"),
            $src=src,
            $dst=dst,
            $conn=c,
            $identifier=cat(src, dst),
            $suppress_for=notice_interval
        ]);
    }
}
