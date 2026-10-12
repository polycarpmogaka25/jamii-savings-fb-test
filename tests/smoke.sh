#!/usr/bin/env bash
set -euo pipefail
BASE="${MI_BASE:-http://localhost:8290}"
check() { local expected="$1"; shift; local got; got=$(curl -sS -o /tmp/jamii-smoke.json -w '%{http_code}' "$@"); test "$got" = "$expected" || { cat /tmp/jamii-smoke.json; echo "Expected $expected got $got" >&2; exit 1; }; }
check 200 "$BASE/accounts/100001/balance"
check 404 "$BASE/accounts/999999/balance"
check 400 "$BASE/accounts/abc/balance"
check 400 -H 'Content-Type: application/json' -d '{"income":-1,"debt":0}' "$BASE/loans/eligibility"
echo 'MI smoke checks passed'
