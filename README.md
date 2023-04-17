# inverter_adc_interface
IP Core for reading the ADC value out of OnSemi SAR ADC NCD98011 on a SPI-compatible interface.
The integration is done by including this source files into a AXI peripherial in a Vivado design to be synthesized onto a ZYNQ7020 SoC.

Currently 10 channels are integrated in the architecture. This can be adjusted based on the needs. Min 1 channel, Max 12 channels in parallel are tested.

The GTKWave setting are included, as I used it for simulation.

External Signals:
- CLK
- CSN
- DATA

# Prerequisites

- GHDL 
- GTKWave

# How To

``make``


Developer:
Samuel Leitenmaier 
Project: Formula Student Tractive System Inverter Development (Technical Uniersity of Applied Sciences Augsburg)
