from vunit import VUnit

# Create VUnit instance from command line arguments
vu = VUnit.from_argv()

# Add a library
lib = vu.add_library("lib")

# Add source files
lib.add_source_files("src/library/math_utils.vhd")
lib.add_source_files("src/base/decode_first_bit.vhd")



# Add testbench files
lib.add_source_files("tb/base/Tb_decode_first_bit.vhd")
# Run VUnit
vu.main()