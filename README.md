# ECSE6680-VLSI-Course-Project
This project is divided into 4 steps:
FIR low pass filter:
1. MATLAB generation of COE files for fir filter coefficients and signal generator
2. Generate fir IP core and ROM IP core (vivado)
3. Write top-level .v file to exemplify fir and ROM
4. Perform top-level engineering simulations
***
## 1. MATLAB generation of COE files for fir filter coefficients and signal generator
Open the fdatool in MATLAB and set the low pass filter:
![FIR Setting-w100](./fig/fdatool.png)
After setting we can see:
![FIR Wave-w100](./fig/wave.png)
Then export the coefficients of the FIR as the *coe* format to be used in Vivado IP core:
![Coefficients-w100](./fig/export.png)
![Saved as .coe-w100](./fig/export_num.png)
![Saved as .coe-w100](./fig/coe.png)
Use sin signal generator to validate the performance of our FIR:
![sin-w100](./fig/sin_coe_generation.png)
![sin-w100](./fig/sin_coe.png)

## 2. Generate FIR IP core and ROM IP core (vivado)
Overview of the structure:
![IP core-w100](./fig/IP_core.png)

```

```
