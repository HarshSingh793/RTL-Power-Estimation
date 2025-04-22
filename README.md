# RTL-Power-Estimation
Scripting Languages and Verification - BEVD205L
1.1	OBJECTIVE and GOALS

The primary objective of this project is to develop a scripting-based tool that performs early-stage power estimation at the RTL (Register Transfer Level) for digital circuits described in Verilog. The tool aims to automate the power analysis process, offering designers early insights into the power characteristics of their designs, thus enabling informed design decisions for power-efficient VLSI systems.
Goals: 
- Design a User-Friendly GUI Interface using TCl/tk
- Automate Verilog Parsing using perl.
-Estimate Dynamic Power, Leakage Power, and Clock Power using analytical models.
-Incorporate toggle factor heuristics and technology-dependent parameters.
-Allow users to select from common nodes (e.g., 180nm, 90nm, 45nm), adapting the model parameters accordingly.
-Export results in both CSV and text formats for easy interpretation and record-keeping. 
-Highlight high-power modules early in the design flow to help guide optimization strategies
1.2	FEATURES

•	Estimates dynamic, leakage, clock, and total power of RTL designs by parsing Verilog files.
•	Supports various logic gates such as AND, OR, XOR, NAND, NOR, NOT, BUFFER, and MUX.
•	Provides a detailed breakdown of power estimation for each module in the design.
•	Displays power for each gate type and flip-flop, enabling a module-level analysis.
•	Outputs the power estimation results in CSV format for further analysis.
•	Generates a formatted text report for easy visualization and documentation.
•	User-friendly GUI for uploading Verilog files and initiating power estimation.
•	Allows users to select input parameters and visualize results interactively.
•	Identifies flip-flops and combinational gates using Perl scripts and regular expressions for accurate power calculations.
•	Calculates toggle factors based on module names to estimate dynamic power accurately.
•	Utilizes standard formulas to calculate dynamic power (P_dyn), leakage power (P_leak), and clock power (P_clk) based on the technology node, supply voltage, and clock frequency.
•	Allows input of the technology node, clock frequency, and supply voltage for accurate power estimations based on specific design parameters.
•	The tool’s modular design enables the addition of new gate types and features with minimal effort.
•	Supports potential future improvements, such as adding support for additional simulators or file types.

2. DESIGN FLOW
Step 1: User Input, where the user uploads a Verilog file containing the RTL design. The Perl script then parses the file to extract necessary components, such as gates and flip-flops, and users can specify important parameters like the technology node, clock frequency, and supply voltage for accurate power estimation.
Step 2: File Parsing and Gate Identification involves the Perl script processing the Verilog file to identify various components like combinational logic gates (AND, OR, XOR, NAND, NOR, etc.) and sequential elements such as flip-flops (DFFs). Regular expressions (Regex) are used to match gate names, flip-flop instances, and other key elements in the Verilog code, allowing for precise identification and categorization.
In Step 3: Power Calculation, the tool estimates power consumption based on the identified gates. Dynamic power is calculated using the toggle factor, derived from the flip-flop behavior and input signal transitions. Leakage power is estimated by considering the number of gates and flip-flops, applying a leakage power model based on technology parameters. Clock power is also estimated based on the flip-flops and their clocking characteristics. The toggle factor is calculated from signal transitions at the flip-flop inputs, playing a vital role in the dynamic power estimation.
Finally, in Step 4: Report Generation, the tool generates two types of reports: a CSV Report, which includes structured data on each module’s power consumption values and gate types, and a Text Report, which provides a human-readable summary, breaking down the power consumption by module and gate type.
