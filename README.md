<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# A SHA256 hardware accelerator

## General description

The goal of this final project is to design and then develop a SHA256 hardware accelerator. It will be mapped on the [Xilinx] [Zynq] core of the [Zybo] prototyping board. The [ARM] processor of the Zynq will be used to run the software stack that drives the hardware accelerator implemented in the FPGA matrix.

## Useful links and documents

* [The SHA256 standard](/doc/sha2.pdf)
* [A paper with nice ideas about SHA256 hardware implementations](http://soc.eurecom.fr/DS/sec/10.1.1.148.7900.pdf)
* [SHA-256 explained on Wikipedia](https://en.wikipedia.org/wiki/SHA-2)

## Specifications

After reading and understanding the SHA256 standard, imagine what your hardware accelerator could be and what interface(s) it could have with the ARM processor. Do not forget that it will be accessed from the software world...

Write down your functional, performance and interface specifications.

Draw block diagrams of your architecture, top-level and sub-modules.

## VHDL coding

Code your hardware accelerator in synthesizable VHDL. Code also simulation environment(s) to validate it.

## Hardware-software integration

Design and develop a Linux device driver for your hardware accelerator, plus a simple software application to test your hardware accelerator and its driver.

Synthesize and map on the Zybo board. Package your Linux device driver and software application in a root file system. Run a nice demo of your work on the board.

[Xilinx]: http://www.xilinx.com
[Zynq]: http://www.xilinx.com/products/silicon-devices/soc/zynq-7000/
[Zybo]: http://soc.eurecom.fr/DS/zybo.html
[ARM]: http://www.arm.com/

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
