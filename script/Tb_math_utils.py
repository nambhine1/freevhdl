from vunit import VUnit

# Create VUnit instance from command line arguments
vu = VUnit.from_argv()

# Add a library
lib = vu.add_library("lib")

# Add source files
lib.add_source_files("src/library/math_utils.vhd")

# Add testbench files
lib.add_source_files("tb/library/Tb_math_utils.vhd")
# Run VUnit
vu.main()