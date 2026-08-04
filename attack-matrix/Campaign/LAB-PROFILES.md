# CADRE Lab Profiles — Modular VM Sets

> **Purpose:** Run the main CADRE lab in **modules** so you can work the campaign (or sister projects) without always powering the full stack.
> **Campaign source of truth:** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) · **Phase entry:** [`Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Runbooks/CAMPAIGNS-RUNBOOK-README.md)
> **Next campaign action:** Phase **0.5** on **ws01** — [`Runbooks/CAMPAIGNS-RUNBOOK-H.md`](Runbooks/CAMPAIGNS-RUNBOOK-H.md)
>
> **Rule:** Profiles are *operational* (what to leave **Running** vs **Suspended/Off**). They do not change playbooks or topology. Worst case: close sister VMs and run the full CADRE set + Kali — that still works.

---

## 1. Inventory (what exists)

RAM figures below match `lab/providers/vmware/Vagrantfile` for Vagrant-managed VMs. **ws01** is the integrated Win11 / MDE P2 workstation (imported; dual-role CADRE beachhead + Eva7ion target) — not in the core Vagrantfile list.

| VM | IP | RAM (alloc) | Role |
|----|-----|-------------|------|
| **dc01** | `.10` | 4 GB | `cadre.local` root DC · CA · DNS |
| **dc02** | `.11` | 4 GB | `child.cadre.local` DC · Phase 1 AS-REP target · **ws01 DNS** |
| **dc03** | `.12` | 4 GB | `range.local` root DC · forest trust peer |
| **mbr01** | `.22` | 4 GB | MSSQL / IIS · Phase 3 exec · unconstrained del. |
| **mbr02** | `.23` | 8 GB | SCCM / WSUS · Branch C / Phase 8 |
| **linux01** | `.40` | 4 GB | AD-joined Linux · Branch D |
| **provisioning** | `.60` | 4 GB | Ansible runner; campaign docs often call this **Kali** |
| **ws01** | `.62` | ~4 GB* | Win11 · MDE P2 · **Phase 0.5 beachhead** · Eva7ion target |
| **elk** | `.50` | 12 GB | Elastic / Kibana / Fleet *(extension)* |
| **vr** | `.51` | 4 GB | Velociraptor *(extension)* |
| **monitor** | `.55` | 8 GB | Zeek / Suricata / Arkime *(extension)* |

\* `docs/internal/plan01-telemetry-catalog/plan01-upgrades/win11-workstation.md` plans **4 GB**. If MDE + browser feel tight, bump to **6–8 GB** in VMware settings — do not drop below 4 GB for Phase 0.5 / evasion work.

**Attacker station:** Campaign v3 marks the attacker as `192.168.77.60` (provisioning / Kali tools). If you run a **separate personal Kali** on the same `vmnet2` lab net, count its RAM on top of the table. Profiles below say **Kali** = wherever you run Impacket / NetExec / payload hosting (usually `.60`).

**Rough totals (allocated):**

| Set | Approx RAM |
|-----|------------|
| Core 7 (no ws01, no extensions) | ~32 GB |
| Core 7 + **ws01** | ~36 GB |
| + elk + monitor + vr | ~56–60 GB |
| + separate Kali (if not `.60`) | + your Kali size |

Host overhead and sister VMs (RevEng Remnux/Flare, etc.) are **extra**.

---

## 2. How to use profiles

1. Pick the profile for your **current** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) phase (table in §4).
2. **Start / resume** only the **Required** VMs.
3. Leave everything else **Suspended** (preferred — keeps state) or **Powered off**.
4. When you need detection / purple-team checks, add the **Optional (telemetry)** row for that profile.
5. If something AD-related flakes (trust, DNS, auth), escalate one step toward a fuller profile — or use **P-FULL**.

**Do not destroy** VMs just to free RAM. Suspend/stop is enough.

**ws01 caution:** Never run `04-vulnerabilities.yml` against ws01 (MDE / Defender stay on). Deploy/verify via `17-ws01-deploy.yml` only. Fleet policy = `CADRE-WS01` (no Elastic Defend).

**Plan 1.1 assume-breach:** `17-ws01-deploy.yml` adds `CHILD\analyst_t1` to local **Administrators** on ws01 (config lane). Attack identity remains `analyst_t1`, never vagrant.

**Optional linux beachhead:** join provisioning to `child.cadre.local` only with  
`CADRE_PROVISIONING_DOMAIN_JOIN=1` + `ansible-playbook …/18-provisioning-domain-join.yml` (default off; keeps Vagrant SSH; **no** monitoring on `.60`).

**Routing:** [`WS01-ROUTING.md`](../04-automation/linux/lib/WS01-ROUTING.md) — ws01 primary · kali alt · `stage_mbr01` exception-only.

---

## 3. Profile catalog

Legend: **R** = required · **O** = optional · **—** = leave suspended/off · **T** = telemetry add-on (elk / monitor / vr)

### Quick reference — machines per profile

| Profile | Power on (required) | Optional / telemetry | Approx RAM | Use for |
|---------|---------------------|----------------------|------------|---------|
| **P-BEACH** | Kali, **ws01**, **dc02** | dc01 | ~12–16 GB | Phase 0.5 / Eva7ion on ws01 |
| **P-CHILD** | Kali, **dc01**, **dc02**, **mbr01*** | ws01; T: elk/monitor/vr | ~16–24 GB | Phase 0–3 child spine |
| **P-CREDS** | Kali, dc01, dc02, **mbr01** | ws01; T: elk/monitor | ~16–20 GB | Phase 3.5 creds |
| **P-DELEG** | Kali, dc01, dc02, **mbr01** | ws01; T: elk/monitor | ~16–20 GB | Phase 4–6 |
| **P-FOREST** | Kali, dc01, dc02, **dc03**, mbr01, **mbr02** | ws01; T: elk/monitor | ~28–32 GB | Phase 7–8 / Branch C |
| **P-LINUX** | Kali, **dc01**, **mbr01**, **linux01** | dc02; T: elk/monitor | ~16–20 GB | Branch D |
| **P-PURPLE** | **elk**, **monitor** + offense subset | vr; **ws01** if MDE logs | subset +12–24 GB | Detection / plan1.7 |
| **P-EVADE** | **ws01**, **dc02** | dc01; Eva7ion ops hosts | ~8–12 GB | MDE / evasion only |
| **P-FULL** | All core 7 + **ws01** + elk + monitor + vr (+ Kali if separate) | — | ~56–60 GB | Worst case / full day |

\* **mbr01** required from Phase 2–3 onward in P-CHILD; Phase 0–1 can omit it. Minimal Phase 1 AS-REP: Kali + dc02 (+ ws01).

Detail per profile below.

### P-BEACH — Phase 0.5 initial access (start here)

**Use for:** Phishing / file exec on **ws01** → C2 as `child.cadre.local\analyst_t1` · Runbook H  
**Also:** Eva7ion MDE / evasion tests that target ws01 only (same host).

| VM | State | Why |
|----|-------|-----|
| Kali / provisioning `.60` | **R** | Payload host, tools, C2 listener |
| **ws01** `.62` | **R** | Beachhead / MDE target |
| **dc02** `.11` | **R** | Domain join DNS + Kerberos for child domain |
| dc01 `.10` | **O** | Root DNS / forest; add if join or name resolution fails |
| Everything else | — | |

**Approx:** ~12–16 GB (+ Kali if separate)  
**Skip for now:** mbr01/02, dc03, linux01, elk, monitor, vr

---

### P-CHILD — Child-domain spine (Phase 0 recon → Phase 3)

**Use for:** Unauth recon, AS-REP, ACE#18 → Kerberoast, BloodHound light, SQL → GodPotato on mbr01  
**After beachhead:** Keep **ws01** if you still operate from the C2 session; suspend it if you switched fully to Kali-side attacks with stolen creds.

| VM | State | Why |
|----|-------|-----|
| Kali / provisioning | **R** | Attack station |
| **dc02** | **R** | child.cadre.local KDC / LDAP |
| **dc01** | **R*** | Forest root / DNS / some LDAP paths; *keep up once you leave pure child-only tests* |
| **mbr01** | **R** from Phase 2–3 | MSSQL / IIS / unconstrained del. |
| **ws01** | **R** for 0.5→1 from beachhead; else **O** | |
| dc03, mbr02, linux01 | — | |
| elk / monitor / vr | **T** | Only when validating detection |

**Approx:** ~16–24 GB without telemetry · +12–24 GB if elk+monitor(+vr)

\* For a **minimal** Phase 1-only AS-REP against dc02, you can try **dc02 + Kali (+ ws01)** only; bring **dc01** back before multi-domain / BH / ACE paths that touch root.

---

### P-CREDS — Phase 3.5 credential access

**Use for:** LSASS / SAM / DPAPI / lsassy / DonPAPI / mimikatz on mbr01 (post-SYSTEM)

| VM | State |
|----|-------|
| Kali / provisioning | **R** |
| dc01, dc02 | **R** |
| mbr01 | **R** |
| ws01 | **O** (if still in chain) |
| elk / monitor | **T** strongly recommended |
| dc03, mbr02, linux01, vr | — unless VR hunt |

**Approx:** ~16–20 GB (+ telemetry)

---

### P-DELEG — Phase 4–6 (discovery → coercion → DCSync)

**Use for:** Full BH, coercion, delegation, DCSync on child → DA child

| VM | State |
|----|-------|
| Kali / provisioning | **R** |
| dc01, dc02 | **R** |
| mbr01 | **R** (unconstrained / coerce paths) |
| ws01 | **O** |
| elk / monitor | **T** for SID:1000050 / DCSync rules |
| dc03, mbr02, linux01 | — |

**Approx:** ~16–20 GB (+ telemetry)

---

### P-FOREST — Phase 7–8 + Branch C (cross-forest / SCCM)

**Use for:** SID history → EA, cross-forest to `range.local`, SCCM on mbr02

| VM | State |
|----|-------|
| Kali / provisioning | **R** |
| dc01, dc02, **dc03** | **R** |
| mbr01 | **R** (often still in path) |
| **mbr02** | **R** for Branch C / SCCM / Phase 8 SCCM bits |
| ws01 | **O** |
| linux01 | — unless linked-server work |
| elk / monitor | **T** |

**Approx:** ~28–32 GB (+ telemetry) — heaviest offense-only profile before extensions

---

### P-LINUX — Branch D

**Use for:** MSSQL linked server → linux01 → Podman / SSSD / keytab

| VM | State |
|----|-------|
| Kali / provisioning | **R** |
| dc01 (linux01 domain) | **R** |
| dc02 | **O/R** if auth path still child-side |
| mbr01 | **R** (SQL link origin) |
| **linux01** | **R** |
| mbr02, dc03, ws01 | — |
| elk / monitor | **T** |

**Approx:** ~16–20 GB

---

### P-PURPLE — Detection / plan1.7 / NSM validation

**Use for:** Elastic rules, Suricata/Zeek fires, Fleet, VR hunts — after or between offense phases

| VM | State |
|----|-------|
| **elk** | **R** for SIEM / Fleet |
| **monitor** | **R** for Zeek/Suricata/Arkime |
| **vr** | **O** for Velociraptor |
| Offense subset | **R** = whatever profile you are validating (often P-CHILD or P-BEACH) |
| ws01 | **R** if validating MDE + `CADRE-WS01` host logs |

**Approx:** offense subset + **~12–24 GB** extensions

---

### P-EVADE — Eva7ion / MDE on ws01 (sister track)

**Use for:** Evasion / MDE P2 work without running the AD kill-chain

| VM | State |
|----|-------|
| **ws01** | **R** |
| **dc02** | **R** (domain-joined; DNS) |
| dc01 | **O** |
| Kali / Remnux / Flare (Eva7ion operator hosts) | as needed for that project |
| Rest of CADRE | — |

**Approx:** ~8–12 GB CADRE-side (+ Eva7ion operator VMs)

---

### P-FULL — Everything you can afford

**Use for:** Full campaign day, cross-forest + telemetry + beachhead, or when modular profiles fight you.

| Include | Notes |
|---------|--------|
| All 7 core + **ws01** + elk + monitor + vr | ~56–60 GB allocated |
| + Kali if distinct from `.60` | Close RevEng / other sister VMs first |

This is the **supported worst case** you already run — profiles exist to avoid needing it every session.

---

## 4. Phase → profile cheat sheet (`CAMPAIGNS_v3`)

| Phase / stream | Runbook | Profile | Machines (power on) | Escalate / add |
|----------------|---------|---------|---------------------|----------------|
| **0** Recon (unauth) | RUNBOOK-0 | P-CHILD | Kali, dc01, dc02 (+ scan targets) | Hosts you are scanning |
| **0.5** Initial access **ws01** | **RUNBOOK-H** | **P-BEACH** | **Kali, ws01, dc02** | + dc01 if DNS/join odd |
| **1** AS-REP | RUNBOOK-1 | P-BEACH → P-CHILD | Kali, ws01, dc02 → + dc01 | Drop ws01 if fully on Kali |
| **2** Kerberoast / ACE#18 | RUNBOOK-2 | P-CHILD | Kali, dc01, dc02, **mbr01** | ws01 optional |
| **3** SQL → SYSTEM | RUNBOOK-3 | P-CHILD | Kali, dc01, dc02, **mbr01** | |
| **3.5** Creds | RUNBOOK-3.5 | P-CREDS | Kali, dc01, dc02, **mbr01** | + elk/monitor (T) |
| **4** BloodHound | RUNBOOK-4 | P-DELEG | Kali, dc01, dc02, mbr01 | |
| **5** Coercion / del. | RUNBOOK-5 | P-DELEG | Kali, dc01, dc02, mbr01 | + elk/monitor (T) |
| **6** DCSync | RUNBOOK-6 | P-DELEG | Kali, dc01, dc02, mbr01 | + elk/monitor (T) |
| **7** SID hist / EA | RUNBOOK-7 | P-FOREST | Kali, dc01, dc02, **dc03**, mbr01 | |
| **8** Cross-forest / SCCM | RUNBOOK-8 | P-FOREST | Kali, dc01, dc02, dc03, mbr01, **mbr02** | + elk/monitor (T) |
| Branch A / B | branch-a / b | P-DELEG | Kali, dc01, dc02, mbr01 | dc01 required for ADCS |
| Branch C | branch-c | P-FOREST | Kali, dc01–03, mbr01, **mbr02** | |
| Branch D | branch-d | P-LINUX | Kali, **dc01**, **mbr01**, **linux01** | dc02 if still child-auth |
| E / F exercises | e / f | P-PURPLE | **elk**, **monitor** + offense subset | + vr; + ws01 for MDE |
| G pre-auth DC | exercises-g | target DC (+ Kali) | Snapshot first; only target DC + Kali | **P-FULL** for cleanup |

---

## 5. Practical tips

1. **Session start:** Suspend RevEng / DarkAI / other labs → apply one CADRE profile → open the matching runbook.
2. **Session end:** Suspend CADRE VMs (don’t destroy) → free RAM for sister work.
3. **DNS:** ws01 points at **dc02** (`.11`). If ws01 can’t resolve the domain, dc02 is down or DNS on ws01 drifted — check `17-ws01-deploy.yml` facts, not `04-vulnerabilities`.
4. **`--kdcHost`:** Multi-DC lab — when only a subset of DCs is up, point NetExec/Impacket at a **running** KDC (usually `.11` for child, `.10` for root).
5. **Telemetry not required to learn offense** — but capture it when you care about plan1.7 / metadata “telemetry fingerprint” rows.
6. **mbr02 (8 GB) and elk (12 GB)** are the two biggest discretionary savings; leave them off until Phase 8 / purple days.
7. If AD trust or replication looks broken after long suspends: power **dc01 + dc02** (+ **dc03** if forest work), wait for healthy replication, then resume the phase profile.

---

## 6. Quick commands (host)

Adjust paths to your VMware / Vagrant root (often under the directory you chose at `cadre.py install`).

```powershell
# Example: resume a beachhead set (names must match your VM display names)
# Prefer VMware UI or vmrun; vagrant resume <name> if the VM is Vagrant-managed.

vagrant status
# vagrant up dc02 ws01 provisioning   # only if those names exist in this Vagrantfile
# ws01 may be a standalone VM — start it from VMware Workstation UI
```

Suspend unused VMs from VMware Workstation (**Suspend** / **Power Off**) rather than `vagrant destroy`.

---

## 7. Related docs

| Doc | Role |
|-----|------|
| [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) | Full campaign narrative (follow this) |
| [`Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Runbooks/CAMPAIGNS-RUNBOOK-README.md) | Which runbook to open |
| [`Runbooks/CAMPAIGNS-RUNBOOK-H.md`](Runbooks/CAMPAIGNS-RUNBOOK-H.md) | Phase 0.5 / ws01 |
| [`docs/deployment.md`](../../docs/deployment.md) | Host RAM / install |
| [`docs/extensions.md`](../../docs/extensions.md) | elk / monitor / vr |
| `ansible/playbooks/17-ws01-deploy.yml` | ws01 deploy (MDE-safe) |

---

*Profiles are guidance, not a second lab. Prefer segmented runs; fall back to P-FULL when needed.*
