# THREAT MODEL — Karen AI P.A

> Modelo amenazas Karen v1.1. Research SOTA ciberseguridad 2025-2026 aplicado.
> Quote SOTA: *"No single technique or product can eliminate prompt injection… defense-in-depth is mandatory."*

**Leyenda estado mitigaciones:**
- **[IMPL ✅]** — código real en el repo, probado (hooks bash + libs Python).
- **[IMPL ✅ parcial]** — existe versión reducida (ej. warn-only), enforcement total pendiente.
- **[SPEC 🔨 v2.x]** — diseño documentado, sin código runtime todavía.

---

## Filosofía: Meta Rule of Two

**Quote Anthropic/Meta (Abr 2026):**
> *"An agent should possess at most two of three properties — processing untrusted inputs, accessing sensitive systems, and changing state externally — in any single operation. Agents with all three simultaneously are, in current practice, indefensible without human supervision at every consequential action."*

Karen enforce **Rule of Two** via tier system + domain firewall + capability matrix.

---

## Threat Tiers

### Tier 1 — CRITICAL (active exploitation 2025-2026)

| # | Threat | Evidencia 2026 | Mitigación Karen |
|---|---|---|---|
| T1.1 | **Indirect Prompt Injection (IPI) in the wild** | Google: 32% aumento Nov 2025-Feb 2026. 1.8M attacks, 60K successful en red-team competition | `spotlight()` + IPI regex + `untrusted-input-spotlight.sh` [IMPL ✅ v1.1] · egress allowlist [SPEC 🔨 v2.x] |
| T1.2 | **npm/pnpm supply chain (axios incident Mar 2026)** | 100M weekly installs comprometidos vía `plain-crypto-js` postinstall RAT | `npm-supply-chain-guard.sh`: `--ignore-scripts` enforced + lockfile required [IMPL ✅] |
| T1.3 | **MCP tool poisoning / rug-pull** | WhatsApp MCP exfiltró history completo. Coined Abr 2025 | `mcp-pin-verify.sh` pinning [IMPL ✅] · manual review tool descriptions [proceso manual] |
| T1.4 | **EchoLeak (CVE-2025-32711)** | Zero-click data exfiltration M365 Copilot. Persistent memory poisoning Bedrock | `mem_filter.py` + provenance required [IMPL ✅] · judge sweep weekly [SPEC 🔨 v2.x] |
| T1.5 | **Postmark MCP backdoor (Sep 2025)** | BCC silencioso a maintainer en cada email outbound | zero-egress T0_inbox + network allowlist [SPEC 🔨 v2.x] |
| T1.6 | **mcp-server-git RCE (CVE-2025-68143/144/145)** | Full RCE vía malicious `.git/config` files | pin patched version [proceso manual] · git config scan + sandbox [SPEC 🔨 v2.x] |
| T1.7 | **Claude Code hook-rewrite escalation** | Injected plugins reescriben permissions/hooks para auto-approve dangerous commands | `integrity-ledger.sh` SHA256 + check SessionStart [IMPL ✅] · readonly hook dir [SPEC 🔨 v2.x] |
| T1.8 | **Memory poisoning (AgentPoison NeurIPS 2024)** | A-MemGuard: 66% poisoned memories miss detection. Optimized trigger tokens contra embeddings | BANNED_FACTS + ZWSP strip + provenance (`mem_filter.py`/`spotlight.py`) [IMPL ✅] · weekly judge [SPEC 🔨 v2.x] |
| T1.9 | **Memory poisoning vía contenido externo** | Contenido web/email/docs inyecta facts falsos que acaban en memoria persistente | mitigado por `untrusted-input-spotlight.sh` + `mem_filter` wiring (`memory-safety-filter.sh`) [IMPL ✅ v1.1] |

### Tier 2 — HIGH

- **CSS-hidden injection** (`display:none`, `left:-9999px`, zero font-size, base64+JS).
- **Unicode tag injection** (ZWSP, U+E0000-U+E007F, Cyrillic homoglyphs).
- **Plugin marketplace impersonation** (cuentas GitHub fake masquerading official).
- **Mem0 path traversal** (6 CVEs OpenClaw).
- **STDIO transport flaw** (Abr 2026, 150M downloads afectados).
- **Confused-deputy Filesystem MCP** (CVE-2025-53109/53110 symlink bypass).

### Tier 3 — MEDIUM

- Excessive agency / overscoped OAuth (Asana cross-tenant leak Jun 2025).
- Smithery path traversal Docker tokens (Oct 2025).
- Figma MCP command injection (CVE-2025-53967).
- Resource exhaustion / context flooding.
- Hallucinated commands (`rm -rf` inventado, slopsquatting fake packages).

---

## Attack Surface Karen v2.2

