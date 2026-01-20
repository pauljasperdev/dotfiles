#!/bin/bash
# GSD Security Gate Hook - Enforces security checklist during verify-work

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loops
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  echo '{"decision": null}'
  exit 0
fi

# Check if this is a verify-work context (has UAT.md being worked on)
if [ ! -f ".planning/codebase/SECURITY-CHECKLIST.md" ]; then
  echo '{"decision": null}'
  exit 0
fi

# Check transcript for security review activity
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  SECURITY_REVIEWED=$(grep -l "SECURITY-CHECKLIST\|security review\|SECURITY-REVIEW.md" "$TRANSCRIPT_PATH" 2>/dev/null)

  if [ -z "$SECURITY_REVIEWED" ]; then
    # Security checklist not worked through - check if this looks like verify-work
    UAT_CONTEXT=$(grep -l "UAT\|verify-work\|verification" "$TRANSCRIPT_PATH" 2>/dev/null)

    if [ -n "$UAT_CONTEXT" ]; then
      cat <<EOF
{
  "decision": "block",
  "reason": "MANDATORY: Before completing verification, you must work through the security checklist. Read .planning/codebase/SECURITY-CHECKLIST.md, review changed files against each category, and log findings to .planning/codebase/SECURITY-REVIEW.md. Critical/High/Medium findings block completion."
}
EOF
      exit 0
    fi
  fi
fi

echo '{"decision": null}'
exit 0
