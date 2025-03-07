# Computer Architecture hands-on exercises based on the Nios II soft processors
Hands-on exercises for the Computer Architecture course at the [University of Las Palmas de Gran Canaria (Spain)](https://internacional.ulpgc.es/en/) using Nios II-based System-on-Chips (SoCs) and the DE0-Nano board.

[Lab 1. Nios II/e instruction set architecture and programming](labs/lab1/lab1tutorial.pdf)

[Lab 2. Performance evaluation of the memory hierarchy of a computer and reverse engineering of the data cache memory](labs/lab2/lab2tutorial.pdf)

[Lab 3. Performance evaluation of pipelined processors](labs/lab3/lab3tutorial.pdf)

[Lab 4. Nios II multiprocessor implementation, parallel programming, and performance evaluation](labs/lab4/lab4tutorial.pdf)

[Lab 5. Nios II processor with customized architecture for a software application](labs/lab5/lab5tutorial.pdf)

## Laboratory infrastructure - hardware: <br />
- Terasic DE0-Nano board <br />
- Desktop computer <br />
- USB-A - miniUSB cable <br />

## Laboratory infrastructure - software: <br />
- Windows 10 <br />
- Altera Quartus II Design Suite 13.1 <br />
- Altera Monitor Program 13.1  <br />
- Nios II Embedded Design Suite 13.1  <br />

## Folder organization: <br />
./code: assembler and C programs <br />
./labs: pdf documents for hands-on exercises <br />
./SoC_configurations: binary files to configure the FPGA of a Terasic DE0-Nano board <br />

## Previous and current academic work
The lab assignments described here have been used in the training of more than 1,000 computer science undergraduate students for more than 10 years.

2025 winter semester: 171 students enrolled, 7 student groups.

## Lab calendar (30 lab hours, 15 2-hour sessions, 1 lab-session/week)

<ins>Week 1.</ins> Lab 1: summary, DE0-Nano board, Altera software tools, Nios II instruction set architecture, assembler programming, exercises. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab1/lab1tutorial.pdf), [video (Spanish)](https://t.ly/QnL3Z).

<ins>Week 2.</ins> Lab 1: subroutines, modification of a loaded instruction code, exercises: Fibonacci series, binary multiplication, dot product, binary division. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab1/lab1tutorial.pdf).

<ins>Week 3.</ins> Lab 1: test of developed assembly code projects on the DE0-Nano board. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab1/lab1tutorial.pdf).

<ins>Week 4.</ins> Lab 1: exam. Hours: 2 (laboratory) + 2 (homework). 

<ins>Week 5.</ins> Lab 2: summary, memory hierarchy and its implementation on the DE0-Nano board, SDRAM memory device, SRAM on-chip memory, performance evaluation of Nios II/e soft core when SDRAM or SRAM are activated. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab2/lab2tutorial.pdf).

## Topics

Labs are based on principles presented in 30 one-hour lectures during the semester in parallel with the lab sessions. The main topics covered are: methodology for performance evaluation of RISC computers, microarchitecture of pipelined processors and its efficient programming, performance evaluation of cache memories, design and performance evaluation of main memory, static scheduling of instructions, out-of-order instruction execution, microarchitecture and evaluation of superscalar processors, VLIW architectures and microarchitectures, high-performance parallel computing using shared memory multi-core architectures, GPUs, multicomputers and application specific instruction set processors.

## Skills gained by students in this Computer Architecture course

Practical experience on Computer Architecture using real FPGA-based hardware, assembly language programming using a RISC-based instruction set and several bare-metal computer systems, multi-thread programming, code optimization using information from the computer architecture, performance evaluation of processors and multiprocessors, performance evaluation of memory hierarchy including main memory and caches, programming, performance evaluation and customization of the microarchitecture of a general-purpose processor integrated into a System-on-Chip.

## Professional opportunities that demand these skills across industries

Platform Hardware and Systems Engineer (development of hardware and systems), System and Solution Architect, GPU Platform Hardware Design Engineer, Platform Solutions Architect, Hardware Engineer, Platform Validation Engineer, Product Packing Engineer, Security Research Engineer, Silicon Architecture Engineer.


## Nios V

Another [repository](https://github.com/vipl-dbd/ComputerArchitecture_NiosV) includes similar hands-on exercises using the Nios V soft processor.

## Citation
Benitez, D. (2024). 
Hands-on experience for undergraduate Computer Architecture courses using Nios V-based soft SoCs and real board. 
2024 First Annual Soft RISC-V Systems Workshop.
https://github.com/vipl-dbd/ComputerArchitecture_NiosV/blob/main/benitezSRvSnov24paper.pdf
