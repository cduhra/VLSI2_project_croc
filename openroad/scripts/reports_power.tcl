# Copyright 2025 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Adapted for power reporting

# Helper script for writing power analysis reports

if { ![info exists report_dir] } {set report_dir "reports_power"}

proc report_power_puts { out } {
    upvar 1 when when
    upvar 1 filename filename
    set fileId [open $filename a]
    puts $fileId $out
    close $fileId
}

proc report_power_metrics { when } {
  global report_dir

  set filename $report_dir/$when.power.rpt
  set fileId [open $filename w]
  close $fileId

  # Power summary
  report_power_puts "\n=========================================================================="
  report_power_puts "$when Power Analysis Summary"
  report_power_puts "--------------------------------------------------------------------------"
  report_power -corner tt >> $filename

  # IR Drop analysis (if available)
  report_power_puts "\n=========================================================================="
  report_power_puts "$when IR Drop Analysis"
  report_power_puts "--------------------------------------------------------------------------"
  # If your tool supports IR drop reporting, add the command here
  # Example: report_ir_drop >> $filename

  # Power grid issues (if available)
  report_power_puts "\n=========================================================================="
  report_power_puts "$when Power Grid Analysis"
  report_power_puts "--------------------------------------------------------------------------"
  # Example: report_power_grid >> $filename

  # Power by block/module (if available)
  report_power_puts "\n=========================================================================="
  report_power_puts "$when Hierarchical Power Breakdown"
  report_power_puts "--------------------------------------------------------------------------"
  # Example: report_power -hierarchical >> $filename

  # Power violations (if available)
  report_power_puts "\n=========================================================================="
  report_power_puts "$when Power Violations"
  report_power_puts "--------------------------------------------------------------------------"
  # Example: report_power_violations >> $filename
}

# Example usage:
# report_power_metrics "post_route"