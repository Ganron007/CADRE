# CADRE — Attack Study Guide

Deep-dive reference for every CADRE attack. Read these to understand **how** and **why** each technique works, not just how to run it.

## Files

| File | Phase | Attacks |
|------|-------|---------|
| `phase0-reconnaissance.md` | Recon | Port scan, anonymous enum, Kerberos user enum |
| `phase1-initial-access.md` | Phase 1 | WT003 AS-REP Roast |
| `phase2-credential-harvesting.md` | Phase 2 | WT002 Kerberoast (AES, via ACE#18) |
| `phase3-execution.md` | Phase 3 | WT041 xp_cmdshell, WT043 IMPERSONATE, GodPotato |
| `branch35-credential-theft.md` | Branch 3.5 | 3.5F LSASS/SAM, 3.5A Winlogon, 3.5B Scheduled Task, 3.5D File Detonation, 3.5J WMI Persistence |
| `phase4-discovery.md` | Phase 4 | BloodHound, MSSQLHound |
| `phase5-lateral-movement.md` | Phase 5 | WT004 Unconstrained Delegation, WT017 PrinterBug, WT021 NTLM Relay |
| `phase6-privilege-escalation.md` | Phase 6 | WT009 DCSync |
| `phase7-forest-trust.md` | Phase 7 | WT010-012 SID History, Golden Ticket |
| `phase8-cross-forest.md` | Phase 8 | WT033-039 SCCM, cross-forest Kerberoast |
| `branchA-acl-abuse.md` | Branch A | WT013-016, WT023-027, ACE abuse |
| `branchB-adcs.md` | Branch B | WT050-062 ESC1-14 |
| `branchC-sccm.md` | Branch C | WT034-039 SCCM escalation |
| `branchD-linux.md` | Branch D | WT044-048 Linux pivot |

**Status:** Files created after each phase is tested and verified. Phase 3+ and branches created as we complete them.

## Per-Attack Template

Each attack entry follows this structure:

```
## WT### — Attack Name

### What It Does
[How it works at the protocol/system level. Why it's possible. What the attacker gains.]

### Step-by-Step
[Exact commands. What each step does. Expected output.]

### Detection
[Event IDs, network signatures, log patterns. What defenders look for.]

### Real-World Usage
[APT groups, notable incidents, red team tooling.]

### Sources
[MITRE, SpecterOps, blog posts, tool docs.]
```

## How to Use

1. Start with `phase0-reconnaissance.md` — understand the lab environment
2. Follow the campaign phases in order: Phase 1 → 2 → 3 → ...
3. Each file builds on the previous — later phases assume you've earned credentials from earlier ones
4. Cross-reference with `../CAMPAIGNS-METADATA.md` for playbook/ACE details
5. Cross-reference with `../../01-walkthroughs/` for step-by-step execution guides

## Related

- `../CAMPAIGNS-METADATA.md` — structured per-attack data (playbook refs, ACE#s, telemetry)
- `../CAMPAIGNS.md` — campaign narrative and attack flow
- `../../10-cert-map/` — per-certification learning paths (CRTP, CRTE, CAPE, etc.)
