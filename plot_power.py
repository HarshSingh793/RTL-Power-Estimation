import numpy as np
import matplotlib.pyplot as plt

# Constants
I_static = 0.005  # Static current in Amperes
C_load = 10e-9    # Load capacitance in Farads (10nF)
f = 1e6           # Frequency in Hz (1 MHz)

# Original data points for 10 Vdd values (1-10V)
Vdd_10 = np.arange(1, 11)
P_total_10 = []

for V in Vdd_10:
    P_static = V * I_static
    P_dynamic = C_load * V**2 * f
    P_total = P_static + P_dynamic
    P_total_10.append(P_total)

# New data points for 50 Vdd values (1-50V)
Vdd_50 = np.arange(1, 51)
P_total_50 = []

for V in Vdd_50:
    P_static = V * I_static
    P_dynamic = C_load * V**2 * f
    P_total = P_static + P_dynamic
    P_total_50.append(P_total)

# Combine both sets of data
Vdd = np.concatenate((Vdd_10, Vdd_50))
P_total = np.concatenate((P_total_10, P_total_50))

# Plot the graph
plt.figure(figsize=(10, 6))
plt.plot(Vdd, P_total, marker='o', linestyle='-', color='b')

# Labeling
plt.title('Vdd vs Total Power')
plt.xlabel('Vdd (V)')
plt.ylabel('Total Power (W)')
plt.grid(True)

# Save the plot as a PNG image
plt.savefig('vdd_vs_power.png')

# Show the plot
plt.show()

print("Graph generated and saved as 'vdd_vs_power.png'")
