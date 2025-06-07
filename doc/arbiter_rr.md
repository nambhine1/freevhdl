
#  Round-Robin Arbiter (VHDL)

##  Overview

This VHDL module implements a **Round-Robin Arbiter** that fairly selects one request among multiple simultaneous requests. It ensures no requester is starved by rotating the priority after each grant.

---

##  Entity: `arbiter_rr`

###  Ports

| Name          | Direction | Type                             | Description                                  |
|---------------|-----------|----------------------------------|----------------------------------------------|
| `clk`         | in        | `std_logic`                      | Clock input                                   |
| `rst`         | in        | `std_logic`                      | **Synchronous**, active-high reset            |
| `request`     | in        | `std_logic_vector(N-1 downto 0)` | Input request signals from N clients          |
| `grant`       | out       | `std_logic_vector(N-1 downto 0)` | One-hot encoded output grant                  |
| `valid_grant` | out       | `std_logic`                      | High if any grant is active                   |

- `N` is specified via the generic parameter `REQUEST_WIDTH`.

---

##  Functionality

- The arbiter scans the `request` vector in **round-robin** order starting from the index after the last grant.
- It grants access to the **first active request** it finds.
- Only **one grant** is issued per clock cycle (`grant` is one-hot).
- If no requests are active, `grant` and `valid_grant` are cleared to `'0'`.

---

##  Generic Parameter

| Name            | Type    | Default | Description                      |
|-----------------|---------|---------|----------------------------------|
| `REQUEST_WIDTH` | integer | `4`     | Number of input request lines    |

---

##  Reset Behavior

- On `rst = '1'` (synchronous reset):
  - All grants are cleared
  - `valid_grant` is set to `'0'`
  - The internal round-robin pointer is reset to 0

---

##  Use Cases

- Arbitration between multiple clients for:
  - Shared buses
  - Memory interfaces
  - I/O peripherals
- Scenarios where **fairness** is required
- Avoiding starvation in request-based systems

---

##  Notes

- This arbiter requires that the `request` signals be held high until the grant is received.
- Only one request is granted at a time per cycle.
- The logic is fully synchronous and synthesizable.

---