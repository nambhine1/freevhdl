# FreeVHDL

[Workflow Status](https://github.com/FPGA-Mada/freevhdl/actions/workflows/your-workflow.yml)

[Official GitHub Repository](https://github.com/FPGA-Mada/freevhdl)



**FreeVHDL** is a collection of reusable, open-source VHDL code snippets and modules designed to support hardware design, learning, and rapid prototyping. This repository aims to be a comprehensive resource for students, engineers, and enthusiasts working with FPGA and ASIC designs.

## Features

- Ready-to-use VHDL components  
- Portable and synthesizable code  
- Modular and well-organized structure  
- Testbenches included for most components  
- Scripts for automating common simulation tasks  

---

## Project Structure

```
freevhdl/
├── src/             # VHDL source code (modules, entities, packages)
│   ├── arithmetic/  # Arithmetic units (e.g., adders, multipliers)
│   ├── memory/      # Memory blocks (e.g., RAM, ROM, FIFO)
│   ├── logic/       # Logic blocks (e.g., encoders, decoders)
│   └── utils/       # Utility components (e.g., clock dividers)
│
├── tb/              # Testbenches for validating source code
│   ├── arithmetic_tb/
│   ├── memory_tb/
│   └── ...
│
├── script/          # Utility scripts for building and simulation
│   └── run_ghdl.sh  # Example GHDL simulation script
│
├── doc/             # Documentation, diagrams, datasheets
│   └── overview.pdf
│
├── .github/         # GitHub Actions CI 
│
└── README.md        # Project documentation
```

---

## Simulation Frameworks

This repository leverages **OSVVM** (Open Source VHDL Verification Methodology) and **VUnit** to enhance the simulation and verification of the VHDL modules. These frameworks provide advanced testbench capabilities and automation to thoroughly verify the behavior of the IP.

- **OSVVM**: Provides advanced verification features including random stimulus generation, coverage, and verification components for high-quality testbenches.  
- **VUnit**: An open-source VHDL unit testing framework that automates simulation runs, improves test organization, and integrates well with continuous integration workflows.

Together, these tools help ensure robust, scalable, and repeatable simulation of all modules included in this repository.

---

## 🛠️ Getting Started

### Requirements

To simulate the VHDL modules, you can use:

- [GHDL](https://ghdl.github.io/ghdl/) – Open-source VHDL simulator  
- [GTKWave](http://gtkwave.sourceforge.net/) – Waveform viewer  
- Alternatively: ModelSim, XSIM (Xilinx), or EDA Playground  

---

## Contributing

Contributions are welcome! Feel free to open issues or pull requests for:

- New VHDL modules  
- Bug fixes or optimizations  
- Improved documentation or testbenches  

---

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).  
See the [LICENSE](./LICENSE) file for full license text.


## Authors

Maintained by [Nambinina Rakotojaona](https://github.com/nambhine1).

---

## Contact

For suggestions or queries, open an [issue](https://github.com/nambhine1/freevhdl/issues).
