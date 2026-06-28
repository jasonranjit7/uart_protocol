# UART Protocol — RTL Implementation in Verilog

A synthesizable, parameterizable Verilog implementation of a UART (Universal Asynchronous Receiver/Transmitter) consisting of a baud rate generator, transmitter, receiver, and top-level loopback wrapper. Simulated with Icarus Verilog and targeting Xilinx Artix-7 FPGA (xc7a35tftg256-1) via Vivado.

---

## Repository Structure

```
uart_protocol/
├── baud_rate_gen.v   # Parameterized baud rate generator with 16× RX oversampling
├── uart_tx.v         # UART transmitter FSM (includes baud_rate_gen)
├── uart_rx.v         # UART receiver FSM with oversampled bit detection
└── uart_top.v        # Top-level wrapper — connects TX directly to RX (loopback)
```

---

## Protocol Overview

UART transmits 8-bit data frames asynchronously using a fixed baud rate. Each frame is structured as:

```
Idle  | Start | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop
  1   |   0   |              8 data bits             |    1
```

- **LSB-first** transmission (D0 sent first on the wire)
- **No parity bit** — 8N1 framing (8 data, No parity, 1 stop)
- **Start bit**: logic `0`; **Stop bit**: logic `1`
- Line idles high

---

## Module Descriptions

### `baud_rate_gen`

Generates independent enable pulses (`tx_en`, `rx_en`) for the TX and RX paths by dividing the system clock.

**Parameters:**

| Parameter         | Default | Description                            |
|-------------------|---------|----------------------------------------|
| `BAUD`            | 9600    | Target baud rate (bits/sec)            |
| `FREQ`            | 50      | System clock frequency in MHz × 10⁶   |
| `OVERSAMPLE_RATE` | 16      | RX oversampling factor                 |

**Internal computation:**

```
tx_cycles = FREQ / BAUD          →  5208 clocks/bit  @ 50 MHz, 9600 baud
rx_cycles = tx_cycles / OS_RATE  →   325 clocks/sample (16× oversampling)
```

Counter widths are inferred via `$clog2` — 13 bits for TX, 9 bits for RX. Both `tx_en` and `rx_en` are single-cycle pulses asserted when their respective counter wraps to zero.

---

### `uart_tx`

Serializes an 8-bit byte and drives it onto the `tx` line at the configured baud rate.

**Ports:**

| Port    | Dir    | Width | Description                             |
|---------|--------|-------|-----------------------------------------|
| `clk`   | input  | 1     | System clock                            |
| `rst`   | input  | 1     | Synchronous active-high reset           |
| `ready` | input  | 1     | Assert high to begin transmission       |
| `data`  | input  | 8     | Byte to transmit                        |
| `done`  | output | 1     | High for one `tx_en` cycle when TX ends |
| `tx`    | output | 1     | Serial data output line                 |

**FSM:**

```
         ready asserted
  IDLE ─────────────────► START ──── tx_en ──► DATA ──── 8 bits sent ──► IDLE
                                                 │ ◄──────────────────────┘
                                            (bit_cnt++)
```

- `data_frame` is loaded from `data` in IDLE and right-shifted each `tx_en` tick
- `tx` drives `data_frame[0]` during DATA; idles / stop bit = `1'b1`
- `shift` and `done` are combinational outputs driven from the Mealy next-state logic
- `bit_cnt` resets on IDLE entry; `done` pulses when `bit_cnt == 8`

---

### `uart_rx`

Deserializes an incoming serial stream using 16× oversampling for robust start-bit detection and mid-bit sampling.

**Ports:**

| Port   | Dir    | Width | Description                              |
|--------|--------|-------|------------------------------------------|
| `clk`  | input  | 1     | System clock                             |
| `rst`  | input  | 1     | Synchronous active-high reset            |
| `rx`   | input  | 1     | Serial data input line                   |
| `done` | output | 1     | High for one `rx_en` cycle when RX ends  |
| `data` | output | 8     | Received byte (valid when `done` pulses) |

**FSM:**

```
  IDLE ──── !rx (start bit) ──► DATA ──── 8 bits ──► STOP ──── back to IDLE
                                  │ ◄─────────────────┘
                              (sample rx at rx_en)
```

- Transitions and sampling gated on `rx_en` (16× faster than TX clock)
- `tx_data` assembles bits LSB-first via `tx_data[bit_cnt] <= rx`
- STOP state validates stop bit: if `rx == 1`, latches `data <= tx_data` and pulses `done`; otherwise `done` stays 0

---

### `uart_top` (Loopback Wrapper)

Connects the TX output directly to the RX input for self-test loopback simulation.

**Ports:**

| Port     | Dir    | Width | Description                          |
|----------|--------|-------|--------------------------------------|
| `clk`    | input  | 1     | System clock                         |
| `rst`    | input  | 1     | Synchronous active-high reset        |
| `ready`  | input  | 1     | Start transmission                   |
| `data`   | input  | 8     | Byte to transmit                     |
| `done`   | output | 1     | RX done pulse                        |
| `rx_data`| output | 8     | Received byte (should match `data`)  |

Internal wire `tx` connects `uart_tx.tx → uart_rx.rx`. `tx_done` from the transmitter is left available for external use.

---

## Simulation

Tested with [Icarus Verilog](https://steveicarus.github.io/iverilog/):

```bash
# Compile (uart_tx.v and uart_rx.v are `include'd automatically)
iverilog -o uart_sim uart_top.v

# Run
vvp uart_sim

# View waveforms
gtkwave dump.vcd
```

A typical testbench asserts `ready = 1` for one clock cycle with `data = 8'hA5`, then monitors `done` and checks that `rx_data == 8'hA5` at the end of the loopback.

---

## Timing at Default Parameters

| Parameter      | Value                          |
|----------------|-------------------------------|
| System clock   | 50 MHz                        |
| Baud rate      | 9600 bps                      |
| Clocks per bit | 5208                          |
| Bit period     | 104.16 µs                     |
| Full frame     | ~1.04 ms (10 bits: 1S+8D+1P)  |
| RX sample rate | 16× (one sample per 325 clks) |

---

## Key Design Decisions

- **16× RX oversampling** — `rx_en` ticks 16× per bit period; start-bit detection triggers mid-bit aligned sampling for all subsequent bits, making the receiver robust to clock skew.
- **Independent baud generators in TX and RX** — each module instantiates its own `baud_rate_gen`, using only the `tx_en` or `rx_en` output it needs (the other port is left unconnected).
- **Mealy combinational outputs in TX** — `tx`, `shift`, and `done` are driven from the combinational `always @(*)` block to minimize latency; the state register is the only clocked element.
- **Synchronous reset throughout** — all `always @(posedge clk)` blocks; FPGA-safe, no asynchronous paths.
- **`$clog2` for counter sizing** — counter widths are inferred at elaboration time, ensuring the design correctly scales with any `BAUD`/`FREQ` combination.

---

## Author

Jason Ranjit J  
MS Electrical & Computer Engineering — University of Wisconsin–Madison  
GitHub: [@jasonranjit7](https://github.com/jasonranjit7)
