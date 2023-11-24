/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : icache_way.sv
 * Organization   : Barcelona Supercomputing Center
 * Author(s)      : Neiel I. Leyva Santes. 
 * Email(s)       : neiel.leyva@bsc.es
 * References     : 
 * -----------------------------------------------
 * Revision History
 *  Revision   | Author    | Commit | Description
 *  ******     | Neiel L.  |        | 
 * -----------------------------------------------
 */


module sargantana_icache_way 
    import sargantana_icache_pkg::*;
(
    input  logic                  clk_i      ,
    input  logic                  rstn_i     ,
    input  logic                  req_i      ,
    input  logic                  we_i       ,
    input  logic  [SET_WIDHT-1:0] data_i     ,
    input  logic [ADDR_WIDHT-1:0] addr_i     ,
    output logic  [SET_WIDHT-1:0] data_o     
);

`ifndef SRAM_IP
    sargantana_set_ram sram(
        .clk_i (clk_i ),
        .rstn_i(rstn_i),
        .req_i (req_i ),
        .we_i  (we_i  ),
        .addr_i(addr_i),
        .data_i(data_i),  
        .data_o(data_o) 
    );
`else
    logic [255:0] RW0O_sram;
    logic [255:0]  write_data;
    logic [ADDR_WIDHT-1:0] address;
    logic write_enable;
    logic chip_enable;
    
	assign write_data = data_i;
	assign write_enable = ~we_i;
	assign chip_enable = ~req_i;
	assign address = addr_i;
        
    RF_2P_128x256_M1B2S2 L1InstArray (
        .CENA(1'b0),
	    .AA(address),
	    .CENB(1'b0),
	    .AB(address),
	    .DB(write_data),
	    .WENB({128{write_enable}}),
	    .STOV(1'b0),
	    .EMAA(3'b000),
	    .EMASA(1'b0),
	    .EMAB(3'b000),
	    .RET(1'b0),
	    .QNAPA(1'b0),
	    .QNAPB(1'b0),
	    .CLKA(clk_i),
	    .CLKB(clk_i),
	    .QA(RW0O_sram)
    );
    
    assign data_o = RW0O_sram;
`endif

endmodule
