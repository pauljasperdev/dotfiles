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
    echo "You MUST obey by the mandatory procedures."
    echo ""
    echo ""
    echo "### Skills"
    echo ""
    echo "You must check your available skills and use them if applicable"
    echo ""
  fi
fi

# For verify-work: inject security checklist
if echo "$PROMPT" | grep -qE '/gsd:verify-work'; then
  if [ -f ".planning/codebase/TESTING.md" ]; then
    echo "### Testing Requirements (from .planning/codebase/TESTING.md)"
    echo ""
    echo "You MUST obey by the mandatory procedures."
    echo "### Security Review Requirements (from .planning/codebase/SECURITY-CHECKLIST.md)"
    echo ""
  fi
fi

# For plan-phase: remind to include testing in verification
if echo "$PROMPT" | grep -qE '/gsd:plan-phase'; then
  if [ -f ".planning/codebase/TESTING.md" ]; then
    echo "### Planning Reminder"
    echo ""
    echo "Include testing verification and security checks in every plan's <verification> section."
    echo "Read .planning/codebase/TESTING.md for project test commands."
    echo ""
    echo "### Skills"
    echo ""
    echo "You must check your available skills and mention them to be used in plan"
    echo ""
  fi
fi

exit 0
