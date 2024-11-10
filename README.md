# Demo Projects for Digilent Basys3 FPGA board 

This repository contains a UART communication project with digit counter and seven-segment display controller, implemented in SystemVerilog for the Digilent Basys3 FPGA development board.

## Overview

The project implements a UART module for serial communication, along with a digit counter and seven-segment display controller to show received/processed data on the Basys3 board's display. The design demonstrates practical digital communication and display interfacing using SystemVerilog HDL.

## Project Structure
- `rtl/` - Contains SystemVerilog RTL source files
  - UART module
  - Digit counter module
  - Seven segment display controller
- `testbench/` - Contains verification testbenches
- `constraint/` - Contains XDC constraint files for Basys3
- `rom_data/` - Contains initialization data files

## Requirements

- Xilinx Vivado Design Suite
- Digilent Basys3 FPGA Board
- USB Cable for programming
- Serial Terminal Program (e.g., PuTTY, TeraTerm)

## Getting Started

1. Clone this repository
2. Open project in Vivado
3. Generate bitstream
4. Program the Basys3 board
5. Connect via serial terminal using appropriate COM port

## Demo Video

https://www.linkedin.com/posts/yigit-bektas-gursoy_koray-karakurtun-fpga-e%C4%9Fitim-serisi-sayesinde-activity-7261362850906980352-LDuW?utm_source=share&utm_medium=member_desktop

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Yigit Bektas Gursoy

## Contributors

TahaGemici
