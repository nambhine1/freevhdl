
# FreeVHDL

**FreeVHDL** is a collection of reusable, open-source VHDL code snippets and modules designed to support hardware design, learning, and rapid prototyping. This repository aims to be a comprehensive resource for students, engineers, and enthusiasts working with FPGA and ASIC designs.

##  Features

- Ready-to-use VHDL components
- Portable and synthesisable code
- Modular and well-organized structure
- Testbenches included for most components
- Scripts for automating common simulation tasks

---

##  Project Structure

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
├── .github/         # GitHub Actions CI (if applicable)
│
└── README.md        # Project documentation (this file)
```

---

## 🛠️ Getting Started

### Requirements

To simulate the VHDL modules, you can use:

- [GHDL](https://ghdl.github.io/ghdl/) – Open-source VHDL simulator
- [GTKWave](http://gtkwave.sourceforge.net/) – Waveform viewer
- Alternatively: ModelSim, XSIM (Xilinx), or EDA Playground

##  Contributing

Contributions are welcome! Feel free to open issues or pull requests for:

- New VHDL modules
- Bug fixes or optimizations
- Improved documentation or testbenches

---

##  License

This project is licensed under the MIT License. See `LICENSE` for details.

---

##  Authors

Maintained by [Nambinina Rakotojaona](https://github.com/nambhine1).

---

##  Contact

For suggestions or queries, open an [issue](https://github.com/nambhine1/freevhdl/issues).
