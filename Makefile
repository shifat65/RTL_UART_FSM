baud:
	iverilog -o out_baud.vvp tb_baud.v baud_gen.v comparator.v counter.v
	vvp out_baud.vvp
g_baud:
	gtkwave --autosave tb_baud.vcd

tx:
	iverilog -o out_tx.vvp tb_tx.v uart_tx.v baud_gen.v comparator.v counter.v
	vvp out_tx.vvp
g_tx:
	gtkwave --autosave tb_tx.vcd

rx:
	iverilog -o out_rx.vvp tb_rx.v uart_rx.v baud_gen.v comparator.v counter.v 
	vvp out_rx.vvp
g_rx:
	gtkwave --autosave tb_rx.vcd


clean:
	rm -f *vcd *.vvp *out 