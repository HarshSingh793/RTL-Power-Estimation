#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV < 4) {
    die "Usage: perl parse_verilog.pl <verilog_file> <clk_freq> <vdd> <tech_node> [debug]\n";
}

my ($verilog_file, $clk_freq, $vdd, $tech_node, $debug) = @ARGV;
$debug ||= 0;

if (!-e $verilog_file || !-r $verilog_file) {
    die "Error: Cannot read Verilog file $verilog_file.\n";
}

open(my $fh, '<', $verilog_file) or die "Cannot open $verilog_file: $!\n";

my ($flip_flops, $combo_gates, $transitions, $total_bits) = (0, 0, 0, 0);
my ($dynamic_power, $leakage_power, $clock_power, $total_power) = (0, 0, 0, 0);

my %tech_coeff = (
    22  => { dyn_ff => 0.2, dyn_gate => 0.1, leak_ff => 0.005, leak_gate => 0.002 },
    32  => { dyn_ff => 0.3, dyn_gate => 0.15, leak_ff => 0.007, leak_gate => 0.003 },
    45  => { dyn_ff => 0.5, dyn_gate => 0.2, leak_ff => 0.01, leak_gate => 0.005 },
    65  => { dyn_ff => 0.7, dyn_gate => 0.25, leak_ff => 0.015, leak_gate => 0.007 },
    90  => { dyn_ff => 1.0, dyn_gate => 0.3, leak_ff => 0.02, leak_gate => 0.01 },
    130 => { dyn_ff => 1.5, dyn_gate => 0.4, leak_ff => 0.03, leak_gate => 0.015 },
    180 => { dyn_ff => 2.0, dyn_gate => 0.5, leak_ff => 0.04, leak_gate => 0.02 }
);

my $coeff = $tech_coeff{$tech_node} || die "Unsupported technology node: $tech_node\n";

# Hierarchical module tracking
my %modules;
my $current_module = "TOP";

