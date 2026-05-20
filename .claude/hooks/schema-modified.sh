#!/usr/bin/env bash
# PostToolUse hook — fires on every Edit/Write tool use.
# Extracts the file path from Claude Code's JSON stdin.
# If the file is a schema or seed SQL file, injects a verification reminder
# into Claude's context via additionalContext (option 1 — reaches Claude, not just transcript).
export PATH="/c/Python314:/c/Python314/Scripts:/usr/bin:/bin:$PATH"

tmp=$(mktemp)
cat > "$tmp"

PYTHON=$(command -v python 2>/dev/null || command -v python3 2>/dev/null || echo "")
tmp_win=$(cygpath -w "$tmp" 2>/dev/null || echo "$tmp")

file_path=$("$PYTHON" -c "
import sys, json
try:
    d = json.load(open(sys.argv[1]))
    fp = d.get('tool_input', {}).get('file_path', '')
    print(fp.replace(chr(92), '/'))
except:
    print('')
" "$tmp_win" 2>/dev/null)

rm -f "$tmp"

if echo "$file_path" | grep -qE "data/(schemas|seeds)/.*\.sql$"; then
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Schema or seed modified. Re-run make schema-verify against the aegis-pg container before declaring done."}}\n'
fi
