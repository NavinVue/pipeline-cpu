onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib inst_rom_ip_opt

do {wave.do}

view wave
view structure
view signals

do {inst_rom_ip.udo}

run -all

quit -force
