/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : icache_checker.sv
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



module sargantana_icache_checker
    import sargantana_icache_pkg::*;
#(
    parameter logic LINES_256   = 1'b0
)
(
    input  logic                           cmp_enable_q     ,
    input  logic    [ICACHE_TAG_WIDTH-1:0] cline_tag_d      , //- From mmu, paddr.
    input  logic        [ICACHE_N_WAY-1:0] way_valid_bits_i ,
    input  logic                   [ 1:0 ] fetch_idx_i      ,    
    input  logic           [WAY_WIDHT-1:0] ifill_data_i     , //- Cache line. 
    output logic        [ICACHE_N_WAY-1:0] cline_hit_o      ,
    output logic         [FETCH_WIDHT-1:0] data_o           ,
    
    input  logic [ICACHE_N_WAY-1:0][TAG_WIDHT-1:0] read_tags_i,
    input  logic [ICACHE_N_WAY-1:0][WAY_WIDHT-1:0] data_rd_i    //- Cache lines read.

);

logic          [$clog2(ICACHE_N_WAY)-1:0] idx      ;
logic [ICACHE_N_WAY-1:0][FETCH_WIDHT-1:0] cline_sel;
    
genvar i;
generate
for (i=0;i<ICACHE_N_WAY;i++) begin : tag_cmp
    assign cline_hit_o[i]  = (read_tags_i[i] == cline_tag_d) & way_valid_bits_i[i];
    assign cline_sel[i]    = chunk_sel(data_rd_i[i],fetch_idx_i[0]);
end
endgenerate

// find valid cache line
sargantana_icache_tzc_idx tzc_idx (
    .in_i  ( cline_hit_o  ),
    .way_o ( idx          )
);

function automatic logic [FETCH_WIDHT-1:0] chunk_sel(
    input logic [255:0] data,
    input logic offset
  );
    logic [FETCH_WIDHT-1:0] out;
    if (LINES_256) begin    // 256b fetch
        out = data;
    end
    else begin              // 128b fetch
        unique case(offset)
          1'b0:   out = {{128{1'b0}}, data[127 : 0]};
          1'b1:   out = {{128{1'b0}}, data[255 : 128]};
          default: out = '0; 
        endcase 
    end
    return out;
endfunction : chunk_sel


assign data_o = cline_sel[idx] ;

                                 
endmodule
