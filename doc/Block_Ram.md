
# 🧠 Block RAM (VHDL)

## 📘 Overview

This VHDL module implements a **synchronous Block RAM** with configurable depth, data width, and operational mode. The address width is automatically determined using a `clog2` function.

## 🧹 Entity: `Block_Ram`

### 🔧 Ports

| Name   | Direction | Type                                            | Description                        |
| ------ | --------- | ----------------------------------------------- | ---------------------------------- |
| `clk`  | in        | `std_logic`                                     | Clock input                        |
| `rst`  | in        | `std_logic`                                     | **Synchronous**, active-high reset |
| `we`   | in        | `std_logic`                                     | Write enable                       |
| `addr` | in        | `std_logic_vector(clog2(RAM_DEPTH)-1 downto 0)` | Memory address                     |
| `din`  | in        | `std_logic_vector(DATA_WIDTH-1 downto 0)`       | Data input                         |
| `dout` | out       | `std_logic_vector(DATA_WIDTH-1 downto 0)`       | Data output                        |

---

### 🔧 Generic Parameters

| Name         | Type    | Default | Description                            |
| ------------ | ------- | ------- | -------------------------------------- |
| `RAM_DEPTH`  | integer | `32`    | Number of memory locations             |
| `DATA_WIDTH` | integer | `32`    | Width of each data word                |
| `RAM_MODE`   | string  | `"WBR"` | RAM operation mode: `"RBW"` or `"WBR"` |

---

## ⚙️ Functionality

- Supports two read/write modes via `RAM_MODE`:

  - `"RBW"` (Read Before Write):\
    Reads data **before** performing a write on the same address in the same cycle.
  - `"WBR"` (Write Before Read):\
    Writes data **first**, then reads the updated value in the same cycle.

- Synchronous `clk`-driven operation

- `dout` output is registered

- Assertion checks to enforce valid `RAM_MODE` values

---

## ⏱ Reset Behavior

| Condition   | Behavior                             |
| ----------- | ------------------------------------ |
| `rst = '1'` | Clears the `dout` register to all 0s |
|             | Synchronous with `clk`               |

---

## ✅ Features

- 🚀 Generic parameters: `RAM_DEPTH`, `DATA_WIDTH`, `RAM_MODE`
- 🧾 Automatic address width via `clog2`
- 🕒 Clocked synchronous memory access
- 📏 Configurable read-before-write or write-before-read behavior
- ⚠️ Built-in assertion for mode configuration validation

---

## 💡 Notes

- 🛠 Designed for **VHDL-2008** (for `clog2` in generics)
- 🧪 Suitable for both **simulation and FPGA synthesis** (e.g., Xilinx Vivado)
- 🔀 Compatible with testbenches using self-checking assertions
