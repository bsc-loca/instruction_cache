/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : sargantana_icache_pkg.sv
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

package sargantana_icache_pkg;


typedef enum logic[2:0] {NO_REQ, 
                         READ, 
                         MISS, 
                         TLB_MISS, 
                         REPLAY, 
                         KILL,
                         REPLAY_TLB,
                         KILL_TLB
                     } ictrl_state_t;

endpackage

