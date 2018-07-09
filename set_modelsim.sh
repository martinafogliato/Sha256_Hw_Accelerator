export PATH=$PATH:/home/marti/intelFPGA_pro/17.1/modelsim_ase/bin:/opt/Xilinx/Vivado/2017.4/bin:/opt/Xilinx/SDK/2017.4/bin
vhdl=/home/marti/Desktop/DS/ds-2018/sha256/vhdl
ds2018=/home/marti/Desktop/DS/ds-2018
scripts=/home/marti/Desktop/DS/ds-2018/sha256/scripts
tmp=/tmp/marti/sha256
mkdir -p $tmp
cd $tmp
vlib myLib
vmap work myLib

vcom $vhdl/sha256_pkg.vhd
vcom $vhdl/axi_pkg.vhd
vcom $vhdl/sha256_exp_unit.vhd
vcom $vhdl/fa.vhd
vcom $vhdl/csa.vhd
vcom $vhdl/sha256_core.vhd
vcom $vhdl/sha256_cu.vhd
vcom $vhdl/sha256.vhd
vcom $vhdl/sha256_ctrl_axi.vhd
