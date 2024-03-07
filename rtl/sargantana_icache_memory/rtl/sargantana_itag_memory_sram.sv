/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : itag_memory.sv
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


module sargantana_itag_memory_sram
#(
    parameter int unsigned ICACHE_N_WAY     = 4,
    parameter int unsigned TAG_DEPTH        = 64,
    parameter int unsigned TAG_ADDR_WIDHT   = $clog2( TAG_DEPTH ),
    parameter int unsigned TAG_WIDHT        = 20
)
(
    input  logic                                   clk_i      ,
    input  logic                                   rstn_i     ,
    input  logic                [ICACHE_N_WAY-1:0] req_i      ,
    input  logic                                   we_i       ,
    input  logic                                   vbit_i     ,
    input  logic                                   flush_i    ,
    input  logic                   [TAG_WIDHT-1:0] data_i     ,
    input  logic              [TAG_ADDR_WIDHT-1:0] addr_i     ,
    output logic [ICACHE_N_WAY-1:0][TAG_WIDHT-1:0] tag_way_o  , //- one for each way.
    output logic                [ICACHE_N_WAY-1:0] vbit_o       
);

//- To build a memory of tags for each path.

//Valid bit wires
logic [TAG_DEPTH-1:0] vbit_vec [ICACHE_N_WAY-1:0];

//--VALID bit vector
genvar i;
generate
for ( i=0; i<ICACHE_N_WAY; i++ )begin
    always_ff @(posedge clk_i) begin
        if(!rstn_i || flush_i) begin
            vbit_vec[i] <= '0; 
            vbit_o[i] <= '0;
        end else if(req_i[i]) begin
            if(we_i) vbit_vec[i][addr_i] <= vbit_i;
            else vbit_o[i] <= vbit_vec[i][addr_i];
        end
    end
end
endgenerate

`ifdef SRAM_IP
    logic [ICACHE_N_WAY-1:0][TAG_WIDHT-1:0] mask;
    logic chip_enable;

    assign chip_enable = |req_i;

    always_comb begin
        for (int i = 0; i < ICACHE_N_WAY; i++) begin
            mask[i] = {TAG_WIDHT{req_i[i] & we_i}};
        end
    end

    asic_sram_1p #(
        .ADDR_WIDTH(TAG_ADDR_WIDHT),
        .DATA_WIDTH(ICACHE_N_WAY * TAG_WIDHT)
    ) sram (
        .A(addr_i),
        .DI({ICACHE_N_WAY{data_i}}),
        .BW(mask),
        .CLK(clk_i),
        .CE(chip_enable),
        .RDWEN(we_i),
        .DO(tag_way_o)
    );

`endif //SRAM_IP

endmodule
