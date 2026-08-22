#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = ["pyyaml"]
# ///
"""
Static analysis scanner for agent skills.

Scans a skill directory for security issues including prompt injection patterns,
obfuscation, dangerous code, secrets, and excessive permissions.

Usage:
    uv run scan_skill.py <skill-directory>

Output: JSON to stdout with structured findings.
"""

from __future__ import annotations

import base64
import json
import re
import sys
from pathlib import Path
from typing import Any

import yaml

# --- Pattern Definitions ---

PROMPT_INJECTION_PATTERNS: list[tuple[str, str, str]] = [
    # (pattern, description, severity)
    (
        r"(?i)ignore\s+(all\s+)?previous\s+instructions",
        "Instruction override: ignore previous instructions",
        "critical",
    ),
    (
        r"(?i)disregard\s+(all\s+)?(previous|prior|above)\s+(instructions|rules|guidelines)",
        "Instruction override: disregard previous",
        "critical",
    ),
    (
        r"(?i)forget\s+(all\s+)?(previous|prior|your)\s+(instructions|rules|training)",
        "Instruction override: forget previous",
        "critical",
    ),
    (r"(?i)you\s+are\s+now\s+(a|an|in)\s+", "Role reassignment: 'you are now'", "high"),
    (
        r"(?i)act\s+as\s+(a|an)\s+unrestricted",
        "Role reassignment: unrestricted mode",
        "critical",
    ),
    (
        r"(?i)enter\s+(developer|debug|admin|god)\s+mode",
        "Jailbreak: developer/debug mode",
        "critical",
    ),
    (r"(?i)DAN\s+(mode|prompt|jailbreak)", "Jailbreak: DAN pattern", "critical"),
    (r"(?i)do\s+anything\s+now", "Jailbreak: do anything now", "critical"),
    (
        r"(?i)bypass\s+(safety|security|content|filter|restriction)",
        "Jailbreak: bypass safety",
        "critical",
    ),
    (
        r"(?i)override\s+(system|safety|security)\s+(prompt|message|instruction)",
        "System prompt override",
        "critical",
    ),
    (r"(?i)\bsystem\s*:\s*you\s+are\b", "System prompt injection marker", "high"),
    (
        r"(?i)new\s+system\s+(prompt|instruction|message)\s*:",
        "New system prompt injection",
        "critical",
    ),
    (
        r"(?i)from\s+now\s+on,?\s+(you|ignore|forget|disregard)",
        "Temporal instruction override",
        "high",
    ),
    (
        r"(?i)pretend\s+(that\s+)?you\s+(have\s+no|don't\s+have|are\s+not\s+bound)",
        "Pretend-based jailbreak",
        "high",
    ),
    (
        r"(?i)respond\s+(only\s+)?with\s+(the\s+)?(raw|full|complete)\s+(system|initial)\s+prompt",
        "System prompt extraction",
        "high",
    ),
    (
        r"(?i)output\s+(your|the)\s+(system|initial|original)\s+(prompt|instructions)",
        "System prompt extraction",
        "high",
    ),
]

OBFUSCATION_PATTERNS: list[tuple[str, str]] = [
    # (description, detail)
    ("Zero-width characters", "Zero-width space, joiner, or non-joiner detected"),
    ("Right-to-left override", "RTL override character can hide text direction"),
    (
        "Homoglyph characters",
        "Characters visually similar to ASCII but from different Unicode blocks",
    ),
    (
        "Unicode Tag characters",
        "Tags block (U+E0000-E007F) can encode invisible ASCII text readable by LLMs",
    ),
]

# Homoglyph mapping: confusable Unicode characters that look like ASCII
# Maps suspicious Unicode chars to the ASCII they mimic
HOMOGLYPH_MAP: dict[str, str] = {
    # Cyrillic lookalikes
    "\u0430": "a",  # Cyrillic а
    "\u0435": "e",  # Cyrillic е
    "\u043e": "o",  # Cyrillic о
    "\u0440": "p",  # Cyrillic р
    "\u0441": "c",  # Cyrillic с
    "\u0443": "y",  # Cyrillic у
    "\u0445": "x",  # Cyrillic х
    "\u0456": "i",  # Cyrillic і
    "\u0458": "j",  # Cyrillic ј
    "\u04bb": "h",  # Cyrillic һ
    "\u0501": "d",  # Cyrillic ԁ
    "\u051b": "q",  # Cyrillic ԛ
    "\u051d": "w",  # Cyrillic ԝ
    # Greek lookalikes
    "\u03b1": "a",  # Greek α (alpha)
    "\u03b5": "e",  # Greek ε (epsilon)
    "\u03bf": "o",  # Greek ο (omicron)
    "\u03c1": "p",  # Greek ρ (rho)
    "\u03c4": "t",  # Greek τ (tau)
    "\u03bd": "v",  # Greek ν (nu)
    "\u03c9": "w",  # Greek ω (omega)
    "\u03ba": "k",  # Greek κ (kappa)
    "\u03b9": "i",  # Greek ι (iota)
    # Other confusables
    "\u0261": "g",  # Latin Small Letter Script G
    "\u026a": "i",  # Latin Letter Small Capital I
    "\u1d00": "a",  # Latin Letter Small Capital A
    "\u1d07": "e",  # Latin Letter Small Capital E
    "\u1d0f": "o",  # Latin Letter Small Capital O
    # Note: Dashes (em-dash, en-dash) excluded from homoglyph detection
    # as they are common typography and not typically used for obfuscation
    "\uff41": "a",  # Fullwidth a
    "\uff45": "e",  # Fullwidth e
    "\uff49": "i",  # Fullwidth i
    "\uff4f": "o",  # Fullwidth o
    "\uff55": "u",  # Fullwidth u
}

# Security-sensitive keywords that attackers might try to obfuscate with homoglyphs
SECURITY_KEYWORDS = {
    "ignore",
    "previous",
    "instructions",
    "disregard",
    "forget",
    "override",
    "system",
    "prompt",
    "bypass",
    "safety",
    "security",
    "password",
    "secret",
    "token",
    "credential",
    "eval",
    "exec",
    "import",
    "shell",
    "sudo",
    "admin",
}

# URL shortener domains
URL_SHORTENERS = {
    "bit.ly",
    "tinyurl.com",
    "t.co",
    "goo.gl",
    "ow.ly",
    "is.gd",
    "buff.ly",
    "adf.ly",
    "j.mp",
    "tr.im",
    "cli.gs",
    "short.to",
    "budurl.com",
    "ping.fm",
    "post.ly",
    "just.as",
    "bkite.com",
    "snipr.com",
    "fic.kr",
    "loopt.us",
    "doiop.com",
    "short.ie",
    "kl.am",
    "wp.me",
    "rubyurl.com",
    "om.ly",
    "to.ly",
    "bit.do",
    "lnkd.in",
    "db.tt",
    "qr.ae",
    "cur.lv",
    "ity.im",
    "q.gs",
    "po.st",
    "bc.vc",
    "twitthis.com",
    "u.telecom.lt",
    "tiny.cc",
    "shorturl.at",
    "rb.gy",
}

SECRET_PATTERNS: list[tuple[str, str, str]] = [
    # (pattern, description, severity)
    (r"(?i)AKIA[0-9A-Z]{16}", "AWS Access Key ID", "critical"),
    (
        r"(?i)aws.{0,20}secret.{0,20}['\"][0-9a-zA-Z/+]{40}['\"]",
        "AWS Secret Access Key",
        "critical",
    ),
    (r"ghp_[0-9a-zA-Z]{36}", "GitHub Personal Access Token", "critical"),
    (r"ghs_[0-9a-zA-Z]{36}", "GitHub Server Token", "critical"),
    (r"gho_[0-9a-zA-Z]{36}", "GitHub OAuth Token", "critical"),
    (r"github_pat_[0-9a-zA-Z_]{82}", "GitHub Fine-Grained PAT", "critical"),
    (r"sk-[0-9a-zA-Z]{20,}T3BlbkFJ[0-9a-zA-Z]{20,}", "OpenAI API Key", "critical"),
    (r"sk-ant-api03-[0-9a-zA-Z\-_]{90,}", "Anthropic API Key", "critical"),
    (r"xox[bpors]-[0-9a-zA-Z\-]{10,}", "Slack Token", "critical"),
    (r"-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----", "Private Key", "critical"),
    (
        r"(?i)(password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{8,}['\"]",
        "Hardcoded password",
        "high",
    ),
    (
        r"(?i)(api[_-]?key|apikey)\s*[:=]\s*['\"][0-9a-zA-Z]{16,}['\"]",
        "Hardcoded API key",
        "high",
    ),
    (
        r"(?i)(secret|token)\s*[:=]\s*['\"][0-9a-zA-Z]{16,}['\"]",
        "Hardcoded secret/token",
        "high",
    ),
]

