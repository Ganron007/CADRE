module CADRE_Coercion;

export {
    redef enum Log::ID += { LOG };

    const internal_subnets: set[subnet] = { 192.168.77.0/24 } &redef;
    const dc_ips: set[addr] = { 192.168.77.10, 192.168.77.11, 192.168.77.12 } &redef;
    const notice_suppression = 300sec &redef;

    redef enum Notice::Type += {
        Coercion_SpoolSample,
        Coercion_PetitPotam,
        Coercion_DFSCoerce,
        Coercion_ShadowCoerce,
    };
}

global coercion_suppress: table[addr, addr, string] of time &create_expire=notice_suppression;

event dce_rpc_request(c: connection, fid: count, ctx_id: count, opnum: count, stub_len: count)
{
    if (! c?$dce_rpc)
        return;

    local src = c$id$orig_h;
    local dst = c$id$resp_h;
    local rpc_endpoint = c$dce_rpc$endpoint;
    local now = network_time();

    if (src in dc_ips)
        return;

    if (src !in internal_subnets)
        return;

    # spoolss — PrinterBug / SpoolSample (WT#017)
    # opnum 62 = RpcRemoteFindFirstPrinterChangeNotification
    # opnum 65 = RpcRemoteFindFirstPrinterChangeNotificationEx
    # Note: RpcOpenPrinter / RpcClosePrinter are in ignored_operations, but the
    # remote-notification opnums trigger coercion callbacks and are NOT ignored.
    if (rpc_endpoint == "spoolss" && (opnum == 62 || opnum == 65)) {
        if ([src, dst, "spoolss"] !in coercion_suppress || coercion_suppress[src, dst, "spoolss"] + notice_suppression < now) {
            coercion_suppress[src, dst, "spoolss"] = now;
            NOTICE([
                $note=Coercion_SpoolSample,
                $msg=fmt("PrinterBug/SpoolSample coercion from %s to %s (spoolss opnum %d)", src, dst, opnum),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, dst, "spoolss"),
                $suppress_for=notice_suppression
            ]);
        }
    }

    # MS-EFSR — PetitPotam (WT#018)
    # Interface UUID: c681d488-d850-11d0-8c52-00c04fd90f7e
    # opnum 0 = EfsRpcOpenFileRaw, opnum 4 = EfsRpcEncryptFileSrv
    if (rpc_endpoint == "c681d488-d850-11d0-8c52-00c04fd90f7e" && (opnum == 0 || opnum == 4)) {
        if ([src, dst, "efsr"] !in coercion_suppress || coercion_suppress[src, dst, "efsr"] + notice_suppression < now) {
            coercion_suppress[src, dst, "efsr"] = now;
            NOTICE([
                $note=Coercion_PetitPotam,
                $msg=fmt("PetitPotam coercion from %s to %s (efsr opnum %d)", src, dst, opnum),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, dst, "efsr"),
                $suppress_for=notice_suppression
            ]);
        }
    }

    # MS-DFSNM — DFSCoerce (WT#019)
    # Interface UUID: 4fc742e0-4a10-11cf-8273-00aa004ae673
    # opnum 12 = NetrDfsAddStdRoot, opnum 13 = NetrDfsRemoveStdRoot
    if (rpc_endpoint == "4fc742e0-4a10-11cf-8273-00aa004ae673" && (opnum == 12 || opnum == 13)) {
        if ([src, dst, "netdfs"] !in coercion_suppress || coercion_suppress[src, dst, "netdfs"] + notice_suppression < now) {
            coercion_suppress[src, dst, "netdfs"] = now;
            NOTICE([
                $note=Coercion_DFSCoerce,
                $msg=fmt("DFSCoerce coercion from %s to %s (netdfs opnum %d)", src, dst, opnum),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, dst, "netdfs"),
                $suppress_for=notice_suppression
            ]);
        }
    }

    # MS-FSRVP — ShadowCoerce (WT#020)
    # Interface UUID: a8e0653c-2744-4389-a61d-7373df8b2292
    # opnum 8 = IsPathSupported, opnum 9 = IsPathShadowCopied
    if (rpc_endpoint == "a8e0653c-2744-4389-a61d-7373df8b2292" && (opnum == 8 || opnum == 9)) {
        if ([src, dst, "fsrvp"] !in coercion_suppress || coercion_suppress[src, dst, "fsrvp"] + notice_suppression < now) {
            coercion_suppress[src, dst, "fsrvp"] = now;
            NOTICE([
                $note=Coercion_ShadowCoerce,
                $msg=fmt("ShadowCoerce coercion from %s to %s (FileServerVssAgent opnum %d)", src, dst, opnum),
                $src=src,
                $dst=dst,
                $conn=c,
                $identifier=cat(src, dst, "fsrvp"),
                $suppress_for=notice_suppression
            ]);
        }
    }
}
