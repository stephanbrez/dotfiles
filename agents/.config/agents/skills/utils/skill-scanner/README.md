Based on:
<https://github.com/getsentry/skills/tree/main/plugins/sentry-skills/skills/skill-scanner>

# Limitations

This scanner performs **static analysis only**. Users should understand these
limitations:

## What This Scanner Cannot Detect

| Limitation                       | Description                                                                                         |
| -------------------------------- | --------------------------------------------------------------------------------------------------- |
| **Runtime behavior**             | Code that appears benign statically but behaves maliciously at runtime (e.g., conditional payloads) |
| **Polymorphic/metamorphic code** | Obfuscation that changes each execution or uses runtime code generation                             |
| **Network-dependent attacks**    | Payloads fetched from remote servers at runtime                                                     |
| **Timing-based attacks**         | Malicious behavior triggered after a delay or on specific dates                                     |
| **Sophisticated obfuscation**    | Advanced encoding schemes beyond base64/ROT13/homoglyphs                                            |
| **Compiled binaries**            | Cannot analyze `.exe`, `.dll`, `.so`, or other compiled code                                        |
| **Encrypted payloads**           | Content encrypted with keys not present in the skill                                                |

## Coverage Gaps

| Area                     | Current State                                                                             |
| ------------------------ | ----------------------------------------------------------------------------------------- |
| **Language support**     | Python, Shell, JS/TS, Ruby, Go, PowerShell. Other languages use generic patterns only.    |
| **Package verification** | Checks for typosquatting patterns but cannot verify packages actually exist on registries |
| **Image formats**        | PNG, JPEG, SVG. Other formats (GIF, WebP, TIFF, PDF) not analyzed for hidden content      |
| **MCP configurations**   | Does not analyze `.mcp.json` files for permission escalation                              |

## Best Practices for Users

1. **Complement with dynamic analysis** — Run suspicious skills in an isolated
   environment and monitor network/filesystem activity
2. **Review flagged items manually** — Medium-confidence findings require human
   judgment
3. **Check package registries** — Verify dependencies exist on PyPI/npm before
   installing
4. **Monitor skill behavior** — Watch for unexpected network connections or file
   access during first use
5. **Keep scanner updated** — New attack patterns emerge regularly