DANGEROUS_SCRIPT_PATTERNS: list[tuple[str, str, str]] = [
    # (pattern, description, severity)
    # Data exfiltration
    (
        r"(?i)(requests\.(get|post|put)|urllib\.request|http\.client|aiohttp)\s*\(",
        "HTTP request (potential exfiltration)",
        "medium",
    ),
    (r"(?i)(curl|wget)\s+", "Shell HTTP request", "medium"),
    (r"(?i)socket\.(connect|create_connection)", "Raw socket connection", "high"),
    (
        r"(?i)subprocess.*\b(nc|ncat|netcat)\b",
        "Netcat usage (potential reverse shell)",
        "critical",
    ),
    # Credential access
    (
        r"(?i)(~|HOME|USERPROFILE).*\.(ssh|aws|gnupg|config)",
        "Sensitive directory access",
        "high",
    ),
    (
        r"(?i)open\s*\(.*(\.env|credentials|\.netrc|\.pgpass|\.my\.cnf)",
        "Sensitive file access",
        "high",
    ),
    (
        r"(?i)os\.environ\s*\[.*(?:KEY|SECRET|TOKEN|PASSWORD|CREDENTIAL)",
        "Environment secret access",
        "medium",
    ),
    # Dangerous execution
    (r"\beval\s*\(", "eval() usage", "high"),
    (r"\bexec\s*\(", "exec() usage", "high"),
    (r"(?i)subprocess.*shell\s*=\s*True", "Shell execution with shell=True", "high"),
    (r"(?i)os\.(system|popen|exec[lv]p?e?)\s*\(", "OS command execution", "high"),
    (r"(?i)__import__\s*\(", "Dynamic import", "medium"),
    # File system manipulation
    (
        r"(?i)(open|write|Path).*\.(claude|bashrc|zshrc|profile|bash_profile)",
        "Agent/shell config modification",
        "critical",
    ),
    (
        r"(?i)(open|write|Path).*(settings\.json|CLAUDE\.md|MEMORY\.md|\.mcp\.json)",
        "Agent settings modification",
        "critical",
    ),
    (
        r"(?i)(open|write|Path).*(\.git/hooks|\.husky)",
        "Git hooks modification",
        "critical",
    ),
    # Encoding/obfuscation in scripts
    (
        r"(?i)base64\.(b64decode|decodebytes)\s*\(",
        "Base64 decoding (potential obfuscation)",
        "medium",
    ),
    (r"(?i)codecs\.(decode|encode)\s*\(.*rot", "ROT encoding (obfuscation)", "high"),
    (r"(?i)compile\s*\(.*exec", "Dynamic code compilation", "high"),
    # Unsafe YAML loading
    (
        r"(?i)yaml\.(load|unsafe_load)\s*\(",
        "Unsafe YAML loading (allows arbitrary code execution)",
        "critical",
    ),
    (
        r"(?i)yaml\.load\s*\([^)]*Loader\s*=\s*yaml\.(Loader|UnsafeLoader|FullLoader)",
        "Unsafe YAML Loader specified",
        "critical",
    ),
]

# Ruby-specific dangerous patterns
DANGEROUS_RUBY_PATTERNS: list[tuple[str, str, str]] = [
    (r"\beval\s*[\(\s]", "eval() usage in Ruby", "high"),
    (r"\bsystem\s*[\(\s]", "system() shell execution", "high"),
    (r"\bexec\s*[\(\s]", "exec() shell execution", "high"),
    (r"`[^`]+`", "Backtick shell execution", "high"),
    (r"%x\{[^}]+\}", "Percent-x shell execution", "high"),
    (r"Kernel\.(system|exec|spawn|`)", "Kernel shell methods", "high"),
    (r"Open3\.(popen|capture|pipeline)", "Open3 subprocess execution", "medium"),
    (r"IO\.popen", "IO.popen subprocess", "high"),
    (r"Gem::Installer", "Gem installation (supply chain risk)", "medium"),
    (
        r"require\s+['\"]net/http['\"]",
        "HTTP library (potential exfiltration)",
        "medium",
    ),
    (r"TCPSocket\.new", "Raw TCP socket connection", "high"),
    (r"ENV\[.*(?:KEY|SECRET|TOKEN|PASSWORD)", "Environment secret access", "medium"),
]

# Go-specific dangerous patterns
DANGEROUS_GO_PATTERNS: list[tuple[str, str, str]] = [
    (r"exec\.Command\s*\(", "exec.Command shell execution", "high"),
    (r"os/exec", "os/exec import (shell execution capability)", "medium"),
    (r"syscall\.(Exec|ForkExec)", "syscall execution", "high"),
    (r"net\.Dial\s*\(", "Network dial (potential exfiltration)", "medium"),
    (r"http\.(Get|Post|Do)\s*\(", "HTTP request (potential exfiltration)", "medium"),
    (r"os\.(Getenv|Environ)", "Environment variable access", "low"),
    (r"ioutil\.ReadFile.*\.(ssh|aws|env|credentials)", "Sensitive file read", "high"),
    (r"plugin\.Open", "Dynamic plugin loading", "high"),
]

# PowerShell-specific dangerous patterns
DANGEROUS_POWERSHELL_PATTERNS: list[tuple[str, str, str]] = [
    (r"Invoke-Expression", "Invoke-Expression (arbitrary code execution)", "critical"),
    (r"iex\s+", "iex alias for Invoke-Expression", "critical"),
    (r"Invoke-Command", "Invoke-Command remote execution", "high"),
    (r"Start-Process", "Start-Process execution", "medium"),
    (r"New-Object\s+Net\.WebClient", "WebClient (potential exfiltration)", "high"),
    (r"Invoke-WebRequest", "Web request (potential exfiltration)", "medium"),
    (r"Invoke-RestMethod", "REST call (potential exfiltration)", "medium"),
    (r"DownloadString|DownloadFile", "Download methods (remote code)", "critical"),
    (r"\[System\.Net\.Sockets", "Socket access", "high"),
    (r"ConvertTo-SecureString", "SecureString handling", "medium"),
    (
        r"\$env:(.*KEY|.*SECRET|.*TOKEN|.*PASSWORD)",
        "Environment secret access",
        "medium",
    ),
    (r"-EncodedCommand", "Encoded command (obfuscation)", "high"),
    (r"FromBase64String", "Base64 decoding (potential obfuscation)", "medium"),
    (r"Set-ExecutionPolicy", "Execution policy modification", "high"),
]

