##! cadre-tls-fingerprint.zeek
##!
##! Captures TLS handshake info from ssl.log and raises Notice on
##! suspicious cipher suites.
##!
##! Concept source: FOR572 JA3/JA4+ hunting notes
##! All code original — CADRE project.

module CADRE_TLSFingerprint;

export {
    redef enum Log::ID += { LOG };

    const suspicious_ciphers: set[string] = {
        # Anonymous key exchange — no authentication
        "TLS_DH_anon_WITH_AES_128_GCM_SHA256",
        "TLS_DH_anon_WITH_AES_128_CBC_SHA",
        "TLS_ECDH_anon_WITH_AES_128_CBC_SHA",
        "TLS_DH_anon_WITH_AES_256_CBC_SHA",

        # Export-grade — deliberately weakened (CVE-2015-0204)
        "TLS_RSA_EXPORT_WITH_RC4_40_MD5",
        "TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5",
        "TLS_RSA_EXPORT_WITH_DES40_CBC_SHA",

        # RC4 — broken (CVE-2013-2566, CVE-2015-2808)
        "TLS_RSA_WITH_RC4_128_MD5",
        "TLS_RSA_WITH_RC4_128_SHA",

        # CCM_8 suites — unusual in standard TLS (IoT/malware)
        "TLS_AES_128_CCM_8_SHA256",
        "TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8",

        # SSLv2 fallback — ancient, attacker-triggered
        "TLS_RSA_WITH_NULL_MD5",
        "TLS_RSA_WITH_NULL_SHA",
    } &redef;

    redef enum Notice::Type += {
        TLS_Suspicious_Cipher,
    };
}

event ssl_established(c: connection)
{
    if (! c?$ssl)
        return;

    local src = c$id$orig_h;
    local dst = c$id$resp_h;
    local cipher = c$ssl$cipher;

    if (cipher in suspicious_ciphers) {
        NOTICE([
            $note=TLS_Suspicious_Cipher,
            $msg=fmt("Suspicious TLS cipher %s from %s to %s (SNI: %s)",
                      cipher, src, dst, c$ssl?$server_name ? c$ssl$server_name : "unknown"),
            $src=src,
            $dst=dst,
            $conn=c,
            $identifier=cat(src, dst, cipher),
            $suppress_for=86400sec
        ]);
    }
}
