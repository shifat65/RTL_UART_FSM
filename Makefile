baud:
	iverilog -o out_baud.vvp ./baud_gen/tb_baud.v ./baud_gen/baud_gen.v ./count_comp/comparator.v ./count_comp/counter.v
	vvp out_baud.vvp
g_baud:
	gtkwave --autosave tb_baud.vcd

tx:
	iverilog -o out_tx.vvp ./Tx_/tb_tx.v ./Tx_/uart_tx.v ./baud_gen/baud_gen.v ./count_comp/comparator.v ./count_comp/counter.v
	vvp out_tx.vvp
g_tx:
	gtkwave --autosave tb_tx.vcd

rx:
	iverilog -o out_rx.vvp ./Rx_/tb_rx.v ./Rx_/uart_rx.v ./baud_gen/baud_gen.v ./count_comp/comparator.v ./count_comp/counter.v
	vvp out_rx.vvp
g_rx:
	gtkwave --autosave tb_rx.vcd

top:
	iverilog -o out_top.vvp ./Top_/top.v ./Top_/tb_top.v ./Tx_/uart_tx.v ./Rx_/uart_rx.v ./baud_gen/baud_gen.v ./count_comp/comparator.v ./count_comp/counter.v
	vvp out_top.vvp
g_top:
	gtkwave --autosave tb_top.vcd


clean:
	rm -f *vcd *.vvp *out 