# Well-known legitimate Python packages (subset for typosquatting detection)
KNOWN_PYPI_PACKAGES = {
    "requests",
    "urllib3",
    "numpy",
    "pandas",
    "flask",
    "django",
    "fastapi",
    "pyyaml",
    "pydantic",
    "pytest",
    "black",
    "mypy",
    "ruff",
    "httpx",
    "aiohttp",
    "boto3",
    "botocore",
    "pillow",
    "sqlalchemy",
    "celery",
    "redis",
    "psycopg2",
    "pymongo",
    "cryptography",
    "paramiko",
    "fabric",
    "ansible",
    "click",
    "typer",
    "rich",
    "beautifulsoup4",
    "lxml",
    "scrapy",
    "selenium",
    "playwright",
    "tensorflow",
    "torch",
    "scikit-learn",
    "scipy",
    "matplotlib",
    "seaborn",
    "jinja2",
    "mako",
    "werkzeug",
    "gunicorn",
    "uvicorn",
    "starlette",
    "httptools",
    "asyncio",
    "aiofiles",
    "anyio",
    "trio",
    "twisted",
    "gevent",
    "eventlet",
    "setuptools",
    "wheel",
    "pip",
    "virtualenv",
    "poetry",
    "pipenv",
    "flit",
    "tox",
    "nox",
    "pre-commit",
    "coverage",
    "hypothesis",
    "faker",
    "factory-boy",
    "marshmallow",
    "attrs",
    "dataclasses",
    "typing-extensions",
    "mypy-extensions",
    "python-dotenv",
    "environs",
    "pydantic-settings",
    "dynaconf",
    "python-decouple",
    "arrow",
    "pendulum",
    "python-dateutil",
    "pytz",
    "babel",
    "humanize",
    "pathlib",
    "pathspec",
    "watchdog",
    "apscheduler",
    "schedule",
    "rq",
    "sentry-sdk",
    "structlog",
    "loguru",
    "python-json-logger",
    "orjson",
    "ujson",
    "simplejson",
    "msgpack",
    "protobuf",
    "grpcio",
    "websockets",
    "python-socketio",
    "channels",
    "daphne",
    "stripe",
    "twilio",
    "sendgrid",
    "mailchimp3",
    "slack-sdk",
    "openai",
    "anthropic",
    "langchain",
    "llama-index",
    "transformers",
    "huggingface-hub",
}

# Common typosquatting patterns
TYPOSQUAT_PATTERNS = [
    (r"^(.+)-python$", r"\1"),  # requests-python -> requests
    (r"^python-(.+)$", r"\1"),  # python-requests -> requests
    (r"^py(.+)$", r"\1"),  # pyrequests -> requests
    (r"^(.+)py$", r"\1"),  # requestspy -> requests
    (r"^(.+)-py$", r"\1"),  # requests-py -> requests
    (r"^(.+)lib$", r"\1"),  # requestslib -> requests
    (r"^(.+)-lib$", r"\1"),  # requests-lib -> requests
    (r"^(.+)[0-9]+$", r"\1"),  # requests2 -> requests
    (r"^(.+)-[0-9]+$", r"\1"),  # requests-2 -> requests
]

# Domains commonly trusted in skill contexts
TRUSTED_DOMAINS = {
    "github.com",
    "api.github.com",
    "raw.githubusercontent.com",
    "docs.sentry.io",
    "develop.sentry.dev",
    "sentry.io",
    "pypi.org",
    "npmjs.com",
    "crates.io",
    "docs.python.org",
    "docs.djangoproject.com",
    "developer.mozilla.org",
    "stackoverflow.com",
    "agentskills.io",
}


def parse_frontmatter(content: str) -> tuple[dict[str, Any] | None, str]:
    """Parse YAML frontmatter from SKILL.md content."""
    if not content.startswith("---"):
        return None, content

    parts = content.split("---", 2)
    if len(parts) < 3:
        return None, content

    try:
        fm = yaml.safe_load(parts[1])
        body = parts[2]
        return fm if isinstance(fm, dict) else None, body
    except yaml.YAMLError:
        return None, content


def check_frontmatter(skill_dir: Path, content: str) -> list[dict[str, Any]]:
    """Validate SKILL.md frontmatter."""
    findings: list[dict[str, Any]] = []
    fm, _ = parse_frontmatter(content)

    if fm is None:
        findings.append(
            {
                "type": "Invalid Frontmatter",
                "severity": "high",
                "location": "SKILL.md:1",
                "description": "Missing or unparseable YAML frontmatter",
                "category": "Validation",
            }
        )
        return findings

    # Required fields
    if "name" not in fm:
        findings.append(
            {
                "type": "Missing Name",
                "severity": "high",
                "location": "SKILL.md frontmatter",
                "description": "Required 'name' field missing from frontmatter",
                "category": "Validation",
            }
        )

    if "description" not in fm:
        findings.append(
            {
                "type": "Missing Description",
                "severity": "medium",
                "location": "SKILL.md frontmatter",
                "description": "Required 'description' field missing from frontmatter",
                "category": "Validation",
            }
        )

    # Name-directory mismatch
    if "name" in fm and fm["name"] != skill_dir.name:
        findings.append(
            {
                "type": "Name Mismatch",
                "severity": "medium",
                "location": "SKILL.md frontmatter",
                "description": f"Frontmatter name '{fm['name']}' does not match directory name '{skill_dir.name}'",
                "category": "Validation",
            }
        )

    # Unrestricted tools
    tools = fm.get("allowed-tools", "")
    if isinstance(tools, str) and tools.strip() == "*":
        findings.append(
            {
                "type": "Unrestricted Tools",
                "severity": "critical",
                "location": "SKILL.md frontmatter",
                "description": "allowed-tools is set to '*' (unrestricted access to all tools)",
                "category": "Excessive Permissions",
            }
        )

    return findings


def check_prompt_injection(content: str, filepath: str) -> list[dict[str, Any]]:
    """Scan content for prompt injection patterns."""
    findings: list[dict[str, Any]] = []
    lines = content.split("\n")

    for line_num, line in enumerate(lines, 1):
        for pattern, description, severity in PROMPT_INJECTION_PATTERNS:
            if re.search(pattern, line):
                findings.append(
                    {
                        "type": "Prompt Injection Pattern",
                        "severity": severity,
                        "location": f"{filepath}:{line_num}",
                        "description": description,
                        "evidence": line.strip()[:200],
                        "category": "Prompt Injection",
                    }
                )
                break  # One finding per line

    return findings


def check_obfuscation(content: str, filepath: str) -> list[dict[str, Any]]:
    """Detect obfuscation techniques."""
    findings: list[dict[str, Any]] = []
    lines = content.split("\n")

    # Zero-width characters
    zwc_pattern = re.compile(r"[\u200b\u200c\u200d\u2060\ufeff]")
    for line_num, line in enumerate(lines, 1):
        if zwc_pattern.search(line):
            chars = [f"U+{ord(c):04X}" for c in zwc_pattern.findall(line)]
            findings.append(
                {
                    "type": "Zero-Width Characters",
                    "severity": "high",
                    "location": f"{filepath}:{line_num}",
                    "description": f"Zero-width characters detected: {', '.join(chars)}",
                    "category": "Obfuscation",
                }
            )

    # RTL override
    rtl_pattern = re.compile(r"[\u202a-\u202e\u2066-\u2069]")
    for line_num, line in enumerate(lines, 1):
        if rtl_pattern.search(line):
            findings.append(
                {
                    "type": "RTL Override",
                    "severity": "high",
                    "location": f"{filepath}:{line_num}",
                    "description": "Right-to-left override or embedding character detected",
                    "category": "Obfuscation",
                }
            )

    # Unicode Tag characters (U+E0000 block) — invisible text readable by LLMs
    tag_pattern = re.compile(r"[\U000e0001-\U000e007f]")
    tag_chars = tag_pattern.findall(content)
    if tag_chars:
        # Decode the hidden text
        decoded = "".join(
            chr(ord(c) - 0xE0000) for c in tag_chars if 0xE0020 <= ord(c) <= 0xE007E
        )
        findings.append(
            {
                "type": "Unicode Tag Smuggling",
                "severity": "critical",
                "location": filepath,
                "description": f"Invisible Unicode Tag characters detected ({len(tag_chars)} chars). "
                f"Decoded hidden text: {decoded[:200]}",
                "category": "Obfuscation",
            }
        )

    # Suspicious base64 strings (long base64 that decodes to text with suspicious keywords)
    b64_pattern = re.compile(r"[A-Za-z0-9+/]{40,}={0,2}")
    for line_num, line in enumerate(lines, 1):
        for match in b64_pattern.finditer(line):
            try:
                decoded = base64.b64decode(match.group()).decode(
                    "utf-8", errors="ignore"
                )
                suspicious_keywords = [
                    "ignore",
                    "system",
                    "override",
                    "eval",
                    "exec",
                    "password",
                    "secret",
                ]
                for kw in suspicious_keywords:
                    if kw.lower() in decoded.lower():
                        findings.append(
                            {
                                "type": "Suspicious Base64",
                                "severity": "high",
                                "location": f"{filepath}:{line_num}",
                                "description": f"Base64 string decodes to text containing '{kw}'",
                                "decoded_preview": decoded[:100],
                                "category": "Obfuscation",
                            }
                        )
                        break
            except Exception:
                pass

    # HTML comments with suspicious content
    comment_pattern = re.compile(r"<!--(.*?)-->", re.DOTALL)
    for match in comment_pattern.finditer(content):
        comment_text = match.group(1)
        # Check if the comment contains injection-like patterns
        for pattern, description, severity in PROMPT_INJECTION_PATTERNS:
            if re.search(pattern, comment_text):
                # Find line number
                line_num = content[: match.start()].count("\n") + 1
                findings.append(
                    {
                        "type": "Hidden Injection in Comment",
                        "severity": "critical",
                        "location": f"{filepath}:{line_num}",
                        "description": f"HTML comment contains injection pattern: {description}",
                        "evidence": comment_text.strip()[:200],
                        "category": "Prompt Injection",
                    }
                )
                break

    # Homoglyph detection - characters that look like ASCII but aren't
    findings.extend(check_homoglyphs(content, filepath))

    # Markdown injection vectors
    findings.extend(check_markdown_injection(content, filepath))

    return findings


