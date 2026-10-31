#!/usr/bin/env python3
"""Run isolated Verilog-2005 simulations with Icarus Verilog."""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LAB4 = ['lab4/lab4.v', 'lab4/led_ctrl_unit.v', 'lab4/edge_detect.v', 'lab4/button_debounce.v']
LAB3 = ['lab3/flowing_water_lights.v', 'lab3/counter.v']
CASES = [
    ('lab1_course', 'mux_sim', ['lab1/mux.v', 'lab1/mux_sim.v']),
    ('lab1_exhaustive', 'mux_verify', ['lab1/mux.v', 'lab1/tests/mux_verify.v']),
    ('lab2_dff_course', 'testbench', ['lab2/dff/dff.v', 'lab2/dff/testbench.v']),
    ('lab2_dff_model', 'dff_verify', ['lab2/dff/dff.v', 'lab2/verification/dff_verify.v']),
    ('lab2_regfile_course', 'testbench', ['lab2/reg8file/reg8file.v', 'lab2/reg8file/testbench.v']),
    ('lab2_regfile_model', 'reg8file_verify', ['lab2/reg8file/reg8file.v', 'lab2/verification/reg8file_verify.v']),
    ('lab3_course', 'testbench', LAB3 + ['lab3/testbench.v']),
    ('lab3_model', 'full_verify', LAB3 + ['lab3/verification/full_verify.v']),
    ('lab4_course', 'testbench', LAB4 + ['lab4/testbench.v']),
    ('lab4_edge', 'edge_testbench', ['lab4/edge_detect.v', 'lab4/edge_testbench.v']),
    ('lab4_model', 'verify', LAB4 + ['lab4/verification/verify.v']),
]
DEFAULT_CASES = [
    ('lab3_default', 'default_timing_verify', LAB3 + ['lab3/verification/default_timing_verify.v']),
    ('lab4_default', 'default_verify', LAB4 + ['lab4/verification/default_verify.v']),
]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--full', action='store_true', help='also verify board timing defaults')
    args = parser.parse_args()
    for tool in ('iverilog', 'vvp'):
        if not shutil.which(tool):
            parser.error(f'{tool} is required on PATH')
    cases = CASES + (DEFAULT_CASES if args.full else [])
    for name, top, sources in cases:
        work = ROOT / 'build' / name
        work.mkdir(parents=True, exist_ok=True)
        executable = work / 'simulation.vvp'
        print(f'Running {name}', flush=True)
        compile_run = subprocess.run(
            ['iverilog', '-g2005', '-Wall', '-s', top, '-o', str(executable)]
            + [str(ROOT / source) for source in sources],
            cwd=work, capture_output=True, text=True, timeout=60)
        (work / 'compile.log').write_text(compile_run.stdout + compile_run.stderr)
        compile_run.check_returncode()
        simulation = subprocess.run(['vvp', str(executable)], cwd=work,
                                    capture_output=True, text=True, timeout=300)
        (work / 'simulation.log').write_text(simulation.stdout + simulation.stderr)
        print(simulation.stdout, end='')
        simulation.check_returncode()
    print(f'PASS: {len(cases)} simulations completed.')
    return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except (subprocess.SubprocessError, OSError) as error:
        print(f'FAIL: {error}; inspect build/<case>/*.log', file=sys.stderr)
        sys.exit(1)
