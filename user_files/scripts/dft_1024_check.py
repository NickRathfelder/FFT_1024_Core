import numpy as np
import os

# Parameters
N = 1024  # DFT size
pattern = np.array([1, 1, 1, 1, 0, 0, 0 ,0])  # Base sequence
repeats = 128  # Number of repetitions
assert len(pattern) * repeats == N, "Sequence length must be 1024"

# Generate the full time-domain sequence by repeating the pattern
x = np.tile(pattern, repeats)

# Compute the DFT: X[k] = sum_{n=0}^{N-1} x[n] * exp(-j*2*pi*k*n/N)
X = np.zeros(N, dtype=complex)
for k in range(N):
    for n in range(N):
        X[k] += x[n] * np.exp(-2j * np.pi * k * n / N)

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(script_dir, 'dft_1024_results.csv')

# Create array with k, real, imag columns - rounded to 2 decimal places
k_values = np.arange(N).reshape(-1, 1)
real_rounded = np.round(np.real(X), 2)
imag_rounded = np.round(np.imag(X), 2)
results = np.column_stack((k_values, real_rounded, imag_rounded))

# Save DFT results to CSV with k column, rounded values
np.savetxt(csv_path, 
           results, 
           delimiter=',', 
           header='k,real,imag', 
           comments='',
           fmt=['%d', '%.2f', '%.2f'])

print(f"DFT results saved to: {csv_path}")
print("Columns: k (bin index), real part (2 decimals), imaginary part (2 decimals)")
print(f"File shape: {N} rows x 3 columns")
print("\nSample (first 5 bins):")
print("k | real   | imag")
for k in range(5):
    print(f"{k} | {np.real(X[k]):6.2f} | {np.imag(X[k]):6.2f}")
