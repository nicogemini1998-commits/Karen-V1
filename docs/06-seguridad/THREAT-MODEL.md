# THREAT MODEL — Karen AI P.A

> Modelo amenazas Karen v2.2. Research SOTA ciberseguridad 2025-2026 aplicado.
> Quote SOTA: *"No single technique or product can eliminate prompt injection… defense-in-depth is mandatory."*

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
| T1.1 | **Indirect Prompt Injection (IPI) in the wild** | Google: 32% aumento Nov 2025-Feb 2026. 1.8M attacks, 60K successful en red-team competition | P0.3 `spotlight()` + egress allowlist + IPI regex filter |
| T1.2 | **npm/pnpm supply chain (axios incident Mar 2026)** | 100M weekly installs comprometidos vía `plain-crypto-js` postinstall RAT | P0.4 `--ignore-scripts` enforced + lockfile required + audit gate |
| T1.3 | **MCP tool poisoning / rug-pull** | WhatsApp MCP exfiltró history completo. Coined Abr 2025 | P1.2 MCP signature pinning + manual review tool descriptions |
| T1.4 | **EchoLeak (CVE-2025-32711)** | Zero-click data exfiltration M365 Copilot. Persistent memory poisoning Bedrock | P2.1 mem_filter + provenance required + judge sweep weekly |
| T1.5 | **Postmark MCP backdoor (Sep 2025)** | BCC silencioso a maintainer en cada email outbound | P1.1 zero-egress T0_inbox + network allowlist |
| T1.6 | **mcp-server-git RCE (CVE-2025-68143/144/145)** | Full RCE vía malicious `.git/config` files | P3 git config scan + sandbox + pin patched version |
| T1.7 | **Claude Code hook-rewrite escalation** | Injected plugins reescriben permissions/hooks para auto-approve dangerous commands | P0.1 SHA256 ledger + readonly hook dir + integrity check SessionStart |
| T1.8 | **Memory poisoning (AgentPoison NeurIPS 2024)** | A-MemGuard: 66% poisoned memories miss detection. Optimized trigger tokens contra embeddings | P2.1 BANNED_FACTS + ZWSP strip + provenance + weekly judge |

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
| LLM01 Prompt Injection | T1.1 | spotlight() + IPI regex + judge dual-LLM |
| LLM02 Sensitive Info Disclosure | T1.5 | secrets-guard hook + egress allowlist + OAuth scoped |
| LLM03 Supply Chain | T1.2 T1.3 | npm guard + MCP pinning + lockfiles |
| LLM04 Data/Model Poisoning | T1.8 | mem_filter + provenance + weekly judge |
| LLM05 Improper Output Handling | T3 hallucinations | codegen scanner (semgrep/bandit/shellcheck) |
| LLM06 Excessive Agency | Cross-cutting | Rule of Two + tier T0-T4 + domain firewall |
| LLM07 System Prompt Leakage | T1.7 | integrity ledger + readonly hooks |
| LLM08 Vector/Embedding Weaknesses | T1.8 | judge LLM antes upsert + provenance metadata |
| LLM09 Misinformation | T3 hallucinations | citation required mode |
| LLM10 Unbounded Consumption | Cost DoS | rate limits + token budgets per subagent |

---

## MITRE ATLAS coverage

Mitigations aplicadas:
- **AML.M0000** Input validation → spotlight() + DANGEROUS regex.
- **AML.M0008** Active monitoring → audit log + trust score.
- **AML.M0017** Model hardening → judge dual-LLM.
- **AML.M0024** Verify ML artifacts → MCP signature pinning + integrity ledger.
- **AML.M0042** Restrict access → tier T0-T4 + capability matrix.

---

## Threat-to-defense traceability

| Threat | Tier | Karen layer mitigando |
|---|---|---|
| T1.1 IPI in the wild | 1 | L3 spotlight + L4 mem_filter + L6 egress allowlist + L7 redteam monthly |
| T1.2 npm axios-class | 1 | L6 npm-guard hook |
| T1.3 MCP tool poisoning | 1 | L6 MCP signature pinning |
| T1.4 EchoLeak | 1 | L4 mem_filter + L4 judge sweep |
| T1.5 Postmark BCC | 1 | L6 zero-egress T0 + allowlist |
| T1.6 mcp-server-git RCE | 1 | L6 git scan + L6 sandbox |
| T1.7 Hook rewrite | 1 | L1 integrity ledger + readonly perms |
| T1.8 Memory poisoning | 1 | L4 mem_filter + provenance + judge weekly |
| T2 CSS/Unicode smuggle | 2 | L3 ZWSP strip + regex |
| T2 Plugin impersonation | 2 | Solo `anthropics/*` repos, pin marketplace.json hash |
| T3 Hallucinated rm -rf | 3 | L5 codegen scanner |

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
- SessionStart: integrity ledger check (P0.1).
- Hooks bash activos validan cada tool call.
- Audit log append-only `~/.claude/karen/audit-log.jsonl`.

### Weekly
- Stop hook domingo: memory judge sweep (P2.3).
- Trust score audit por subagent (`/karen-audit`).

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