```
┌─────────────────────────────────────────────────────────┐
│ EXTERNAL                                                │
│  ├─ Gmail / Outlook (email contenido untrusted)         │
│  ├─ Calendar (eventos pueden ser malicious)             │
│  ├─ GitHub (issues/PRs/READMEs untrusted)               │
│  ├─ Notion (docs externos compartidos)                  │
│  ├─ Firecrawl/Brightdata (web scraping)                 │
│  └─ Plugins marketplace (impersonation risk)            │
│                                                         │
│  ↓ TODA ENTRADA UNTRUSTED PASA POR spotlight()          │
├─────────────────────────────────────────────────────────┤
│ SUPPLY CHAIN                                            │
│  ├─ npm/pnpm packages (axios-class attacks)             │
│  ├─ PyPI packages                                       │
│  ├─ MCP servers npm/PyPI                                │
│  ├─ Claude Code plugins (marketplace)                   │
│  └─ Docker images (neo4j, mem0)                         │
│                                                         │
│  ↓ Pinning + lockfile + --ignore-scripts + audit        │
├─────────────────────────────────────────────────────────┤
│ KAREN CORE                                              │
│  ├─ ~/.claude/settings.json (hook config)               │
│  ├─ ~/.claude/hooks/*.sh (executable code)              │
│  ├─ ~/.claude/agents/*.json (subagent settings)         │
│  ├─ CLAUDE.md proyecto (instrucciones)                  │
│  └─ rules-learned.md (auto-actualizable)                │
│                                                         │
│  ↓ SHA256 ledger integridad + read-only hooks dir       │
├─────────────────────────────────────────────────────────┤
│ MEMORY                                                  │
│  ├─ Mem0 (vector store)                                 │
│  ├─ Neo4j (graph)                                       │
│  ├─ 01-MEMORIA/*.md (markdown)                          │
│  └─ profile.json                                        │
│                                                         │
│  ↓ mem_filter + judge weekly + provenance required      │
├─────────────────────────────────────────────────────────┤
│ EGRESS                                                  │
│  ├─ Network outbound (curl, fetch, MCP calls)           │
│  ├─ File writes (side projects, memoria, logs)          │
│  ├─ Bash exec (deploy, npm, docker)                     │
│  └─ Git push (repos personales)                         │
│                                                         │
│  ↓ Allowlist per tier + sandbox network=none default    │
└─────────────────────────────────────────────────────────┘
```

---

## Mapeo OWASP LLM Top 10 (2025) → Karen defenses

| OWASP | Threat | Karen defense |
|---|---|---|
| LLM01 Prompt Injection | T1.1 | spotlight() + IPI regex [IMPL ✅] · judge dual-LLM [SPEC 🔨 v2.x] |
| LLM02 Sensitive Info Disclosure | T1.5 | secrets-guard hook [IMPL ✅] · egress allowlist [SPEC 🔨 v2.x] · OAuth scoped [proceso manual] |
| LLM03 Supply Chain | T1.2 T1.3 | npm guard + MCP pinning + lockfiles [IMPL ✅] |
| LLM04 Data/Model Poisoning | T1.8 T1.9 | mem_filter + provenance [IMPL ✅] · weekly judge [SPEC 🔨 v2.x] |
| LLM05 Improper Output Handling | T3 hallucinations | codegen scanner (semgrep/bandit/shellcheck) [IMPL ✅] |
| LLM06 Excessive Agency | Cross-cutting | domain firewall paths [IMPL ✅ best-effort] · Rule of Two enforcement + tiers runtime [SPEC 🔨 v2.x] |
| LLM07 System Prompt Leakage | T1.7 | integrity ledger [IMPL ✅] · readonly hooks [SPEC 🔨 v2.x] |
| LLM08 Vector/Embedding Weaknesses | T1.8 | provenance metadata [IMPL ✅] · judge LLM antes upsert [SPEC 🔨 v2.x] |
| LLM09 Misinformation | T3 hallucinations | citation-required v1 warn-only (`citation-required.sh`) [IMPL ✅ parcial v1.1] · enforcement total [SPEC 🔨 v2.x] |
| LLM10 Unbounded Consumption | Cost DoS | budget caps `cost_optimizer.py` [IMPL ✅ lib] · rate limits + budgets per subagent [SPEC 🔨 v2.x] |

---

## MITRE ATLAS coverage

Mitigations aplicadas:
- **AML.M0000** Input validation → spotlight() + DANGEROUS regex [IMPL ✅].
- **AML.M0008** Active monitoring → audit log (`audit-trail.sh`) [IMPL ✅ v1.1] · trust score [SPEC 🔨 v2.x].
- **AML.M0017** Model hardening → judge dual-LLM [SPEC 🔨 v2.x].
- **AML.M0024** Verify ML artifacts → MCP signature pinning + integrity ledger [IMPL ✅].
- **AML.M0042** Restrict access → domain firewall paths [IMPL ✅ best-effort] · tiers T0-T4 runtime + capability matrix [SPEC 🔨 v2.x].

---

## Threat-to-defense traceability

