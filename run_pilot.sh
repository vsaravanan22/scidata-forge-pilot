#!/usr/bin/env bash
# Reproduce the SciData-Forge correspondence-test pilot end to end.
# Usage: ./run_pilot.sh            (uses 2 threads by default)
#        OMP_NUM_THREADS=8 ./run_pilot.sh
set -euo pipefail
cd "$(dirname "$0")"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-2}"
export PYSCF_MAX_MEMORY="${PYSCF_MAX_MEMORY:-4000}"
mkdir -p results

start=$(date +%s)
python scripts/01_build_structures.py
python scripts/02_compute.py
python scripts/03_analyze.py
end=$(date +%s)

python - "$start" "$end" <<'EOF'
import json, sys, platform, os
from importlib.metadata import version
start, end = map(int, sys.argv[1:3])
info = {
    "wall_time_minutes": round((end - start) / 60, 1),
    "omp_num_threads": os.environ.get("OMP_NUM_THREADS"),
    "cpu_count": os.cpu_count(),
    "python": platform.python_version(),
    "platform": platform.platform(),
    "packages": {p: version(p) for p in ["pyscf", "rdkit", "pyberny", "numpy", "scipy", "pandas"]},
}
json.dump(info, open("results/run_info.json", "w"), indent=2)
print(json.dumps(info, indent=2))
EOF
