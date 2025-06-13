# get the absolute path of the script directory
set script_dir [file dirname [info script]]

# compute repo root dir (parent of script dir)
set repo_root [file normalize [file join $script_dir ..]]

puts "Script directory is: $script_dir"
puts "Repo root directory is: $repo_root"

# source startup using path relative to repo root
set startup_path [file normalize [file join $repo_root src/library/OsvvmLibraries/Scripts/StartUp.tcl]]

puts "Trying to source $startup_path"
source $startup_path

# Build commands using repo_root
build [file join $repo_root src/library/OsvvmLibraries/OsvvmLibraries.pro]
build [file join $repo_root src/library/math_utils.pro]
build [file join $repo_root src/axi/src.pro]
build [file join $repo_root tb/osvvm/Axi_stream_fifo/TestHarness_fifo.pro]

