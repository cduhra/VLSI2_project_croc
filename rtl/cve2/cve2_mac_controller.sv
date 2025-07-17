// -----------------------------------------------------------------------------
// cve2_mac_controller - Description
// -----------------------------------------------------------------------------
// This module implements a simple state machine to sequence a Multiply-Accumulate
// (MAC) operation over two ALU cycles in the pipeline.
//
// - When a MAC instruction is detected (alu_operator_i == ALU_MAC and mac_en_i == 1):
//     1. The controller sets alu_operator_o to ALU_MUL for one cycle (multiplication).
//     2. On the next cycle, it sets alu_operator_o to ALU_ADD (accumulation).
//     3. The signal mac_en_2_cycles_o remains high for both cycles to indicate
//        the MAC operation is in progress.
// - After the two cycles, the controller returns to idle and passes through
//   the original ALU operator.
//
// Inputs:
//   - clk_i, rst_ni: Clock and reset.
//   - alu_operator_i: The requested ALU operation.
//   - mac_en_i: Enable signal for the MAC operation.
//
// Outputs:
//   - alu_operator_o: The ALU operation to perform (MUL, then ADD for MAC).
//   - mac_en_2_cycles_o: High for two cycles during a MAC operation.
//
// This allows the pipeline to treat a MAC instruction as a two-step operation,
// using existing ALU resources for multiplication and addition in sequence.
// -----------------------------------------------------------------------------


module cve2_mac_controller (
    // Clock and Reset
    input  logic                 clk_i,
    input  logic                 rst_ni,

    // Inputs
    input  cve2_pkg::alu_op_e       alu_operator_i,
    input  logic                    mac_en_i,   // MAC enable

    // Outputs
    output cve2_pkg::alu_op_e       alu_operator_o, // Output ALU operator
    output logic                    mac_en_2_cycles_o // MAC enable for 2 cycles
);
    // In idle mode the signal must be transparent
    typedef enum logic [1:0] {IDLE, MUL, ADD} mac_state_e;
    mac_state_e state_q, state_d;

    // Output registers
    cve2_pkg::alu_op_e alu_operator_d, alu_operator_q;
    logic mac_en_2_cycles_d, mac_en_2_cycles_q;

    // State transition logic
    always_comb begin
        state_d = state_q;
        alu_operator_d = alu_operator_q;
        mac_en_2_cycles_d = 1'b0;

        case (state_q)
            IDLE: begin
                if (alu_operator_i == cve2_pkg::ALU_MAC && mac_en_i) begin
                    state_d = MUL;
                    alu_operator_d = cve2_pkg::ALU_CLMUL;
                    mac_en_2_cycles_d = 1'b1; // Stall during MUL
                end else begin
                    alu_operator_d = alu_operator_i;
                end
            end
            MUL: begin
                alu_operator_d = cve2_pkg::ALU_ADD;
                mac_en_2_cycles_d = 1'b1; // Stall during ADD
                state_d = ADD;
            end
            ADD: begin
                alu_operator_d = alu_operator_i;
                mac_en_2_cycles_d = 1'b0;
                state_d = IDLE;
            end
            default: begin
                state_d = IDLE;
                alu_operator_d = alu_operator_i;
                mac_en_2_cycles_d = 1'b0;
            end
        endcase
    end

    // FlipFlop for state and output registers
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q <= IDLE;
            alu_operator_q <= alu_operator_i;
            mac_en_2_cycles_q <= 1'b0;
        end else begin
            state_q <= state_d;
            alu_operator_q <= alu_operator_d;
            mac_en_2_cycles_q <= mac_en_2_cycles_d;
        end
    end

    // Outputs
    assign alu_operator_o = alu_operator_q;
    assign mac_en_2_cycles_o = mac_en_2_cycles_q;
    
endmodule