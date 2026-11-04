#!/usr/bin/env bash
# Points Claude Code at OpenRouter with the student's key. Runs on create and on every start.
# The key comes from the Codespaces secret OPENROUTER_API_KEY (never from this repo).
# HACKATHON_MODEL overrides the model (default below). Safe to run again.
set -u

MODEL="${HACKATHON_MODEL:-deepseek/deepseek-v4.1-flash}"
# Pasted keys often carry a stray space or line break; strip all white space.
KEY="$(printf '%s' "${OPENROUTER_API_KEY:-}" | tr -d '[:space:]')"
WORKSPACE="${WORKSPACE_DIR:-$PWD}"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

if [ -z "$KEY" ]; then
  echo "SETUP PROBLEM: no hackathon key found. Open START-HERE.md and follow 'Add your key'."
  exit 0
fi
case "$KEY" in
  sk-or-*) ;;
  *) echo "SETUP PROBLEM: the key does not start with sk-or-. Copy it again from your welcome email."; exit 0 ;;
esac

mkdir -p "$CONFIG_DIR"
# Key and model go through the environment, not the command line, so they never show in process lists.
HK_KEY="$KEY" HK_MODEL="$MODEL" HK_WS="$WORKSPACE" HK_CFG="$CONFIG_DIR" HK_HOME="$HOME" node -e '
const fs = require("fs"), path = require("path");
const e = process.env;
const settingsFile = path.join(e.HK_CFG, "settings.json");
let s = {};
try { s = JSON.parse(fs.readFileSync(settingsFile, "utf8")); } catch (_) {}
s.env = Object.assign(s.env || {}, {
  ANTHROPIC_BASE_URL: "https://openrouter.ai/api",
  ANTHROPIC_AUTH_TOKEN: e.HK_KEY,
  ANTHROPIC_API_KEY: "",
  ANTHROPIC_DEFAULT_OPUS_MODEL: e.HK_MODEL,
  ANTHROPIC_DEFAULT_SONNET_MODEL: e.HK_MODEL,
  ANTHROPIC_DEFAULT_HAIKU_MODEL: e.HK_MODEL,
  CLAUDE_CODE_SUBAGENT_MODEL: e.HK_MODEL,
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1",
  CLAUDE_CODE_MAX_OUTPUT_TOKENS: "32000",
  ENABLE_TOOL_SEARCH: "false"
});
s.model = e.HK_MODEL;
s.permissions = Object.assign(s.permissions || {}, { defaultMode: "acceptEdits" });
fs.writeFileSync(settingsFile, JSON.stringify(s, null, 2));
fs.chmodSync(settingsFile, 0o600);

const stateFile = e.HK_CFG === path.join(e.HK_HOME, ".claude")
  ? path.join(e.HK_HOME, ".claude.json") : path.join(e.HK_CFG, ".claude.json");
let j = {};
try { j = JSON.parse(fs.readFileSync(stateFile, "utf8")); } catch (_) {}
j.hasCompletedOnboarding = true;
j.projects = j.projects || {};
j.projects[e.HK_WS] = Object.assign(j.projects[e.HK_WS] || {}, { hasTrustDialogAccepted: true });
fs.writeFileSync(stateFile, JSON.stringify(j, null, 2));
' || { echo "SETUP PROBLEM: could not write the Claude Code settings."; exit 0; }

echo "Setup done. Open a terminal and type: claude"
