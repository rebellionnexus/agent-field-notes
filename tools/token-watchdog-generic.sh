#!/bin/bash
# ============================================================================
# TOKEN WATCHDOG — Context Window Monitor for OpenClaw Agents
# ============================================================================
# Generic version — adapt the CONFIG section to your setup.
#
# Monitors all active OpenClaw agent sessions and alerts before compaction.
# Three-tier system: WARNING (50%), CRITICAL (75%), EMERGENCY (85%)
#
# Usage:
#   ./token-watchdog-generic.sh              # Normal run (from scheduler)
#   ./token-watchdog-generic.sh --check      # Manual check, prints to stdout
#   ./token-watchdog-generic.sh --check --agent <id>   # Check specific agent
#
# Schedule with launchd (macOS) or cron/systemd (Linux).
# DO NOT schedule inside OpenClaw — monitor externally.
#
# Requires: openclaw CLI, jq
# ============================================================================

set -euo pipefail

# === CONFIG — EDIT THESE ===

# Alert thresholds (percentage of context window)
WARN_PCT=50
CRITICAL_PCT=75
EMERGENCY_PCT=85

# Where to store state and logs
STATE_DIR="/tmp/openclaw/watchdog"
LOG_FILE="/tmp/openclaw/token-watchdog.log"

# How to send alerts. This example uses OpenClaw's Telegram integration.
# Replace with your own alerting (Slack webhook, email, ntfy, etc.)
ALERT_ACCOUNT="your-telegram-account"    # OpenClaw Telegram account ID
ALERT_TARGET="your-chat-id"             # Telegram chat ID for alerts

# Agent registry — map agent IDs to friendly names
# Add your agents here.
agent_name() {
    case "$1" in
        main)   echo "Main Agent" ;;
        *)      echo "$1" ;;
    esac
}

# Agent workspaces — where to write emergency flag files
# Set to "" for agents without a known workspace.
agent_workspace() {
    case "$1" in
        main)   echo "$HOME/.openclaw/workspace" ;;
        *)      echo "" ;;
    esac
}

# Backup commands — called at EMERGENCY tier.
# Replace with your own backup logic, or leave empty to skip.
run_emergency_backup() {
    local agent_id="$1"
    # Example: backup workspace to a safe location
    # cp -r "$HOME/.openclaw/workspace" "/path/to/backups/$(date +%Y%m%d_%H%M%S)/"
    log "  Backup: implement run_emergency_backup() for ${agent_id}"
}

# === END CONFIG ===

# === FLAGS ===
CHECK_MODE=false
FILTER_AGENT=""

while [ $# -gt 0 ]; do
    case "$1" in
        --check|-c) CHECK_MODE=true; shift ;;
        --agent|-a) FILTER_AGENT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# === INTERNALS ===
mkdir -p "$STATE_DIR"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    if [ "$CHECK_MODE" = true ]; then
        echo "$msg"
    else
        echo "$msg" >> "$LOG_FILE"
    fi
}

send_alert() {
    local msg="$1"
    if [ "$CHECK_MODE" = true ]; then
        echo "  [ALERT] $msg"
    else
        openclaw message send \
            --channel telegram \
            --account "$ALERT_ACCOUNT" \
            -t "$ALERT_TARGET" \
            -m "$msg" 2>/dev/null || {
            log "WARN: Alert send failed"
        }
    fi
}

state_file_for() {
    echo "${STATE_DIR}/$(echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g').json"
}

read_state() {
    local sf
    sf=$(state_file_for "$1")
    if [ -f "$sf" ]; then
        cat "$sf"
    else
        echo '{"level":"none","session_id":"","percent":0,"tokens":0}'
    fi
}

