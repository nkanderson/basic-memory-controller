# Clear previous waveforms
if {![batch_mode]} {
  delete wave *
}

# Add signals
add wave -noupdate sim:/processor/clk
add wave -noupdate sim:/processor/resetH
add wave -noupdate sim:/processor/AddrValid
add wave -noupdate sim:/processor/rw
add wave -noupdate -radix hexadecimal sim:/processor/AddrData
add wave -noupdate -radix hexadecimal sim:/processor/AddrData_drive


# Zoom to full simulation length
if {![batch_mode]} {
  wave zoom full
}
