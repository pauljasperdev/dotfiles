set -e

opencode run \
"1. Decide which task to work on next. \
This should be the one YOU decide has the highest priority, \
- not necessarily the first in the list. \
2. fomat code via `uv run poe format`, lint via `uv run poe lint` \
run tests `uv run poe test` \
3. Append your progress to the progress.txt file. \
4. Mark as passes: true in prd.json if requirements and verification are met. \
5. Make a git commit of that feature. \
\
ONLY WORK ON A SINGLE FEATURE. \
\
If, while implementing the feature, you notice that all work \
is complete, output <promise>COMPLETE</promise>."
  --model openai/gpt-5.1-codex \
  --files prd.json progress.txt \
  --log-level debug
