#!/usr/bin/env bash
# Install ProgramLab tasks into ProgramBench and pull their cleanroom images.
# Usage: bash setup.sh [REGEX]   (default: all tasks; J=8 parallel pulls)
set -euo pipefail
DIR=${PROGRAMLAB_DIR:-$HOME/.cache/programlab}
export REPO=ghcr.io/programlab-agent
hf download Program-Lab/ProgramLab tasks.tar.gz instances.jsonl --repo-type dataset \
  --revision "${PROGRAMLAB_REVISION:-main}" --local-dir "$DIR" >/dev/null
tar -xzf "$DIR/tasks.tar.gz" -C "$(python3 -c 'import programbench.constants as c; print(c.TASKS_DIR)')"
grep -o '"instance_id": "[^"]*"' "$DIR/instances.jsonl" | cut -d'"' -f4 | grep -E "${1:-.}" |
  xargs -P "${J:-8}" -I% bash -euc '
    image="$REPO/${1//__/_1776_}:task_cleanroom_v6"
    docker image inspect "$image" >/dev/null 2>&1 ||
      { docker pull -q "$REPO/programlab:$1" >/dev/null && docker tag "$REPO/programlab:$1" "$image"; }
    echo "ready $1"' _ %
cat <<EOF
Done. Set these before running ProgramBench:
  export PROGRAMBENCH_DOCKER_ORG=$REPO
  export PROGRAMBENCH_HF_REPO=Program-Lab/ProgramLab-Tests
EOF
