package require Tk

# Global Variables
set ::verilog_files {}
set ::clk_freq "1.0"
set ::vdd "1.2"
set ::tech_node "45"
set ::dyn_power "0.00"
set ::leak_power "0.00"
set ::clock_power "0.00"
set ::total_power "0.00"
set ::toggle_factor "0.00"

# Main window
wm title . "RTL Power Estimation Tool"
grid [ttk::frame .main -padding "10 10 10 10"] -column 0 -row 0 -sticky nwes

# File Selection
ttk::labelframe .main.file -text "Design Files" -padding 5
grid .main.file -column 0 -row 0 -sticky ew -padx 5 -pady 5

ttk::button .main.file.btn -text "Select Verilog Files" -command {
    set files [tk_getOpenFile -multiple 1 -filetypes {
        {"Verilog Files" {.v .vh}}
        {"All Files" *}
    }]
    
    if {[llength $files] > 0} {
        set ::verilog_files $files
        .main.file.lbl configure -text "Selected: [llength $::verilog_files] files"
    }
}

ttk::label .main.file.lbl -text "No files selected" -width 50 -anchor w
pack .main.file.btn .main.file.lbl -side top -anchor w

# Parameters
ttk::labelframe .main.params -text "Parameters" -padding 5
grid .main.params -column 0 -row 1 -sticky ew -padx 5 -pady 5

ttk::label .main.params.lbl_clk -text "Clock (GHz):"
ttk::entry .main.params.ent_clk -textvariable ::clk_freq -width 8
ttk::label .main.params.lbl_vdd -text "Voltage (V):"
ttk::entry .main.params.ent_vdd -textvariable ::vdd -width 8

# Technology Node Selection
ttk::label .main.params.lbl_tech -text "Tech Node (nm):"
ttk::combobox .main.params.combo_tech -values {22 32 45 65 90 130 180} -textvariable ::tech_node -state readonly
set ::tech_node 45  ;# Default to 45nm

grid .main.params.lbl_clk .main.params.ent_clk -sticky w -pady 2
grid .main.params.lbl_vdd .main.params.ent_vdd -sticky w -pady 2
grid .main.params.lbl_tech .main.params.combo_tech -sticky w -pady 2

# Results
ttk::labelframe .main.results -text "Power Results (uW)" -padding 5
grid .main.results -column 0 -row 2 -sticky ew -padx 5 -pady 5

ttk::label .main.results.lbl_dyn -text "Dynamic:"
ttk::label .main.results.val_dyn -textvariable ::dyn_power -width 10 -anchor e
ttk::label .main.results.lbl_leak -text "Leakage:"
ttk::label .main.results.val_leak -textvariable ::leak_power -width 10 -anchor e
ttk::label .main.results.lbl_clock -text "Clock:"
ttk::label .main.results.val_clock -textvariable ::clock_power -width 10 -anchor e
ttk::label .main.results.lbl_toggle -text "Toggle Factor:"
ttk::label .main.results.val_toggle -textvariable ::toggle_factor -width 10 -anchor e
ttk::label .main.results.lbl_total -text "Total:" -font {Helvetica 10 bold}
ttk::label .main.results.val_total -textvariable ::total_power -width 10 -anchor e -font {Helvetica 10 bold}

grid .main.results.lbl_dyn .main.results.val_dyn -sticky ew -pady 2
grid .main.results.lbl_leak .main.results.val_leak -sticky ew -pady 2
grid .main.results.lbl_clock .main.results.val_clock -sticky ew -pady 2
grid .main.results.lbl_toggle .main.results.val_toggle -sticky ew -pady 2
grid .main.results.lbl_total .main.results.val_total -sticky ew -pady 5

# Buttons
ttk::frame .main.buttons
grid .main.buttons -column 0 -row 3 -sticky e -padx 5 -pady 5

ttk::button .main.buttons.est -text "Estimate" -command {
    if {[llength $::verilog_files] == 0} {
        tk_messageBox -message "Please select at least one Verilog file!" -icon warning
        return
    }
    
    foreach file $::verilog_files {
        if {[catch {exec perl parse_verilog.pl $file $::clk_freq $::vdd $::tech_node} err]} {
            tk_messageBox -message "Error processing file: $file\n$err" -icon error
            return
        }

        set start [string first "===POWER_START===" $err]
        set end [string first "===POWER_END===" $err]
        
        if {$start >= 0 && $end >= 0} {
            set power_data [string range $err $start+16 $end-1]
            foreach line [split $power_data "\n"] {
                if {[regexp {Dynamic: ([\d.]+)} $line -> val]} {
                    set ::dyn_power $val
                }
                if {[regexp {Leakage: ([\d.]+)} $line -> val]} {
                    set ::leak_power $val
                }
                if {[regexp {Clock: ([\d.]+)} $line -> val]} {
                    set ::clock_power $val
                }
                if {[regexp {Toggle Factor: ([\d.]+)} $line -> val]} {
                    set ::toggle_factor $val
                }
                if {[regexp {Total: ([\d.]+)} $line -> val]} {
                    set ::total_power $val
                }
            }
        } else {
            tk_messageBox -message "Error processing file: $file" -icon error
        }
    }
    
    tk_messageBox -message "Power estimation completed for all files!" -icon info
}

ttk::button .main.buttons.plot -text "Plots" -command {
    if {![file exists "power_data.csv"]} {
        tk_messageBox -message "No power data available!" -icon warning
        return
    }
    if {[catch {exec python plot_power.py} err]} {
        tk_messageBox -message "Plot error: $err" -icon error
    } else {
        tk_messageBox -message "Plots generated successfully!" -icon info
    }
}

ttk::button .main.buttons.report -text "View Power Report" -command {
    if {![file exists "power_report.txt"]} {
        tk_messageBox -message "No power report available!" -icon warning
        return
    }
    
    if {[tk_messageBox -message "Open power_report.txt?" -type yesno] == "yes"} {
        if {[tk windowingsystem] eq "win32"} {
            exec notepad.exe power_report.txt &
        } elseif {[tk windowingsystem] eq "x11"} {
            exec xdg-open power_report.txt &
        } elseif {[tk windowingsystem] eq "aqua"} {
            exec open power_report.txt &
        } else {
            tk_messageBox -message "Unsupported OS for opening the report!" -icon error
        }
    }

}
ttk::button .main.buttons.randplot -text "Random VDD Plot" -command {
    if {[tk windowingsystem] eq "win32"} {
        catch {exec cmd.exe /c start /B python plot_power.py} err
    } else {
        catch {exec python plot_power.py &} err
    }
    tk_messageBox -message "Plot generation started in the background.\nCheck images when done." -icon info
}


pack .main.buttons.randplot -side left -padx 5

ttk::button .main.buttons.exit -text "Exit" -command exit

pack .main.buttons.est .main.buttons.plot .main.buttons.report .main.buttons.exit -side left -padx 5
