/*
 * Copyright 2025 BSC*
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

import sargantana_icache_pkg::*;


`timescale 1 ns/ 1 ns
module tb_drac_icache();

logic clk_i  ;
logic rstn_i ;

tresp_i_t      itlb_tresp_i ;
ifill_resp_i_t ifill_resp_i ;

top_drac top_drac(
    .itlb_tresp_i (itlb_tresp_i) ,
    .ifill_resp_i (ifill_resp_i) ,
    .CLK                           ( clk_i   ) ,
    .RST                           ( rstn_i  ) ,
    .SOFT_RST                      (  ) ,
    .RESET_ADDRESS                 ( 40'h200 ) ,
    // CSR INPUT INTERFACE                 
    .CSR_RW_RDATA                  (  ),
    .CSR_CSR_STALL                 (  ),
    .CSR_XCPT                      (  ),
    .CSR_ERET                      (  ),
    .CSR_EVEC                      (  ),
    .CSR_INTERRUPT                 (  ),
    .CSR_INTERRUPT_CAUSE           (  ),
    // D-CACHE  INTERFACE                       
    .DMEM_ORDERED                  (  ),
    .DMEM_REQ_READY                (  ),
    .DMEM_RESP_BITS_DATA_SUBW      (  ),
    .DMEM_RESP_BITS_NACK           (  ),
    .DMEM_RESP_BITS_REPLAY         (  ),
    .DMEM_RESP_VALID               (  ),
    .DMEM_XCPT_MA_ST               (  ),
    .DMEM_XCPT_MA_LD               (  ),
    .DMEM_XCPT_PF_ST               (  ),
    .DMEM_XCPT_PF_LD               (  ),
    // FETCH  INTERFACE                         
    .IO_FETCH_PC_VALUE             (  ),
    .IO_FETCH_PC_UPDATE            (  ),
    // DEBUGGING MODULE SIGNALS                
    .IO_REG_READ                   (  ),
    .IO_REG_ADDR                   (  ),     
    .IO_REG_WRITE                  (  ),
    .IO_REG_WRITE_DATA             (  ),
    .istall_test                   (  ),    
    // CSR OUTPUT INTERFACE           
    .CSR_RW_ADDR                   (  ),
    .CSR_RW_CMD                    (  ),
    .CSR_RW_WDATA                  (  ),
    .CSR_EXCEPTION                 (  ),
    .CSR_RETIRE                    (  ),
    .CSR_CAUSE                     (  ),
    .CSR_PC                        (  ),
    // D-CACHE  OUTPUT INTERFACE                
    .DMEM_REQ_VALID                (  ),  
    .DMEM_OP_TYPE                  (  ),
    .DMEM_REQ_CMD                  (  ),
    .DMEM_REQ_BITS_DATA            (  ),
    .DMEM_REQ_BITS_ADDR            (  ),
    .DMEM_REQ_BITS_TAG             (  ),
    .DMEM_REQ_INVALIDATE_LR        (  ),
    .DMEM_REQ_BITS_KILL            (  ),
    // DEBUGGING MODULE SIGNALS                
    // PC                                  
    .IO_FETCH_PC                   (  ),
    .IO_DEC_PC                     (  ),
    .IO_RR_PC                      (  ),
    .IO_EXE_PC                     (  ),
    .IO_WB_PC                      (  ),
    .IO_WB_PC_VALID                (  ),
    .IO_WB_ADDR                    (  ),
    .IO_WB_WE                      (  ),
    .IO_WB_BITS_ADDR               (  ),
    .IO_REG_READ_DATA              (  ),
    // PMU INTERFACE                            
    .io_core_pmu_branch_miss       (  ),
    .io_core_pmu_EXE_STORE         (  ),
    .io_core_pmu_EXE_LOAD          (  ),
    .io_core_pmu_new_instruction   (  )    
);


initial clk_i = 1'b1;
always #25 clk_i = ~clk_i;

task automatic reset;
    begin
        rstn_i <= 1'b0; 
        #50;
        rstn_i <= 1'b1;
    end
endtask


task automatic set;
    begin
        clk_i              <= 1'b1;
        rstn_i             <= 1'b0;
        ifill_resp_i       <=  '{default:0};  
        itlb_tresp_i       <=  '{default:0}; 
        $display("Running testbench");
    end
endtask

initial begin
    set();
    reset();
    //#6700 //- The time needed to flush the valid bits.

end

endmodule
