# CADRE — Cloud Attack Content (Plan 11)

Cloud + hybrid identity attacks covering CARTP and CARTE certifications.

## Structure

```
09-cloud/
├── entragoat/           EntraGoat scenario wrappers (C01-C06)
├── azure-rm/            Azure RM attacks (A01-A04) — CARTE level
├── hybrid-chains/       Multi-step on-prem ↔ cloud chains (H01-H04)
├── fixtures/            Recorded Graph API responses for offline mode
└── README.md            This file
```

## Walkthroughs

### EntraGoat Scenarios (CARTP)

| ID | Title | Scenario |
|----|-------|----------|
| C01 | SP with Application.ReadWrite.All | Scenario 1 |
| C02 | App with Mail.Read (all mailboxes) | Scenario 2 |
| C03 | RoleManagement.ReadWrite.Directory self-assign | Scenario 3 |
| C04 | SP owner → credential add | Scenario 4 |
| C05 | CBA → Global Admin | Scenario 5 |
| C06 | Conditional Access bypass | Scenario 6 |

### Cloud Sync (CARTP)

| ID | Title |
|----|-------|
| C07 | PHS hash extraction |
| C08 | SyncJacking |
| C09 | Golden SAML |

### Hybrid Chains

| ID | Path |
|----|------|
| H01 | ADCS ESC1 → CBA → Cloud Admin |
| H02 | Cloud SP → Sync write-back → On-prem DC |
| H03 | On-prem Kerberoast → PHS → Cloud |
| H04 | Cloud CA bypass → Token → On-prem RBCD |

### Azure RM (CARTE)

| ID | Title |
|----|-------|
| A01 | Subscription RBAC escalation |
| A02 | PIM eligibility abuse |
| A03 | Cross-tenant B2B guest abuse |
| A04 | Azure Arc → on-prem control |

## Dual Mode

Every cloud walkthrough supports two modes:
- **Offline:** Uses `fixtures/` recorded Graph API responses — no tenant needed
- **Tenant:** Uses a real M365 dev tenant (free) + Azure free trial

## Status

Scaffolded. Content after Plan 11 implementation.