| Threat | Tier | Karen layer mitigando |
|---|---|---|
| T1.1 IPI in the wild | 1 | L3 spotlight [IMPL ✅] + L4 mem_filter [IMPL ✅] + L6 egress allowlist [SPEC 🔨 v2.x] + L7 redteam monthly [proceso] |
| T1.2 npm axios-class | 1 | L6 npm-guard hook [IMPL ✅] |
| T1.3 MCP tool poisoning | 1 | L6 MCP signature pinning [IMPL ✅] |
| T1.4 EchoLeak | 1 | L4 mem_filter [IMPL ✅] + L4 judge sweep [SPEC 🔨 v2.x] |
| T1.5 Postmark BCC | 1 | L6 zero-egress T0 + allowlist [SPEC 🔨 v2.x] |
| T1.6 mcp-server-git RCE | 1 | L6 git scan + L6 sandbox [SPEC 🔨 v2.x] |
| T1.7 Hook rewrite | 1 | L1 integrity ledger [IMPL ✅] + readonly perms [SPEC 🔨 v2.x] |
| T1.8 Memory poisoning | 1 | L4 mem_filter + provenance [IMPL ✅] + judge weekly [SPEC 🔨 v2.x] |
| T1.9 Memory poisoning vía contenido externo | 1 | mitigado por `untrusted-input-spotlight.sh` + `mem_filter` wiring [IMPL ✅ v1.1] |
| T2 CSS/Unicode smuggle | 2 | L3 ZWSP strip + regex [IMPL ✅] |
| T2 Plugin impersonation | 2 | Solo `anthropics/*` repos, pin marketplace.json hash [proceso manual] |
| T3 Hallucinated rm -rf | 3 | L5 codegen scanner [IMPL ✅] |

---

## Standards compliance

- ✅ OWASP LLM Top 10 (2025).
- ✅ MITRE ATLAS framework.
- ⚠ NIST AI RMF (parcial — falta documentation formal).
- ⚠ EU AI Act (no aplica directo a uso personal).
- ⚠ ISO 42001 (no aplica directo).

---

## Threat actors considerados

| Actor | Capacidades | Mitigación primaria |
|---|---|---|
| **External via email/web/docs** | Inyecta instrucciones en contenido leído | spotlight + filtros + judge |
| **Supply chain (npm/PyPI/MCP marketplace)** | Compromete packages downstream | Pinning + lockfiles + `--ignore-scripts` |
| **Insider data exfiltration** | Karen leak Cliender → personal o viceversa | Domain firewall + Cliender isolation guard |
| **Hallucinations as attack** | Karen genera comandos destructivos / fake creds | Codegen scanner + confirm humano destructive |
| **Side projects con vulnerabilidades** | Karen escribe código inseguro | semgrep/bandit/shellcheck PostToolUse |

---

## Continuous security

### Daily
- SessionStart: integrity ledger check [IMPL ✅].
- Hooks bash activos validan cada tool call [IMPL ✅ — requiere `install.sh` ejecutado].
- Audit log append-only (`audit-trail.sh`) [IMPL ✅ v1.1].

### Weekly
- Memory judge sweep domingo — vía cron o `/loop` (Claude Code no soporta "Stop hook"/"SessionStop" persistente para esto) [SPEC 🔨 v2.x].
- Trust score audit por subagent (`/karen-audit`) [command IMPL ✅ · score runtime SPEC 🔨 v2.x].

### Monthly
- garak baseline red-team (`/karen-redteam`).
- Review MCP server CVEs en https://authzed.com/blog/timeline-mcp-breaches.
- Rotate OAuth tokens.

### Quarterly
- OWASP LLM Top 10 self-assessment.
- MITRE ATLAS mapping refresh.
- Full PyRIT red-team campaign.

---

## Bibliografía

- [Help Net Security — IPI in the wild Apr 2026](https://www.helpnetsecurity.com/2026/04/24/indirect-prompt-injection-in-the-wild/)
- [Google — AI threats in the wild](https://blog.google/security/prompt-injections-web/)
- [Palo Alto Unit 42 — Web-Based IPI in the Wild](https://unit42.paloaltonetworks.com/ai-agent-prompt-injection/)
- [Lakera — Indirect Prompt Injection](https://www.lakera.ai/blog/indirect-prompt-injection)
- [Authzed — MCP Breaches Timeline](https://authzed.com/blog/timeline-mcp-breaches)
- [Strobes — MCP Critical Vulnerabilities](https://strobes.co/blog/mcp-model-context-protocol-and-its-critical-vulnerabilities/)
- [NSA — Model Context Protocol CSI](https://www.nsa.gov/Portals/75/documents/Cybersecurity/CSI_MCP_SECURITY.pdf)
- [OWASP LLM Top 10 2025](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [Snyk — TanStack npm Shai-Hulud](https://snyk.io/blog/tanstack-npm-packages-compromised/)
- [arXiv 2512.16962 — MemoryGraft](https://arxiv.org/pdf/2512.16962)
- [Mem0 — Security Best Practices](https://mem0.ai/blog/ai-memory-security-best-practices)
- [Northflank — Sandboxing AI agents 2026](https://northflank.com/blog/how-to-sandbox-ai-agents)
- [PromptArmor — Hijacking Claude Code](https://www.promptarmor.com/resources/hijacking-claude-code-via-injected-marketplace-plugins)
- [Cybersecurity News — Anthropic security plugin](https://cybersecuritynews.com/anthropic-updates-claude-code/)
