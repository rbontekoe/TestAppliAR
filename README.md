# TestAppliAR

!!! info
    Under development!!!

This file has all the ingredients to test the stuff from the course [BAWJ](https://www.appligate.nl/BAWJ/stable/), section3 - [Using Containers](https://www.appligate.nl/BAWJ/stable/chapter13/). It contains:
- src/main.jl
- IJulia notebook ar.ipynb
- IJulia notenook website.ipynb

### Prerequisites
- Ubuntu 20.04
- Julia 1.5.0+
- The two Docker containers from chapter 13, test_sshd and test_sshd2.

### Installation
The best is to use the IJulia notebooks, steps:
1. Clone this project: `git clone https://github.com/rbontekoe/TestAppliAR.git`
2. Start Julia and Add IJulia: using Pkg; Pkg.add("IJulia");
3. Enable local environment: Pkg.activate(".")
4. julia> using IJulia
5. julia> notebook(dir=".", detached=true)
6. Open and run code: ar.ipynb

