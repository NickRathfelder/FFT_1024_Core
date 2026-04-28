import math
import cmath
import os

N = 1024

def float_to_q3_12(value):
    """Convert float to Q3.12 fixed point (16-bit signed)"""
    scaled = int(round(value * (1 << 12)))
    scaled = max(-32768, min(32767, scaled))
    return scaled & 0xFFFF

# Relative path using os
script_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(script_dir, '..', 'memory')
os.makedirs(output_dir, exist_ok=True)

# Generate 512 twiddle factors: w0^k where w0 = e^(+j 2π/N), k=0 to N/2-1
w0 = cmath.exp(-2j * math.pi / N)  # Note: +j (positive angle)
twiddles = []
for k in range(N//2):  # k=0 to 511
    w = w0 ** k
    real_q = float_to_q3_12(w.real)
    imag_q = float_to_q3_12(w.imag)
    word = (real_q << 16) | imag_q
    binary = f'{word:032b}'
    twiddles.append(binary)

# Save 512 lines
filename = os.path.join(output_dir, 'twiddle_512x32_binary.mem')
with open(filename, 'w') as f:
    for line in twiddles:
        f.write(line + '\n')

print(f"Generated: {filename} (512 lines, k=0 to 511)")
print(f"Path: {os.path.relpath(filename, script_dir)}")
print("First 5 lines:")
for k in range(4):
    print(f"k={k}: {twiddles[k]}")