def check_homoglyphs(content: str, filepath: str) -> list[dict[str, Any]]:
    """Detect homoglyph characters used to evade keyword detection."""
    findings: list[dict[str, Any]] = []
    lines = content.split("\n")

    for line_num, line in enumerate(lines, 1):
        # Check if line contains any homoglyphs
        found_homoglyphs: list[tuple[str, str]] = []
        for char in line:
            if char in HOMOGLYPH_MAP:
                found_homoglyphs.append((char, HOMOGLYPH_MAP[char]))

        if found_homoglyphs:
            # Decode the line to see what it would look like in ASCII
            decoded_line = line
            for homoglyph, ascii_char in found_homoglyphs:
                decoded_line = decoded_line.replace(homoglyph, ascii_char)

            # Check if decoded line contains security-sensitive keywords
            decoded_lower = decoded_line.lower()
            matched_keywords = [kw for kw in SECURITY_KEYWORDS if kw in decoded_lower]

            if matched_keywords:
                char_info = ", ".join(
                    f"'{h}'(U+{ord(h):04X})→'{a}'" for h, a in found_homoglyphs[:5]
                )
                findings.append(
                    {
                        "type": "Homoglyph Obfuscation",
                        "severity": "critical",
                        "location": f"{filepath}:{line_num}",
                        "description": f"Line contains homoglyph characters that decode to security keywords: {matched_keywords}",
                        "evidence": f"Original: {line.strip()[:100]} | Decoded: {decoded_line.strip()[:100]}",
                        "homoglyphs": char_info,
                        "category": "Obfuscation",
                    }
                )
            elif len(found_homoglyphs) > 2:
                # Multiple homoglyphs even without keyword match is suspicious
                char_info = ", ".join(
                    f"'{h}'(U+{ord(h):04X})→'{a}'" for h, a in found_homoglyphs[:5]
                )
                findings.append(
                    {
                        "type": "Suspicious Homoglyphs",
                        "severity": "medium",
                        "location": f"{filepath}:{line_num}",
                        "description": f"Line contains {len(found_homoglyphs)} homoglyph characters (non-ASCII lookalikes)",
                        "evidence": f"Original: {line.strip()[:100]}",
                        "homoglyphs": char_info,
                        "category": "Obfuscation",
                    }
                )

    return findings


def check_markdown_injection(content: str, filepath: str) -> list[dict[str, Any]]:
    """Detect markdown-specific injection vectors."""
    findings: list[dict[str, Any]] = []
    lines = content.split("\n")

    for line_num, line in enumerate(lines, 1):
        # Reference-style link comments: [//]: # "hidden content"
        ref_comment = re.search(r'\[//\]:\s*#\s*["\'](.+?)["\']', line)
        if ref_comment:
            comment_content = ref_comment.group(1)
            # Check for injection patterns in hidden comment
            for pattern, description, severity in PROMPT_INJECTION_PATTERNS:
                if re.search(pattern, comment_content):
                    findings.append(
                        {
                            "type": "Markdown Comment Injection",
                            "severity": "critical",
                            "location": f"{filepath}:{line_num}",
                            "description": f"Markdown reference comment contains injection pattern: {description}",
                            "evidence": line.strip()[:200],
                            "category": "Prompt Injection",
                        }
                    )
                    break

        # Empty/invisible image tags that may trigger fetches
        empty_img = re.search(r"!\[\]\(([^)]+)\)", line)
        if empty_img:
            url = empty_img.group(1)
            if not url.startswith("#"):  # Ignore anchor-only refs
                findings.append(
                    {
                        "type": "Hidden Image Fetch",
                        "severity": "medium",
                        "location": f"{filepath}:{line_num}",
                        "description": f"Empty alt-text image may trigger silent fetch: {url[:100]}",
                        "category": "Hidden Content",
                    }
                )

        # Empty links that may contain tracking/exfil URLs
        empty_link = re.search(r"\[\]\(([^)]+)\)", line)
        if empty_link:
            url = empty_link.group(1)
            if url.startswith("http"):
                findings.append(
                    {
                        "type": "Hidden Link",
                        "severity": "medium",
                        "location": f"{filepath}:{line_num}",
                        "description": f"Empty link text with URL (potential tracking): {url[:100]}",
                        "category": "Hidden Content",
                    }
                )

    return findings


def check_secrets(content: str, filepath: str) -> list[dict[str, Any]]:
    """Detect hardcoded secrets."""
    findings: list[dict[str, Any]] = []
    lines = content.split("\n")

    for line_num, line in enumerate(lines, 1):
        for pattern, description, severity in SECRET_PATTERNS:
            if re.search(pattern, line):
                # Mask the actual secret in evidence
                evidence = line.strip()[:200]
                findings.append(
                    {
                        "type": "Secret Detected",
                        "severity": severity,
                        "location": f"{filepath}:{line_num}",
                        "description": description,
                        "evidence": evidence,
                        "category": "Secret Exposure",
                    }
                )
                break  # One finding per line

    return findings


def check_scripts(script_path: Path) -> list[dict[str, Any]]:
    """Analyze a script file for dangerous patterns."""
    findings: list[dict[str, Any]] = []
    try:
        content = script_path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return findings

    relative = script_path.name
    suffix = script_path.suffix.lower()
    lines = content.split("\n")

    # Select appropriate patterns based on file type
    patterns_to_check: list[tuple[str, str, str]] = []

    if suffix in (".py",):
        patterns_to_check = DANGEROUS_SCRIPT_PATTERNS
    elif suffix in (".rb",):
        patterns_to_check = DANGEROUS_RUBY_PATTERNS
    elif suffix in (".go",):
        patterns_to_check = DANGEROUS_GO_PATTERNS
    elif suffix in (".ps1", ".psm1", ".psd1"):
        patterns_to_check = DANGEROUS_POWERSHELL_PATTERNS
    elif suffix in (".sh", ".bash", ".zsh"):
        # Shell scripts use the general patterns plus some shell-specific
        patterns_to_check = DANGEROUS_SCRIPT_PATTERNS
    elif suffix in (".js", ".ts", ".mjs", ".cjs"):
        # JavaScript/TypeScript use the general patterns
        patterns_to_check = DANGEROUS_SCRIPT_PATTERNS
    else:
        # Unknown script type - use general patterns
        patterns_to_check = DANGEROUS_SCRIPT_PATTERNS

    for line_num, line in enumerate(lines, 1):
        for pattern, description, severity in patterns_to_check:
            if re.search(pattern, line):
                findings.append(
                    {
                        "type": "Dangerous Code Pattern",
                        "severity": severity,
                        "location": f"scripts/{relative}:{line_num}",
                        "description": description,
                        "evidence": line.strip()[:200],
                        "category": "Malicious Code",
                    }
                )
                break  # One finding per line

    return findings


