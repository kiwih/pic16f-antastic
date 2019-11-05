vsim work.pic16fantastic_on_de2_115
add wave -position insertpoint  \
sim:/pic16fantastic_on_de2_115/CLOCK_50 \
sim:/pic16fantastic_on_de2_115/KEY \
sim:/pic16fantastic_on_de2_115/SW
force -freeze sim:/pic16fantastic_on_de2_115/CLOCK_50 1 0, 0 {50 ps} -r 100
force -freeze sim:/pic16fantastic_on_de2_115/KEY 1111 0
force -freeze sim:/pic16fantastic_on_de2_115/SW 01010101 0
add wave -position insertpoint  \
sim:/pic16fantastic_on_de2_115/LEDG
add wave -position insertpoint sim:/pic16fantastic_on_de2_115/core/*
run
run
run
run
force -freeze sim:/pic16fantastic_on_de2_115/KEY 0000 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run