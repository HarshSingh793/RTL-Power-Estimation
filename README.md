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

STEP BY STEP INSTRUCTIONS TO EXECUTE THE PROGRAM -
  Prepare the Environment:
  
•	Install Perl, Tcl/Tk, and necessary libraries.

•	Ensure the Verilog file is ready for analysis (e.g., top_module.v).

  Launch the GUI:
  
•	Open the Tcl/Tk GUI tool.

  Input Parameters:
  
•	Enter clock frequency, supply voltage, and technology node in the GUI.

•	Upload the Verilog file for processing.

  Run the Tool:
  
•	Click the “Run” button to start the power estimation process.

  View the Results:
  
•	The tool generates:

o	CSV Report: Detailed power consumption data.

o	Text Report: Human-readable power summary.

o	Log File: Contains process logs and errors.

  Check the Output:
  
•	Open and analyze the CSV or text report for power estimation details.


**SAMPLE INPUT FILE - test.v**

**SAMPLE INPUT PARAMETERS**

Clock - 1.0 Ghz 
Voltage - 12V
Tech Node(nm)- 32


**OUTPUT RESULTS**

power_report.txt
For Plots - Check the file included in the repository named - vdd_vs_power.png

**All the sample input file and output files are included**


