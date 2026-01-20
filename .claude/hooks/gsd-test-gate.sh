#!/bin/bash
# GSD Test Gate Hook - Blocks subagent completion until tests pass

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loops
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  echo '{"decision": null}'
  exit 0
fi

# Check if this looks like a GSD execution (has .planning/ artifacts)
if [ ! -d ".planning" ]; then
  echo '{"decision": null}'
  exit 0
fi

# Check if TESTING.md exists (project has testing requirements)
if [ ! -f ".planning/codebase/TESTING.md" ]; then
  echo '{"decision": null}'
  exit 0
fi

# Read transcript to check for test execution
# Look for common test command patterns in the conversation
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  # Check if tests were mentioned as run
  TEST_RUN=$(grep -l "pnpm test\|npm test\|pnpm check\|npm run lint\|vitest\|jest" "$TRANSCRIPT_PATH" 2>/dev/null)

  # Check for test failures
  TEST_FAIL=$(grep -l "FAIL\|failed\|Error:\|✗\|error TS" "$TRANSCRIPT_PATH" 2>/dev/null)

  if [ -z "$TEST_RUN" ]; then
    # Tests weren't run - block and request
    cat <<EOF
{
  "decision": "block",
  "reason": "MANDATORY: Before completing this plan, you must run the project tests from .planning/codebase/TESTING.md. Run the test commands (pnpm check, pnpm test:unit, etc.) and ensure they pass. If tests fail, fix the issues before completing."
}
EOF
    exit 0
  fi

  if [ -n "$TEST_FAIL" ]; then
    # Tests were run but failed - block and request fix
    cat <<EOF
{
  "decision": "block",
  "reason": "Tests failed. You must fix the failing tests before completing this plan. Review the test output, fix the issues, and re-run tests until they pass."
}
EOF
    exit 0
  fi
fi

# Tests were run and passed (or couldn't determine) - allow completion
echo '{"decision": null}'
exit 0
