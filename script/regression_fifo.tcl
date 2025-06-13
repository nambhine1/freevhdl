# Get directory of this Tcl script
set script_dir [file dirname [info script]]

# Get repo root directory (one level above script folder)
set repo_root [file normalize [file join $script_dir ..]]

# Construct absolute path to StartUp.tcl
set startup_path [file join $repo_root src/library/OsvvmLibraries/Scripts/StartUp.tcl]

puts "Script directory is: $script_dir"
puts "Repo root directory is: $repo_root"
puts "Trying to source $startup_path"

# Source the startup script
source $startup_path

variable OMIT_XILINX_FILES 0

build [file join $repo_root src/library/OsvvmLibraries/OsvvmLibraries.pro]

if {$::osvvm::ToolName eq "GHDL"} {
    set OMIT_XILINX_FILES 1
    SetExtendedAnalyzeOptions {-frelaxed -Wno-specs}
    SetExtendedSimulateOptions {-frelaxed -Wno-specs -Wno-binding}
    SetExtendedRunOptions {--ieee-asserts=disable-at-0}
}

if {$::osvvm::ToolName eq "RivieraPRO"} {
    set OMIT_XILINX_FILES 1
    puts "Simulator = $::osvvm::ToolName, OMIT_XILINX_FILES = $OMIT_XILINX_FILES"
    LinkLibraryDirectory {temp/VHDL_LIBS}
}

if {$::osvvm::ToolName eq "QuestaSim"} {
    set OMIT_XILINX_FILES 0
    SetVHDLVersion 2008
    vmap unisim "$PrecompiledVivadoIPCores/unisim"
    vmap xpm "$PrecompiledVivadoIPCores/xpm"
}

build [file join $repo_root src/library/math_utils.pro]
build [file join $repo_root src/axi/src.pro]

build [file join $repo_root tb/osvvm/Axi_stream_fifo/TestHarness_fifo.pro]
