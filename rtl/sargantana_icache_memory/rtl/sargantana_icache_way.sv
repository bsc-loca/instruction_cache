/*
 * Copyright 2023 BSC*
 * *Barcelona Supercomputing Center (BSC)
 * 
 * SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 * 
 * Licensed under the Solderpad Hardware License v 2.1 (the “License”); you
 * may not use this file except in compliance with the License, or, at your
 * option, the Apache License version 2.0. You may obtain a copy of the
 * License at
 * 
 * https://solderpad.org/licenses/SHL-2.1/
 * 
 * Unless required by applicable law or agreed to in writing, any work
 * distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
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

//Build the number of sets of one way.
//genvar i;
//generate
//for ( i=0; i<ICACHE_N_SET; i++ )begin:n_set
//set_ram sram(
//    .clk_i (clk_i ),
//    .rstn_i(rstn_i),
//    .req_i (req_i ),
//    .we_i  (we_i  ),
//    .addr_i(addr_i),
//    .data_i(data_i [i*SET_WIDHT +: SET_WIDHT]),  //- The data input is segmented 
//                                                 //  according to sets.
//    .data_o(data_o [i*SET_WIDHT +: SET_WIDHT ])  //- The acquired data are organized 
//                                                 //  into one vector.
//);
//end
//endgenerate
`ifndef SRAM_MEMORIES
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
    logic [127:0] RW0O_sram;
    logic [127:0]  write_data;
    logic [ADDR_WIDHT-1:0] address;
    logic write_enable;
    logic chip_enable;
    
	assign write_data = data_i;
	assign write_enable = ~we_i;
	assign chip_enable = ~req_i;
	assign address = addr_i;

 
    `ifdef MEMS_22NM 
		`ifdef MEMS_R1PH
			R1PH_256x128 L1InstArray (
				.CLK(clk_i),
				.CEN(chip_enable),
				.RDWEN(write_enable),
				.AW(addr_i[7:1]), // Port-A address word line inputs
				.AC(addr_i[0]), // POrt-A address column inputs
				.D(write_data), // Data
				.BW(~{128{1'b0}}), // Mask
				.T_LOGIC(1'b0), // Test logic, active high? 
				.MA_SAWL(1'b0), // Margin adjust sense amp. Default: 1'b0
				.MA_WL(1'b0),
				.MA_WRAS(1'b0),
				.MA_WRASD(1'b0),
				.Q(RW0O_sram)
            );
		`else
			R1DH_256x128 L1InstArray (
				.CLK(clk_i),
				.CEN(chip_enable),
				.RDWEN(write_enable),
				.AW(addr_i[7:1]), // Port-A address word line inputs
				.AC(addr_i[0]), // POrt-A address column inputs
				.D(write_data), // Data
				.BW(~{128{1'b0}}), // Mask
				.T_LOGIC(1'b0), // Test logic, active high? 
				.MA_SAWL(1'b0), // Margin adjust sense amp. Default: 1'b0
				.MA_WL(1'b0),
				.MA_WRAS(1'b0),
				.MA_WRASD(1'b0),
				.Q(RW0O_sram)
            );
		`endif
	
    `elsif SYNTHESIS_7NM
        RF_SP_256x128 L1InstArray (
            .A(address),
            .D(write_data),
            .CLK(clk_i),
            .CEN(1'b0), // chip-enable active-low
            .GWEN(write_enable), // write-enable active-low
            .WEN({128{1'b0}}), // write-enable active-low (WEN[0]=LSB)
            .EMA(3'b000),
            .EMAW(2'b00),
            .EMAS(1'b0),
            .Q(RW0O_sram),
            .STOV(1'b0),
            .RET(1'b0)
        );
    `else
    TS1N65LPHSA256X128M4F L1InstArray (
        .A  (address) ,
        .D  (write_data) ,
        .BWEB  ({128{1'b0}}) ,
        .WEB  (write_enable) ,
        .CEB  (chip_enable) ,
        .CLK  (clk_i) ,
        .Q  (RW0O_sram),
        .WTSEL(3'b000),
        .RTSEL(2'b00),
        .AWT(1'b0)
    ); 
    `endif
    
    assign data_o = RW0O_sram;
`endif

endmodule