while (my $line = <$fh>) {
    chomp $line;

    # Detect module declaration
    if ($line =~ /^\s*module\s+(\w+)/) {
        $current_module = $1;
        $modules{$current_module} ||= { ff => 0, gate => 0 };
    }

    # Detect endmodule
    if ($line =~ /^\s*endmodule\b/) {
        $current_module = "TOP";
    }

    # Count Flip-Flops (by keyword match)
    if ($line =~ /\b(DFF|DFFSR|FD|DFFPOSX1|DFFNEG|DFFS|DFFN|FF|DFFRX1)\b/) {
        $flip_flops++;
        $modules{$current_module}{ff}++;
    }

    # Count Combinational Gates (by keyword match)
    if ($line =~ /\b(AND|OR|XOR|NAND|NOR|INV|BUF|MUX|AOI|OAI)\b/) {
        $combo_gates++;
        $modules{$current_module}{gate}++;
    }

    # Count gates via submodule instantiations
    if ($line =~ /\b(and_gate|or_gate|xor_gate|nand_gate|nor_gate|inv_gate|buf_gate|mux2)\b/) {
        $combo_gates++;
        $modules{$current_module}{gate}++;
    }

    # Count D Flip-Flop instantiations
    if ($line =~ /\bdff\b/) {
        $flip_flops++;
        $modules{$current_module}{ff}++;
    }

    # Bit-width FFs (optional)
    if ($line =~ /(?:output\s+)?reg\s*(?:\[(\d+):(\d+)\])?\s*([\w,\s]+)/) {
        my $bit_width = abs(($1 // 0) - ($2 // 0)) + 1;
        my @signals = split(/\s*,\s*/, $3);
        my $extra = $bit_width * scalar @signals;
        $flip_flops += $extra;
        $total_bits += $extra;
        $modules{$current_module}{ff} += $extra;
    }
}

close($fh);

my $toggle_factor = 0.234;

if ($verilog_file =~ /counter|mux|shift_register|dff|and_gate|xor_gate/) {
    if ($verilog_file =~ /counter/) {
        $toggle_factor = 1.0;
    } elsif ($verilog_file =~ /mux/) {
        $toggle_factor = 0.5;
    } elsif ($verilog_file =~ /shift_register/) {
        $toggle_factor = 0.25;
    } elsif ($verilog_file =~ /and_gate|xor_gate/) {
        $toggle_factor = 0.1;
    }
}

$dynamic_power = ($flip_flops * $coeff->{dyn_ff} + $combo_gates * $coeff->{dyn_gate}) * ($clk_freq / 1000) * ($vdd ** 2) * $toggle_factor;
$leakage_power = ($flip_flops * $coeff->{leak_ff} + $combo_gates * $coeff->{leak_gate}) * $vdd;
$clock_power   = $flip_flops * 0.1 * ($clk_freq / 1000);
$total_power   = $dynamic_power + $leakage_power + $clock_power;

$dynamic_power *= 1000;
$leakage_power *= 1000;
$clock_power *= 1000;
$total_power *= 1000;

# Save results to CSV
my $csv_file = "power_data.csv";
my $csv_header = "Timestamp,Clock Frequency (GHz),VDD (V),Technology Node (nm),Toggle Factor,Dynamic Power (µW),Leakage Power (µW),Clock Power (µW),Total Power (µW)\n";
my $timestamp = localtime();

open(my $csv, '>>', $csv_file) or die "Cannot open $csv_file: $!\n";
print $csv $csv_header if (-z $csv_file);
print $csv "$timestamp,$clk_freq,$vdd,$tech_node,$toggle_factor,$dynamic_power,$leakage_power,$clock_power,$total_power\n";
close($csv);

# Save Power Report
my $report_file = "power_report.txt";
open(my $report, '>', $report_file) or die "Cannot open $report_file: $!\n";

print $report "========================================\n";
print $report "           RTL Power Report             \n";
print $report "========================================\n";
print $report "Technology Node   : ${tech_node}nm\n";
print $report "Clock Frequency   : ${clk_freq} GHz\n";
print $report "Supply Voltage    : ${vdd} V\n";
print $report "----------------------------------------\n";
printf $report "%-20s: %d\n", "Flip-Flops", $flip_flops;
printf $report "%-20s: %d\n", "Combinational Gates", $combo_gates;
printf $report "%-20s: %.4f\n", "Toggle Factor", $toggle_factor;
print $report "----------------------------------------\n";
printf $report "%-20s: %.2f µW\n", "Dynamic Power", $dynamic_power;
printf $report "%-20s: %.2f µW\n", "Leakage Power", $leakage_power;
printf $report "%-20s: %.2f µW\n", "Clock Power", $clock_power;
printf $report "%-20s: %.2f µW\n", "Total Power", $total_power;
print $report "========================================\n";

# Module-wise breakdown
print $report "\nHierarchical Module-wise Breakdown:\n";
print $report "----------------------------------------\n";
foreach my $mod (sort keys %modules) {
    my $mff = $modules{$mod}{ff};
    my $mgate = $modules{$mod}{gate};
    my $dyn = ($mff * $coeff->{dyn_ff} + $mgate * $coeff->{dyn_gate}) * ($clk_freq / 1000) * ($vdd ** 2) * $toggle_factor * 1000;
    my $leak = ($mff * $coeff->{leak_ff} + $mgate * $coeff->{leak_gate}) * $vdd * 1000;
    my $clk  = $mff * 0.1 * ($clk_freq / 1000) * 1000;
    my $total = $dyn + $leak + $clk;

    printf $report "\nModule: %-15s\n", $mod;
    printf $report "  Flip-Flops         : %d\n", $mff;
    printf $report "  Combo Gates        : %d\n", $mgate;
    printf $report "  Dynamic Power      : %.2f µW\n", $dyn;
    printf $report "  Leakage Power      : %.2f µW\n", $leak;
    printf $report "  Clock Power        : %.2f µW\n", $clk;
    printf $report "  Total Module Power : %.2f µW\n", $total;
}

close($report);

# Print summary to terminal
print "===POWER_START===\n";
print "FlipFlops: $flip_flops\n";
print "ComboGates: $combo_gates\n";
print "Toggle Factor: $toggle_factor\n";
print "Technology Node: ${tech_node}nm\n";
print "Dynamic: $dynamic_power µW\n";
print "Leakage: $leakage_power µW\n";
print "Clock: $clock_power µW\n";
print "Total: $total_power µW\n";
print "===POWER_END===\n";

print "Power report saved to $report_file\n";
