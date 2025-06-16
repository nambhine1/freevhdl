from vunit import VUnit

# Create VUnit instance from command line arguments
vu = VUnit.from_argv()

# Add a library
lib = vu.add_library("lib")

# Add source files
lib.add_source_files("src/library/math_utils.vhd")
lib.add_source_files("src/base/Block_Ram_sp.vhd")



# Add testbench files
lib.add_source_files("tb/base/Tb_Block_Ram_sp.vhd")
# Run VUnit
vu.main()