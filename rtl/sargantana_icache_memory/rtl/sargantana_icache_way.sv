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
#(
    parameter int unsigned ICACHE_DEPTH = 64,
    parameter int unsigned SET_WIDHT    = 32*8,
    parameter int unsigned ADDR_WIDHT   = 6
)
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
    sargantana_set_ram #(
        .ICACHE_DEPTH   ( ICACHE_DEPTH  ),
        .SET_WIDHT      ( SET_WIDHT     ),
        .ADDR_WIDHT     ( ADDR_WIDHT    )
    ) sram(
        .clk_i (clk_i ),
        .rstn_i(rstn_i),
        .req_i (req_i ),
        .we_i  (we_i  ),
        .addr_i(addr_i),
        .data_i(data_i),  
        .data_o(data_o) 
    );
`else
    asic_sram_1p #(
        .ADDR_WIDTH(ADDR_WIDHT),
        .DATA_WIDTH(SET_WIDHT)
    ) sram (
       .A(addr_i),
       .DI(data_i),
       .BW({SET_WIDHT{we_i}}),
       .CLK(clk_i),
       .CE(req_i),
       .RDWEN(we_i),
       .DO(data_o)
    );
`endif

endmodule