write_state() {
    local key="$1" level="$2" pct="$3" tokens="$4" session_id="$5"
    local sf
    sf=$(state_file_for "$key")
    cat > "$sf" << EOF
{
  "level": "$level",
  "percent": $pct,
  "tokens": $tokens,
  "session_id": "$session_id",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# === QUERY SESSIONS ===

SESSIONS_JSON=$(openclaw sessions --json 2>/dev/null) || {
    log "ERROR: Failed to query openclaw sessions. Gateway may be down."
    exit 1
}

# Filter to interactive sessions only (skip cron/ephemeral)
INTERACTIVE_SESSIONS=$(echo "$SESSIONS_JSON" | jq -c '
    [.sessions[] | select(
        (.key | test(":cron:") | not) and
        (.key | test(":run:") | not) and
        (.totalTokens > 0)
    )]
')

SESSION_COUNT=$(echo "$INTERACTIVE_SESSIONS" | jq 'length')

if [ "$SESSION_COUNT" -eq 0 ]; then
    log "No active interactive sessions."
    exit 0
fi

log "Checking ${SESSION_COUNT} session(s)..."

# === PROCESS EACH SESSION ===

echo "$INTERACTIVE_SESSIONS" | jq -c '.[]' | while IFS= read -r session; do
    KEY=$(echo "$session" | jq -r '.key')
    TOTAL_TOKENS=$(echo "$session" | jq -r '.totalTokens // 0')
    CONTEXT_TOKENS=$(echo "$session" | jq -r '.contextTokens // 200000')
    SESSION_ID=$(echo "$session" | jq -r '.sessionId // ""')
    MODEL=$(echo "$session" | jq -r '.model // "unknown"')

    AGENT_ID=$(echo "$KEY" | cut -d: -f2)
    NAME=$(agent_name "$AGENT_ID")
    WORKSPACE=$(agent_workspace "$AGENT_ID")

    # Filter if requested
    if [ -n "$FILTER_AGENT" ] && [ "$AGENT_ID" != "$FILTER_AGENT" ]; then
        continue
    fi

    SESSION_TYPE=$(echo "$KEY" | cut -d: -f3-)
    PCT=$((TOTAL_TOKENS * 100 / CONTEXT_TOKENS))

    PREV_STATE=$(read_state "$KEY")
    LAST_LEVEL=$(echo "$PREV_STATE" | jq -r '.level // "none"')
    LAST_SESSION=$(echo "$PREV_STATE" | jq -r '.session_id // ""')

    # New session — reset alerts
    if [ "$SESSION_ID" != "$LAST_SESSION" ] && [ -n "$LAST_SESSION" ]; then
        log "  ${NAME}: New session detected. Resetting."
        LAST_LEVEL="none"
        [ -n "$WORKSPACE" ] && rm -f "${WORKSPACE}/EMERGENCY-CONTEXT.md"
    fi

    log "  ${NAME} [${SESSION_TYPE}]: ${TOTAL_TOKENS}/${CONTEXT_TOKENS} (${PCT}%) on ${MODEL} — last: ${LAST_LEVEL}"

    if [ "$PCT" -ge "$EMERGENCY_PCT" ]; then
        if [ "$LAST_LEVEL" != "emergency" ]; then
            log "  EMERGENCY: ${NAME} at ${PCT}%"
            run_emergency_backup "$AGENT_ID"

            if [ -n "$WORKSPACE" ] && [ -d "$WORKSPACE" ]; then
                cat > "${WORKSPACE}/EMERGENCY-CONTEXT.md" << EMERGEOF
# EMERGENCY — CONTEXT AT ${PCT}%

**Agent:** ${NAME}
**Triggered:** $(date)
**Tokens:** ${TOTAL_TOKENS} / ${CONTEXT_TOKENS} (${MODEL})

STOP. Save your state. Close this session. Start fresh.
Delete this file after closing properly.
EMERGEOF
            fi

            send_alert "EMERGENCY: ${NAME} at ${PCT}% (${TOTAL_TOKENS}/${CONTEXT_TOKENS} on ${MODEL}). End this session NOW."
            write_state "$KEY" "emergency" "$PCT" "$TOTAL_TOKENS" "$SESSION_ID"
        fi

    elif [ "$PCT" -ge "$CRITICAL_PCT" ]; then
        if [ "$LAST_LEVEL" != "critical" ] && [ "$LAST_LEVEL" != "emergency" ]; then
            log "  CRITICAL: ${NAME} at ${PCT}%"
            send_alert "CRITICAL: ${NAME} at ${PCT}% (${TOTAL_TOKENS}/${CONTEXT_TOKENS} on ${MODEL}). Close protocol needed."
            write_state "$KEY" "critical" "$PCT" "$TOTAL_TOKENS" "$SESSION_ID"
        fi

    elif [ "$PCT" -ge "$WARN_PCT" ]; then
        if [ "$LAST_LEVEL" = "none" ]; then
            log "  WARNING: ${NAME} at ${PCT}%"
            send_alert "Heads up: ${NAME} at ${PCT}% (${TOTAL_TOKENS}/${CONTEXT_TOKENS} on ${MODEL}). Wrap up at a natural break."
            write_state "$KEY" "warning" "$PCT" "$TOTAL_TOKENS" "$SESSION_ID"
        fi

    else
        if [ "$LAST_LEVEL" != "none" ]; then
            log "  Clear: ${NAME} reset from ${LAST_LEVEL}"
            [ -n "$WORKSPACE" ] && rm -f "${WORKSPACE}/EMERGENCY-CONTEXT.md"
        fi
        write_state "$KEY" "none" "$PCT" "$TOTAL_TOKENS" "$SESSION_ID"
    fi
done

# === CHECK MODE SUMMARY ===

if [ "$CHECK_MODE" = true ]; then
    echo ""
    echo "=== TOKEN WATCHDOG ==="
    echo "$INTERACTIVE_SESSIONS" | jq -r '.[] |
        "\(.key | split(":")[1]) [\(.key | split(":")[2:] | join(":"))] — \(.totalTokens)/\(.contextTokens) (\(.totalTokens * 100 / .contextTokens)%) on \(.model)"' |
        sed 's/^/  /'
    echo ""
    echo "  Thresholds: WARNING=${WARN_PCT}% | CRITICAL=${CRITICAL_PCT}% | EMERGENCY=${EMERGENCY_PCT}%"
    echo "======================"
fi
