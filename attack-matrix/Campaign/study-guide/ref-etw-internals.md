# ETW Internals — Architecture, Hooking, Tampering, Detection

> **Source:** https://kernullist.github.io/kernullist-blog/posts/etw-internals-deep-dive/
> **Date:** 2026-06-03
> **MITRE:** T1562.006 (Impair Defenses: Indicator Blocking)
> **CADRE mapping:** Campaign_suggestions.md #30, Detection Engineering

---

## What It Is

Deep-dive on Event Tracing for Windows (ETW) — the telemetry fabric behind Elastic Defend, Sysmon, EDRs, WPR, and forensic tools. Covers how ETW providers register, how attackers hook/tamper with ETW to blind defenders, and detection strategies.

## Why CADRE Needs This

- Elastic Defend depends on ETW for process, file, network, and registry telemetry
- Sysmon uses ETW for many of its event types
- If an attacker patches ETW, our telemetry goes dark — all detection rules become useless
- Understanding ETW internals helps us detect when attackers try to disable telemetry

## Key Concepts (to fill when article is read in detail)

### ETW Architecture
- Provider registration
- Consumer/session model
- Controller API

### Attack Techniques
- EtwEventWrite patching
- NtTraceEvent hooks
- Provider unloading
- Process-level ETW tampering

### Detection Strategies
- Cross-view detection (compare ETW telemetry with kernel callbacks)
- ETW provider integrity monitoring
- Detecting patching of ETW functions

## CADRE Application

- Build cadre-* rules that detect ETW tampering
- Validate Elastic Defend telemetry integrity
- Reference for understanding detection blind spots
- Complements Impacket-IoCs (plan1.7) — if ETW is blinded, protocol-level detection still works at network layer

---

*Last updated: 2026-06-09*
