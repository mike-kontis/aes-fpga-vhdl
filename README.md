# FPGA Implementation of the AES Algorithm (128/192/256-bit) in VHDL

## Overview

This repository contains a parameterizable hardware implementation of the **Advanced Encryption Standard (AES)** algorithm in **VHDL**, supporting all three standardized key lengths:

* **AES-128**
* **AES-192**
* **AES-256**

The design was developed as part of a diploma thesis and targets the **Altera Cyclone III FPGA (EPC35F672C6)**. The implementation performs both **encryption and decryption** and communicates with external computers through **UART serial interfaces**.

The AES version is selected through compilation parameters, allowing the same hardware design to support all three variants without modifying the source code.

---

# Features

* Parameterizable AES implementation (128, 192 and 256-bit keys)
* Hardware implementation written entirely in VHDL
* AES Encryption and Decryption support
* UART transmitter and receiver implemented in VHDL
* End-to-end communication between two serial terminals
* Real-time visualization of intermediate AES rounds using FPGA seven-segment HEX displays
* Configurable through compile-time parameters

---

# System Architecture

The complete system consists of:

1. UART Receiver
2. Input Buffer for Plaintext and Secret Key
3. AES Encryption Core
4. UART Transmission of Ciphertext
5. AES Decryption Core
6. UART Transmission of Recovered Plaintext

The same FPGA performs both encryption and decryption, demonstrating the correctness of the implementation by recovering the original message.

---

# Experimental Setup

The FPGA board is connected to **two serial UART interfaces**.

Two **Tera Term** terminals are opened simultaneously:

* **Terminal 1:** Sends the plaintext message and the encryption key.
* **Terminal 2:** Receives the encrypted data and finally displays the decrypted plaintext.

Execution flow:

1. User sends plaintext and key through UART.
2. FPGA receives the data.
3. AES encryption starts.
4. Intermediate round results are displayed on the FPGA HEX displays.
5. Ciphertext is transmitted through the second UART interface.
6. AES decryption is executed.
7. The recovered plaintext is transmitted back and displayed on the second terminal.

The final output matches the original plaintext, verifying the correct operation of the complete AES hardware implementation.

---

# Directory Structure

```
docs/          Thesis documentation and presentation
images/        FPGA photos, architecture diagrams and screenshots
rtl/           VHDL source code
simulations/   Testbenches and simulation files
README.md
```

---

# Target Device

* FPGA Family: Altera Cyclone III
* Device: EPC35F672C6

---

# Technologies Used

* VHDL
* Intel Quartus
* UART Serial Communication
* Tera Term
* FPGA Hardware Design
* AES Cryptographic Algorithm

---

# Demonstration

The implementation demonstrates a complete AES communication chain:

```
Plaintext
      │
      ▼
UART Reception
      │
      ▼
AES Encryption
      │
      ▼
Ciphertext
      │
      ▼
UART Transmission
      │
      ▼
AES Decryption
      │
      ▼
Recovered Plaintext
```

The recovered plaintext is identical to the original input message.

---

# Future Improvements

* Runtime AES mode selection without recompilation
* Support for additional cipher modes (CBC, CTR, GCM)
* AXI or Avalon bus integration
* Performance optimization through pipelining
* Hardware performance benchmarking

---

# Author

**Kontis Michail**

Diploma Thesis Project

Department of Computer Science and Engineering

University of Ioannina

Academic Year:  2025-2026

---

# License

This repository is intended for educational and research purposes.
