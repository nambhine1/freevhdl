# Get directory of this Tcl script
set script_dir [file dirname [info script]]

# Debug print
puts "Script directory is: $script_dir"

# Build absolute path to StartUp.tcl relative to script directory
set startup_path [file normalize [file join $script_dir ../src/library/OsvvmLibraries/Scripts/StartUp.tcl]]

puts "Trying to source $startup_path"
source $startup_path

# Your remaining build commands with file join for safety
build [file join $script_dir ../src/library/OsvvmLibraries/OsvvmLibraries.pro]
build [file join $script_dir ../src/library/math_utils.pro]
build [file join $script_dir ../src/axi/src.pro]
build [file join $script_dir ../tb/osvvm/Axi_stream_fifo/TestHarness_fifo.pro]