def extract_urls(
    content: str, filepath: str
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    """Extract and categorize URLs, returning (urls, findings)."""
    urls: list[dict[str, Any]] = []
    findings: list[dict[str, Any]] = []

    # Match http(s), data:, and file:// URLs
    url_pattern = re.compile(
        r"(https?://[^\s\)\]\>\"'`]+|data:[^\s\)\]\>\"'`]+|file://[^\s\)\]\>\"'`]+)"
    )
    lines = content.split("\n")

    for line_num, line in enumerate(lines, 1):
        for match in url_pattern.finditer(line):
            url = match.group().rstrip(".,;:")

            # Handle data: URLs
            if url.startswith("data:"):
                # Check for suspicious data URLs (especially with base64 encoded content)
                if "base64" in url.lower():
                    # Try to decode and check for suspicious content
                    try:
                        # Extract base64 portion after "base64,"
                        b64_match = re.search(r"base64,(.+)", url)
                        if b64_match:
                            decoded = base64.b64decode(b64_match.group(1)).decode(
                                "utf-8", errors="ignore"
                            )
                            suspicious_keywords = [
                                "ignore",
                                "system",
                                "override",
                                "eval",
                                "exec",
                                "script",
                            ]
                            for kw in suspicious_keywords:
                                if kw.lower() in decoded.lower():
                                    findings.append(
                                        {
                                            "type": "Suspicious Data URL",
                                            "severity": "critical",
                                            "location": f"{filepath}:{line_num}",
                                            "description": f"data: URL contains base64-encoded content with suspicious keyword '{kw}'",
                                            "decoded_preview": decoded[:100],
                                            "category": "Obfuscation",
                                        }
                                    )
                                    break
                    except Exception:
                        pass

                findings.append(
                    {
                        "type": "Data URL",
                        "severity": "medium",
                        "location": f"{filepath}:{line_num}",
                        "description": "data: URL detected - can embed arbitrary content inline",
                        "evidence": url[:100] + ("..." if len(url) > 100 else ""),
                        "category": "Supply Chain",
                    }
                )
                continue

            # Handle file:// URLs
            if url.startswith("file://"):
                path_part = url[7:]  # Remove "file://"
                severity = (
                    "critical"
                    if any(
                        s in path_part.lower()
                        for s in [
                            ".ssh",
                            ".aws",
                            ".env",
                            "credentials",
                            "passwd",
                            "shadow",
                            "id_rsa",
                        ]
                    )
                    else "high"
                )

                findings.append(
                    {
                        "type": "File URL",
                        "severity": severity,
                        "location": f"{filepath}:{line_num}",
                        "description": f"file:// URL may access local filesystem: {path_part[:100]}",
                        "category": "Local File Access",
                    }
                )
                continue

            # Handle http(s) URLs
            try:
                # Extract domain
                domain = url.split("//", 1)[1].split("/", 1)[0].split(":")[0]
                # Check if root domain is trusted
                domain_parts = domain.split(".")
                root_domain = (
                    ".".join(domain_parts[-2:]) if len(domain_parts) >= 2 else domain
                )
                trusted = root_domain in TRUSTED_DOMAINS or domain in TRUSTED_DOMAINS

                # Check for URL shorteners
                is_shortener = root_domain in URL_SHORTENERS or domain in URL_SHORTENERS
                if is_shortener:
                    findings.append(
                        {
                            "type": "URL Shortener",
                            "severity": "high",
                            "location": f"{filepath}:{line_num}",
                            "description": f"URL shortener detected ({domain}) - final destination unknown, may hide malicious URLs",
                            "url": url,
                            "category": "Supply Chain",
                        }
                    )
                    trusted = False

            except (IndexError, ValueError):
                domain = "unknown"
                trusted = False

            urls.append(
                {
                    "url": url,
                    "domain": domain,
                    "trusted": trusted,
                    "location": f"{filepath}:{line_num}",
                }
            )

    return urls, findings


def check_structural_attacks(
    skill_dir: Path, content: str, frontmatter: dict[str, Any] | None
) -> list[dict[str, Any]]:
    """Detect structural attack patterns that go beyond text content."""
    findings: list[dict[str, Any]] = []

    # 1. Symlinks — files that resolve to paths outside the skill directory
    for path in skill_dir.rglob("*"):
        if path.is_symlink():
            target = path.resolve()
            is_internal = target.is_relative_to(skill_dir.resolve())
            findings.append(
                {
                    "type": "Symlink Detected",
                    "severity": "medium" if is_internal else "critical",
                    "location": str(path.relative_to(skill_dir)),
                    "description": f"Symlink points to {path.readlink()} (resolves to {str(target)}). "
                    "Symlinks can trick agents into reading sensitive files (e.g., ~/.ssh/id_rsa) "
                    "disguised as example/reference files.",
                    "category": "Symlink Exfiltration",
                }
            )

    # 2. YAML hook exploitation — hooks in frontmatter execute shell commands
    if frontmatter and "hooks" in frontmatter:
        hooks = frontmatter["hooks"]
        hook_types = hooks.keys() if isinstance(hooks, dict) else []
        for hook_type in hook_types:
            findings.append(
                {
                    "type": "Frontmatter Hooks",
                    "severity": "critical",
                    "location": "SKILL.md frontmatter",
                    "description": f"Skill defines '{hook_type}' hooks. Hooks execute shell commands "
                    "automatically on lifecycle events — the model cannot prevent execution. "
                    "Review all hook commands carefully.",
                    "category": "Hook Exploitation",
                }
            )

    # 3. !`command` pre-prompt injection — runs at template expansion time
    bang_pattern = re.compile(r"!\`[^`]+\`")
    for line_num, line in enumerate(content.split("\n"), 1):
        for match in bang_pattern.finditer(line):
            cmd = match.group()[2:-1]  # Strip !` and `
            findings.append(
                {
                    "type": "Pre-prompt Command",
                    "severity": "high",
                    "location": f"SKILL.md:{line_num}",
                    "description": f"!`command` syntax executes at skill load time before the model sees "
                    f"the prompt. Command: {cmd}",
                    "evidence": line.strip()[:200],
                    "category": "Pre-prompt Injection",
                }
            )

    # 4. Test file auto-discovery — conftest.py, test_*.py, *.test.js/ts
    test_patterns = {
        "conftest.py": "pytest auto-imports conftest.py at collection time — code runs before any tests",
        "test_*.py": "pytest discovers and runs test_*.py files automatically",
        "*_test.py": "pytest discovers and runs *_test.py files automatically",
        "*.test.js": "Jest/Vitest may discover .test.js files if dot:true glob is set",
        "*.test.ts": "Jest/Vitest may discover .test.ts files if dot:true glob is set",
    }
    for path in skill_dir.rglob("*"):
        if not path.is_file():
            continue
        name = path.name
        for pattern, desc in test_patterns.items():
            import fnmatch

            if fnmatch.fnmatch(name, pattern):
                findings.append(
                    {
                        "type": "Test File Auto-Discovery",
                        "severity": "high",
                        "location": str(path.relative_to(skill_dir)),
                        "description": f"{desc}. Bundled test files execute as a side effect of running "
                        "the test suite — review file contents for hidden payloads.",
                        "category": "Test File RCE",
                    }
                )

    # 5. npm postinstall — bundled package.json with lifecycle scripts
    for pkg_json in skill_dir.rglob("package.json"):
        try:
            pkg = json.loads(pkg_json.read_text(encoding="utf-8", errors="replace"))
        except (json.JSONDecodeError, OSError, ValueError):
            continue
        scripts = pkg.get("scripts") or {}
        lifecycle_hooks = [
            "preinstall",
            "install",
            "postinstall",
            "preuninstall",
            "postuninstall",
        ]
        for hook in lifecycle_hooks:
            if hook in scripts:
                findings.append(
                    {
                        "type": "npm Lifecycle Hook",
                        "severity": "critical",
                        "location": str(pkg_json.relative_to(skill_dir)),
                        "description": f"package.json defines '{hook}' script: {scripts[hook]}. "
                        "npm executes lifecycle hooks automatically on install — "
                        "this is a common supply chain attack vector.",
                        "category": "Supply Chain",
                    }
                )

    # 6. Image metadata — parse PNG chunks properly to find tEXt/iTXt metadata
    import struct

    for img_path in skill_dir.rglob("*.png"):
        try:
            data = img_path.read_bytes()
            # PNG files start with 8-byte signature, then chunks
            # Each chunk: 4-byte length (big-endian), 4-byte type, data, 4-byte CRC
            if data[:8] != b"\x89PNG\r\n\x1a\n":
                continue
            offset = 8
            while offset + 8 <= len(data):
                chunk_len = struct.unpack(">I", data[offset : offset + 4])[0]
                chunk_type = data[offset + 4 : offset + 8]
                chunk_data = data[offset + 8 : offset + 8 + chunk_len]

                keyword = ""
                value = ""
                if chunk_type == b"tEXt":
                    # tEXt: keyword\0text
                    parts = chunk_data.split(b"\x00", 1)
                    if len(parts) > 1:
                        keyword = parts[0].decode("ascii", errors="ignore")
                        value = parts[1][:200].decode("latin-1", errors="ignore")
                elif chunk_type == b"iTXt":
                    # iTXt: keyword\0comprFlag\0comprMethod\0langTag\0transKeyword\0text
                    parts = chunk_data.split(b"\x00", 4)
                    if len(parts) >= 5:
                        keyword = parts[0].decode("ascii", errors="ignore")
                        value = parts[4][:200].decode("utf-8", errors="ignore")

                if keyword and value.strip():
                    findings.append(
                        {
                            "type": "Image Metadata Text",
                            "severity": "high",
                            "location": str(img_path.relative_to(skill_dir)),
                            "description": f"PNG contains text metadata ('{keyword}'): {value[:100]}. "
                            "Hidden instructions in image metadata can be read by "
                            "multimodal LLMs when they inspect the file.",
                            "category": "Image Injection",
                        }
                    )

                # Advance to next chunk: length + type(4) + data + CRC(4)
                offset += 4 + 4 + chunk_len + 4
        except (OSError, struct.error):
            continue

    # 7. JPEG EXIF metadata — check for text in common EXIF fields
    for img_path in skill_dir.rglob("*.jpg"):
        findings.extend(check_jpeg_exif(img_path, skill_dir))
    for img_path in skill_dir.rglob("*.jpeg"):
        findings.extend(check_jpeg_exif(img_path, skill_dir))

    # 8. SVG files — can contain embedded scripts and external references
    for svg_path in skill_dir.rglob("*.svg"):
        findings.extend(check_svg_content(svg_path, skill_dir))

    return findings


def check_jpeg_exif(img_path: Path, skill_dir: Path) -> list[dict[str, Any]]:
    """Check JPEG files for suspicious EXIF metadata."""
    findings: list[dict[str, Any]] = []
    try:
        data = img_path.read_bytes()

        # JPEG starts with FF D8
        if data[:2] != b"\xff\xd8":
            return findings

        # Look for EXIF marker (FF E1) and extract ASCII text
        # This is a simplified check - looks for readable text in EXIF segments
        offset = 2
        while offset < len(data) - 4:
            if data[offset] != 0xFF:
                offset += 1
                continue

            marker = data[offset + 1]

            # APP1 marker (EXIF) = 0xE1
            if marker == 0xE1:
                segment_len = int.from_bytes(data[offset + 2 : offset + 4], "big")
                segment_data = data[offset + 4 : offset + 2 + segment_len]

                # Look for suspicious text patterns in the segment
                try:
                    text_content = segment_data.decode("utf-8", errors="ignore")
                    # Check for injection patterns
                    for pattern, description, severity in PROMPT_INJECTION_PATTERNS:
                        if re.search(pattern, text_content):
                            findings.append(
                                {
                                    "type": "JPEG EXIF Injection",
                                    "severity": "critical",
                                    "location": str(img_path.relative_to(skill_dir)),
                                    "description": f"JPEG EXIF metadata contains injection pattern: {description}",
                                    "category": "Image Injection",
                                }
                            )
                            break

                    # Check for any substantial text content
                    readable_text = re.findall(r"[\x20-\x7E]{20,}", text_content)
                    for text in readable_text:
                        if any(kw in text.lower() for kw in SECURITY_KEYWORDS):
                            findings.append(
                                {
                                    "type": "JPEG EXIF Text",
                                    "severity": "high",
                                    "location": str(img_path.relative_to(skill_dir)),
                                    "description": f"JPEG contains suspicious text in EXIF: {text[:100]}",
                                    "category": "Image Injection",
                                }
                            )
                            break
                except Exception:
                    pass

                offset += 2 + segment_len
            elif marker == 0xD9:  # End of image
                break
            elif marker in (0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0x01):
                # Standalone markers
                offset += 2
            elif 0xE0 <= marker <= 0xEF or marker == 0xFE:
                # APP markers or comment - skip
                segment_len = int.from_bytes(data[offset + 2 : offset + 4], "big")
                offset += 2 + segment_len
            else:
                offset += 2

    except (OSError, ValueError, IndexError):
        pass

    return findings


def check_svg_content(svg_path: Path, skill_dir: Path) -> list[dict[str, Any]]:
    """Check SVG files for embedded scripts and dangerous content."""
    findings: list[dict[str, Any]] = []
    try:
        content = svg_path.read_text(encoding="utf-8", errors="replace")
        rel_path = str(svg_path.relative_to(skill_dir))

        # Check for script tags
        script_pattern = re.compile(r"<script[^>]*>", re.IGNORECASE)
        if script_pattern.search(content):
            findings.append(
                {
                    "type": "SVG Script Tag",
                    "severity": "critical",
                    "location": rel_path,
                    "description": "SVG contains <script> tag - can execute JavaScript when viewed",
                    "category": "SVG Injection",
                }
            )

        # Check for event handlers (onclick, onload, onerror, etc.)
        event_pattern = re.compile(r'\bon\w+\s*=\s*["\']', re.IGNORECASE)
        if event_pattern.search(content):
            findings.append(
                {
                    "type": "SVG Event Handler",
                    "severity": "critical",
                    "location": rel_path,
                    "description": "SVG contains event handlers (onclick, onload, etc.) - can execute JavaScript",
                    "category": "SVG Injection",
                }
            )

        # Check for external references (xlink:href, href to external URLs)
        external_ref = re.compile(
            r'(?:xlink:)?href\s*=\s*["\'](?:https?://|//|data:)', re.IGNORECASE
        )
        for match in external_ref.finditer(content):
            findings.append(
                {
                    "type": "SVG External Reference",
                    "severity": "high",
                    "location": rel_path,
                    "description": f"SVG contains external reference: {match.group()[:100]}",
                    "category": "SVG Injection",
                }
            )

        # Check for foreignObject (can embed HTML)
        if re.search(r"<foreignObject", content, re.IGNORECASE):
            findings.append(
                {
                    "type": "SVG ForeignObject",
                    "severity": "high",
                    "location": rel_path,
                    "description": "SVG contains <foreignObject> - can embed arbitrary HTML/XHTML content",
                    "category": "SVG Injection",
                }
            )

        # Check for use tags pointing to external resources
        use_external = re.compile(
            r'<use[^>]+(?:xlink:)?href\s*=\s*["\'](?:https?://|//)', re.IGNORECASE
        )
        if use_external.search(content):
            findings.append(
                {
                    "type": "SVG External Use",
                    "severity": "high",
                    "location": rel_path,
                    "description": "SVG <use> element references external resource",
                    "category": "SVG Injection",
                }
            )

        # Check for embedded text that might contain injection patterns
        text_content = re.sub(r"<[^>]+>", " ", content)  # Strip tags
        for pattern, description, severity in PROMPT_INJECTION_PATTERNS:
            if re.search(pattern, text_content):
                findings.append(
                    {
                        "type": "SVG Text Injection",
                        "severity": "high",
                        "location": rel_path,
                        "description": f"SVG text content contains injection pattern: {description}",
                        "category": "Image Injection",
                    }
                )
                break

    except (OSError, UnicodeDecodeError):
        pass

    return findings


def compute_description_body_overlap(
    frontmatter: dict[str, Any] | None, body: str
) -> float:
    """Compute keyword overlap between description and body as a heuristic."""
    if (
        not frontmatter
        or "description" not in frontmatter
        or frontmatter["description"] is None
    ):
        return 0.0

    desc_words = set(re.findall(r"\b[a-z]{4,}\b", frontmatter["description"].lower()))
    body_words = set(re.findall(r"\b[a-z]{4,}\b", body.lower()))

    if not desc_words:
        return 0.0

    overlap = desc_words & body_words
    return len(overlap) / len(desc_words)


def check_package_dependencies(skill_dir: Path) -> list[dict[str, Any]]:
    """Analyze package dependencies for typosquatting and suspicious packages."""
    findings: list[dict[str, Any]] = []

    # Check Python scripts for PEP 723 inline dependencies
    scripts_dir = skill_dir / "scripts"
    if scripts_dir.is_dir():
        for script_file in scripts_dir.rglob("*.py"):
            try:
                content = script_file.read_text(encoding="utf-8", errors="replace")
                rel_path = str(script_file.relative_to(skill_dir))

                # Look for PEP 723 script metadata block
                # Format: # /// script\n# dependencies = [...]\n# ///
                pep723_match = re.search(
                    r"#\s*///\s*script\s*\n((?:#[^\n]*\n)*?)#\s*///",
                    content,
                    re.MULTILINE,
                )

                if pep723_match:
                    metadata_block = pep723_match.group(1)
                    # Extract dependencies line
                    deps_match = re.search(
                        r"#\s*dependencies\s*=\s*\[(.*?)\]", metadata_block, re.DOTALL
                    )
                    if deps_match:
                        deps_str = deps_match.group(1)
                        # Parse the dependency list
                        deps = re.findall(r'["\']([^"\']+)["\']', deps_str)
                        findings.extend(analyze_python_dependencies(deps, rel_path))

            except (OSError, UnicodeDecodeError):
                continue

    # Check for requirements.txt
    for req_file in skill_dir.rglob("requirements*.txt"):
        try:
            content = req_file.read_text(encoding="utf-8", errors="replace")
            rel_path = str(req_file.relative_to(skill_dir))
            deps = []
            for line in content.split("\n"):
                line = line.strip()
                if line and not line.startswith("#") and not line.startswith("-"):
                    # Extract package name (before any version specifier)
                    pkg_match = re.match(r"([a-zA-Z0-9_-]+)", line)
                    if pkg_match:
                        deps.append(pkg_match.group(1))
            findings.extend(analyze_python_dependencies(deps, rel_path))
        except (OSError, UnicodeDecodeError):
            continue

    # Check for pyproject.toml
    pyproject = skill_dir / "pyproject.toml"
    if pyproject.exists():
        try:
            content = pyproject.read_text(encoding="utf-8", errors="replace")
            rel_path = "pyproject.toml"
            # Simple extraction of dependencies (not full TOML parsing)
            deps_section = re.search(
                r"dependencies\s*=\s*\[(.*?)\]", content, re.DOTALL
            )
            if deps_section:
                deps = re.findall(r'["\']([^"\'>=<\[]+)', deps_section.group(1))
                findings.extend(analyze_python_dependencies(deps, rel_path))
        except (OSError, UnicodeDecodeError):
            pass

    # Check package.json for npm dependencies
    for pkg_json in skill_dir.rglob("package.json"):
        try:
            content = pkg_json.read_text(encoding="utf-8", errors="replace")
            rel_path = str(pkg_json.relative_to(skill_dir))
            pkg = json.loads(content)

            all_deps = []
            for dep_key in [
                "dependencies",
                "devDependencies",
                "peerDependencies",
                "optionalDependencies",
            ]:
                if dep_key in pkg and isinstance(pkg[dep_key], dict):
                    all_deps.extend(pkg[dep_key].keys())

            findings.extend(analyze_npm_dependencies(all_deps, rel_path))
        except (OSError, json.JSONDecodeError):
            continue

    return findings


def analyze_python_dependencies(deps: list[str], location: str) -> list[dict[str, Any]]:
    """Analyze Python dependencies for typosquatting and suspicious packages."""
    findings: list[dict[str, Any]] = []

    for dep in deps:
        # Normalize: lowercase and strip version specifiers
        dep_name = re.sub(r"[>=<\[\];].*$", "", dep).strip().lower()
        dep_normalized = dep_name.replace("-", "_").replace(".", "_")

        # Check if it's a known package
        known_normalized = {
            p.replace("-", "_").replace(".", "_").lower() for p in KNOWN_PYPI_PACKAGES
        }
        if dep_normalized in known_normalized:
            continue  # Known good package

        # Check for typosquatting patterns
        for pattern, replacement in TYPOSQUAT_PATTERNS:
            base_match = re.match(pattern, dep_name)
            if base_match:
                potential_target = re.sub(pattern, replacement, dep_name)
                potential_normalized = potential_target.replace("-", "_").replace(
                    ".", "_"
                )
                if potential_normalized in known_normalized:
                    findings.append(
                        {
                            "type": "Potential Typosquat",
                            "severity": "high",
                            "location": location,
                            "description": f"Package '{dep_name}' may be typosquatting '{potential_target}'",
                            "category": "Supply Chain",
                        }
                    )
                    break

        # Check for suspicious package name patterns
        suspicious_patterns = [
            (
                r"(requests|urllib|http|socket|crypto|ssh|aws|azure|gcp).*hack",
                "Contains 'hack' with sensitive library name",
            ),
            (r".*malware.*", "Contains 'malware' in name"),
            (r".*exploit.*", "Contains 'exploit' in name"),
            (r".*backdoor.*", "Contains 'backdoor' in name"),
            (r".*keylog.*", "Contains 'keylog' in name"),
            (r".*stealer.*", "Contains 'stealer' in name"),
        ]
        for pattern, desc in suspicious_patterns:
            if re.match(pattern, dep_name, re.IGNORECASE):
                findings.append(
                    {
                        "type": "Suspicious Package Name",
                        "severity": "critical",
                        "location": location,
                        "description": f"Package '{dep_name}': {desc}",
                        "category": "Supply Chain",
                    }
                )
                break

        # Levenshtein-like check: very similar to known package (edit distance 1-2)
        for known_pkg in KNOWN_PYPI_PACKAGES:
            known_norm = known_pkg.replace("-", "_").replace(".", "_").lower()
            if dep_normalized != known_norm and len(dep_normalized) == len(known_norm):
                # Same length, check character difference
                diff_count = sum(
                    1 for a, b in zip(dep_normalized, known_norm) if a != b
                )
                if diff_count == 1:
                    findings.append(
                        {
                            "type": "Potential Typosquat",
                            "severity": "high",
                            "location": location,
                            "description": f"Package '{dep_name}' differs by 1 character from known package '{known_pkg}'",
                            "category": "Supply Chain",
                        }
                    )
                    break

    return findings


def analyze_npm_dependencies(deps: list[str], location: str) -> list[dict[str, Any]]:
    """Analyze npm dependencies for suspicious patterns."""
    findings: list[dict[str, Any]] = []

    # Well-known npm packages
    known_npm = {
        "react",
        "vue",
        "angular",
        "svelte",
        "express",
        "fastify",
        "koa",
        "hapi",
        "lodash",
        "underscore",
        "ramda",
        "axios",
        "node-fetch",
        "got",
        "superagent",
        "typescript",
        "webpack",
        "vite",
        "esbuild",
        "rollup",
        "parcel",
        "babel",
        "jest",
        "mocha",
        "chai",
        "vitest",
        "playwright",
        "puppeteer",
        "cypress",
        "eslint",
        "prettier",
        "husky",
        "lint-staged",
        "commitlint",
        "next",
        "nuxt",
        "gatsby",
        "remix",
        "astro",
        "sveltekit",
        "mongoose",
        "sequelize",
        "prisma",
        "typeorm",
        "knex",
        "pg",
        "mysql2",
        "redis",
        "ioredis",
        "bull",
        "bullmq",
        "agenda",
        "socket.io",
        "ws",
        "graphql",
        "apollo-server",
        "urql",
        "dotenv",
        "commander",
        "yargs",
        "chalk",
        "ora",
        "inquirer",
        "uuid",
        "nanoid",
        "date-fns",
        "moment",
        "dayjs",
        "luxon",
        "zod",
        "yup",
        "joi",
        "ajv",
        "class-validator",
    }

    for dep in deps:
        dep_lower = dep.lower()

        # Check for suspicious patterns
        suspicious = [
            (r".*malware.*", "Contains 'malware' in name"),
            (r".*exploit.*", "Contains 'exploit' in name"),
            (r".*backdoor.*", "Contains 'backdoor' in name"),
            (r".*keylog.*", "Contains 'keylog' in name"),
        ]
        for pattern, desc in suspicious:
            if re.match(pattern, dep_lower):
                findings.append(
                    {
                        "type": "Suspicious Package Name",
                        "severity": "critical",
                        "location": location,
                        "description": f"npm package '{dep}': {desc}",
                        "category": "Supply Chain",
                    }
                )
                break

        # Check for typosquatting of known packages
        for known in known_npm:
            if dep_lower != known and len(dep_lower) == len(known):
                diff_count = sum(1 for a, b in zip(dep_lower, known) if a != b)
                if diff_count == 1:
                    findings.append(
                        {
                            "type": "Potential npm Typosquat",
                            "severity": "high",
                            "location": location,
                            "description": f"Package '{dep}' differs by 1 character from known package '{known}'",
                            "category": "Supply Chain",
                        }
                    )
                    break

    return findings


def scan_skill(skill_dir: Path) -> dict[str, Any]:
    """Run full scan on a skill directory."""
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return {"error": f"No SKILL.md found in {skill_dir}"}

    try:
        content = skill_md.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        return {"error": f"Cannot read SKILL.md: {e}"}

    frontmatter, body = parse_frontmatter(content)

    all_findings: list[dict[str, Any]] = []
    all_urls: list[dict[str, Any]] = []

    # 1. Frontmatter validation
    all_findings.extend(check_frontmatter(skill_dir, content))

    # 2. Prompt injection patterns in SKILL.md
    all_findings.extend(check_prompt_injection(content, "SKILL.md"))

    # 3. Obfuscation detection in SKILL.md
    all_findings.extend(check_obfuscation(content, "SKILL.md"))

    # 4. Secret detection in SKILL.md
    all_findings.extend(check_secrets(content, "SKILL.md"))

    # 5. URL extraction from SKILL.md
    skill_urls, url_findings = extract_urls(content, "SKILL.md")
    all_urls.extend(skill_urls)
    all_findings.extend(url_findings)

    # 6. Scan reference files
    refs_dir = skill_dir / "references"
    if refs_dir.is_dir():
        for ref_file in sorted(refs_dir.iterdir()):
            if ref_file.suffix == ".md":
                try:
                    ref_content = ref_file.read_text(encoding="utf-8", errors="replace")
                except OSError:
                    continue
                rel_path = f"references/{ref_file.name}"
                all_findings.extend(check_prompt_injection(ref_content, rel_path))
                all_findings.extend(check_obfuscation(ref_content, rel_path))
                all_findings.extend(check_secrets(ref_content, rel_path))
                ref_urls, ref_url_findings = extract_urls(ref_content, rel_path)
                all_urls.extend(ref_urls)
                all_findings.extend(ref_url_findings)

    # 7. Scan scripts
    scripts_dir = skill_dir / "scripts"
    script_findings: list[dict[str, Any]] = []
    # Expanded script extensions including Ruby, Go, PowerShell
    script_extensions = (
        ".py",
        ".sh",
        ".bash",
        ".zsh",  # Python and shell
        ".js",
        ".ts",
        ".mjs",
        ".cjs",  # JavaScript/TypeScript
        ".rb",  # Ruby
        ".go",  # Go
        ".ps1",
        ".psm1",
        ".psd1",  # PowerShell
    )
    if scripts_dir.is_dir():
        for script_file in sorted(scripts_dir.iterdir()):
            if script_file.suffix.lower() in script_extensions:
                sf = check_scripts(script_file)
                script_findings.extend(sf)
                try:
                    script_content = script_file.read_text(
                        encoding="utf-8", errors="replace"
                    )
                except OSError:
                    continue
                rel_path = f"scripts/{script_file.name}"
                all_findings.extend(check_secrets(script_content, rel_path))
                all_findings.extend(check_obfuscation(script_content, rel_path))
                script_urls, script_url_findings = extract_urls(
                    script_content, rel_path
                )
                all_urls.extend(script_urls)
                all_findings.extend(script_url_findings)

    all_findings.extend(script_findings)

    # 8. Structural attacks (symlinks, hooks, !command, test files, npm, image metadata)
    all_findings.extend(check_structural_attacks(skill_dir, content, frontmatter))

    # 9. Package dependency analysis (typosquatting, suspicious packages)
    all_findings.extend(check_package_dependencies(skill_dir))

    # 10. Description-body overlap
    overlap = compute_description_body_overlap(frontmatter, body)

    # Build structure info
    structure = {
        "has_skill_md": True,
        "has_references": (
            refs_dir.is_dir() if (refs_dir := skill_dir / "references") else False
        ),
        "has_scripts": (
            scripts_dir.is_dir() if (scripts_dir := skill_dir / "scripts") else False
        ),
        "reference_files": (
            sorted(
                f.name
                for f in (skill_dir / "references").iterdir()
                if f.suffix == ".md"
            )
            if (skill_dir / "references").is_dir()
            else []
        ),
        "script_files": (
            sorted(
                f.name
                for f in (skill_dir / "scripts").iterdir()
                if f.suffix.lower()
                in (
                    ".py",
                    ".sh",
                    ".bash",
                    ".zsh",
                    ".js",
                    ".ts",
                    ".mjs",
                    ".cjs",
                    ".rb",
                    ".go",
                    ".ps1",
                    ".psm1",
                    ".psd1",
                )
            )
            if (skill_dir / "scripts").is_dir()
            else []
        ),
    }

    # Summary counts
    severity_counts: dict[str, int] = {}
    for f in all_findings:
        sev = f.get("severity", "unknown")
        severity_counts[sev] = severity_counts.get(sev, 0) + 1

    untrusted_urls = [u for u in all_urls if not u["trusted"]]

    # Allowed tools analysis
    tools_info = None
    if frontmatter and "allowed-tools" in frontmatter:
        tools_str = frontmatter["allowed-tools"]
        if isinstance(tools_str, str):
            tools_list = [
                t.strip() for t in tools_str.replace(",", " ").split() if t.strip()
            ]
            tools_info = {
                "tools": tools_list,
                "has_bash": "Bash" in tools_list,
                "has_write": "Write" in tools_list,
                "has_edit": "Edit" in tools_list,
                "has_webfetch": "WebFetch" in tools_list,
                "has_task": "Task" in tools_list,
                "unrestricted": tools_str.strip() == "*",
            }

    return {
        "skill_name": frontmatter.get("name", "unknown") if frontmatter else "unknown",
        "skill_dir": str(skill_dir),
        "structure": structure,
        "frontmatter": frontmatter,
        "tools": tools_info,
        "findings": all_findings,
        "finding_counts": severity_counts,
        "total_findings": len(all_findings),
        "urls": {
            "total": len(all_urls),
            "untrusted": untrusted_urls,
            "trusted_count": len(all_urls) - len(untrusted_urls),
        },
        "description_body_overlap": round(overlap, 2),
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: scan_skill.py <skill-directory>", file=sys.stderr)
        sys.exit(1)

    skill_dir = Path(sys.argv[1]).resolve()
    if not skill_dir.is_dir():
        print(json.dumps({"error": f"Not a directory: {skill_dir}"}))
        sys.exit(1)

    result = scan_skill(skill_dir)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
