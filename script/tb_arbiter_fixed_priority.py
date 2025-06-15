from vunit import VUnit

# Create VUnit instance from command line arguments
vu = VUnit.from_argv()

# Add a library
lib = vu.add_library("lib")

# Add source files
lib.add_source_files("src/base/arbiter_fixed_priority.vhd")

# Add testbench files
lib.add_source_files("tb/base/Tb_arbiter_fixed_priority.vhd")

# Run VUnit
vu.main()