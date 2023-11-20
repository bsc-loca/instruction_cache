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
  import sargantana_icache_pkg::*;
(
    input  logic                                   clk_i      ,
    input  logic                                   rstn_i     ,
    input  logic                [ICACHE_N_WAY-1:0] req_i      ,
    input  logic                                   we_i       ,
    input  logic                                   vbit_i     ,
    input  logic                                   flush_i    ,
    input  logic                   [TAG_WIDHT-1:0] data_i     ,
    input  logic                  [ADDR_WIDHT-3:0] addr_i     ,
    output logic [ICACHE_N_WAY-1:0][TAG_WIDHT-1:0] tag_way_o  , //- one for each way.
    output logic                [ICACHE_N_WAY-1:0] vbit_o       
);

//logic [ICACHE_N_WAY-1:0] mem_ready;

//- To build a memory of tags for each path.

//Valid bit wires
logic [ICACHE_DEPTH-1:0] vbit_vec [0:ICACHE_N_WAY-1];

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
`ifdef PADDR_39

  //Tag array wires
  logic [107:0] q_sram;
  logic [107:0] write_mask, write_data, w_mask, w_data, mask;
  logic write_enable;
  logic chip_enable;
  logic [ADDR_WIDHT-3:0] address;

  // Tag array SRAM implementation

  assign mask[26:0] = {27{req_i[0]}};
  assign mask[53:27] = {27{req_i[1]}};
  assign mask[80:54] = {27{req_i[2]}};
  assign mask[107:81] = {27{req_i[3]}};
  assign w_mask = {108{we_i}} & mask;
      
  assign w_data[26:0] = data_i;
  assign w_data[53:27] = data_i;
  assign w_data[80:54] = data_i;
  assign w_data[107:81] = data_i;

  assign write_mask = ~w_mask;
  assign write_data = w_data;
  assign write_enable = ~we_i;
  assign address = addr_i;
  assign chip_enable = ~(|req_i);

  RF_SP_128x108 MDArray_tag_il1 (
      .A(address),
      .D(write_data),
      .CLK(clk_i),
      .CEN(1'b0), // chip-enable active-low
      .GWEN(write_enable), // write-enable active-low
      .WEN(write_mask), // write-enable active-low (WEN[0]=LSB)
      .EMA(3'b000),
      .EMAW(2'b00),
      .EMAS(1'b0),
      .Q(q_sram),
      .STOV(1'b0),
      .RET(1'b0)
  );

  assign tag_way_o[0] = q_sram[26:0];
  assign tag_way_o[1] = q_sram[53:27];
  assign tag_way_o[2] = q_sram[80:54];
  assign tag_way_o[3] = q_sram[107:81];


`endif //PADDR_39
`endif //SRAM_IP

endmodule
