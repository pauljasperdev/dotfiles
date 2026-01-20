#!/bin/bash
# GSD Prompt Inject Hook - Injects testing/security requirements into GSD commands

# Read the user's prompt from stdin
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Check if this is a GSD command
if ! echo "$PROMPT" | grep -qE '/gsd:(execute-plan|verify-work|plan-phase|execute-phase)'; then
  exit 0  # Not a GSD command, skip
fi

# Output procedures based on command type
echo "## MANDATORY PROCEDURES"
echo ""

# For execute-plan and execute-phase: inject testing requirements
if echo "$PROMPT" | grep -qE '/gsd:(execute-plan|execute-phase)'; then
  if [ -f ".planning/codebase/TESTING.md" ]; then
    echo "### Testing Requirements (from .planning/codebase/TESTING.md)"
    echo ""
    echo "Before marking any plan complete, you MUST run these tests:"
    echo ""
    # Extract test commands from TESTING.md
    grep -E '^\s*-?\s*\`?(pnpm|npm|yarn|bun)\s+(test|check|lint|verify)' .planning/codebase/TESTING.md 2>/dev/null | head -10 || echo "- Read .planning/codebase/TESTING.md for test commands"
    echo ""
    echo "If tests fail, DO NOT mark the plan as complete. Fix the issues first."
    echo ""
  fi
fi

# For verify-work: inject security checklist
if echo "$PROMPT" | grep -qE '/gsd:verify-work'; then
  if [ -f ".planning/codebase/SECURITY-CHECKLIST.md" ]; then
    echo "### Security Review Requirements (from .planning/codebase/SECURITY-CHECKLIST.md)"
    echo ""
    echo "Before completing verification, work through the security checklist:"
    echo ""
    echo "1. Read .planning/codebase/SECURITY-CHECKLIST.md"
    echo "2. Review files changed in this phase against each category"
    echo "3. Log any findings to .planning/codebase/SECURITY-REVIEW.md"
    echo "4. Critical/High/Medium findings BLOCK completion"
    echo ""
  fi
fi

# For plan-phase: remind to include testing in verification
if echo "$PROMPT" | grep -qE '/gsd:plan-phase'; then
  if [ -f ".planning/codebase/TESTING.md" ]; then
    echo "### Planning Reminder"
    echo ""
    echo "Include testing verification in every plan's <verification> section."
    echo "Read .planning/codebase/TESTING.md for project test commands."
    echo ""
  fi
fi

exit 0
