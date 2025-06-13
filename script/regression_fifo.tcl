# Get directory of the currently running script
set script_dir [file dirname [info script]]

# Source the Startup.tcl relative to script_dir
source [file join $script_dir ../src/library/OsvvmLibraries/Scripts/StartUp.tcl]

variable OMIT_XILINX_FILES 0

build [file join $script_dir ../src/library/OsvvmLibraries/OsvvmLibraries.pro]

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

build [file join $script_dir ../src/library/math_utils.pro]
build [file join $script_dir ../src/axi/src.pro]

build [file join $script_dir ../tb/osvvm/Axi_stream_fifo/TestHarness_fifo.pro]
