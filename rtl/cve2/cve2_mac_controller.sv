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
    input  cve2_pkg::md_op_e        mac_md_operator_i, // Multiplier operator for MAC
    input  logic                    mac_en_i,   // MAC enable
    input  logic                    valid_ex_i, // EX stage has valid output

    // Outputs
    output cve2_pkg::alu_op_e       alu_operator_o, // Output ALU operator
    output logic                    mac_en_2_cycles_o, // MAC enable for 2 cycles
    output logic                    mac_mul_en_o,      // Add this to the port list
    output cve2_pkg::md_op_e        mac_md_operator_o,   // Multiplier operator for MAC
    output logic                    mac_mul_en_comb_o  // Combinational output for MAC multiplier enable
);
    // In idle mode the signal must be transparent
    typedef enum logic [1:0] {IDLE, MUL, ADD} mac_state_e;
    mac_state_e state_q, state_d;

    // Output registers
    cve2_pkg::alu_op_e alu_operator_d, alu_operator_q;
    logic mac_en_2_cycles_d, mac_en_2_cycles_q;
    logic mac_mul_en_d, mac_mul_en_q;
    cve2_pkg::md_op_e mac_md_operator_d, mac_md_operator_q;

    // State transition logic
    always_comb begin
        state_d = state_q;
        alu_operator_d = alu_operator_q;
        mac_en_2_cycles_d = 1'b0;
        mac_mul_en_o = mac_mul_en_q;
        mac_mul_en_comb_o = mac_mul_en_d;
        mac_md_operator_d = mac_md_operator_q;

        case (state_q)
            IDLE: begin
                if (alu_operator_i == cve2_pkg::ALU_MAC && mac_en_i) begin
                    state_d = MUL;
                    mac_mul_en_d = 1'b1; // Enable multiplier
                    mac_md_operator_d = cve2_pkg::MD_OP_MULL; // Set multiplier op
                    alu_operator_d = alu_operator_q; // ALU always does ADD for MAC
                    mac_en_2_cycles_d = 1'b1;
                    $display("[MAC CTRL] IDLE->MUL: alu_operator_d=%0d (ALU_MAC)", alu_operator_d);
                    
                end else begin
                    mac_en_2_cycles_d = 1'b0;
                    alu_operator_d = alu_operator_i;
                    mac_md_operator_d = mac_md_operator_i;
                    mac_mul_en_d = 1'b0;
                    // $display("[MAC CTRL] IDLE: alu_operator_d=%0d (passthrough)", alu_operator_d);
                end
            end
            MUL: begin
                mac_en_2_cycles_d = 1'b1;
                if (valid_ex_i) begin
                    state_d = ADD;
                    mac_mul_en_d = 1'b0; // Disable multiplier
                    alu_operator_d = cve2_pkg::ALU_MAC;
                    $display("[MAC CTRL] MUL->ADD: alu_operator_d=%0d (ALU_MAC)", alu_operator_d);
                end else begin
                    mac_mul_en_d = 1'b1;
                    alu_operator_d = alu_operator_q; // Keep ALU operator as MAC
                    mac_md_operator_d = mac_md_operator_q;
                    $display("[MAC CTRL] MUL: alu_operator_d=%0d (ALU_MAC)", alu_operator_d);
                end
                
            end
            ADD: begin
                alu_operator_d = cve2_pkg::ALU_MAC;
                mac_en_2_cycles_d = 1'b1;
                state_d = IDLE;
                mac_mul_en_d = 1'b0;
                mac_md_operator_d = mac_md_operator_q;
                $display("[MAC CTRL] ADD->IDLE: alu_operator_d=%0d (ALU_MAC)", alu_operator_d);
            end
            default: begin
                state_d = IDLE;
                alu_operator_d = alu_operator_q;
                mac_en_2_cycles_d = 1'b0;
                mac_mul_en_d = 1'b0;
                mac_md_operator_d = mac_md_operator_q;
                $display("[MAC CTRL] DEFAULT: alu_operator_d=%0d (passthrough)", alu_operator_d);
            end
        endcase
    end

    // FlipFlop for state and output registers
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q <= IDLE;
            alu_operator_q <= alu_operator_i;
            mac_en_2_cycles_q <= 1'b0;
            mac_mul_en_q <= 1'b0;
            mac_md_operator_q <= mac_md_operator_i;
        end else begin
            state_q <= state_d;
            alu_operator_q <= alu_operator_d;
            mac_en_2_cycles_q <= mac_en_2_cycles_d;
            mac_mul_en_q <= mac_mul_en_d;
            mac_md_operator_q <= mac_md_operator_d;
        end
    end

    assign alu_operator_o = alu_operator_q;
    assign mac_en_2_cycles_o = mac_en_2_cycles_q;
    assign mac_mul_en_o = mac_mul_en_q;
    assign mac_md_operator_o = mac_md_operator_q;
    always_ff @(posedge clk_i) begin
        if (mac_en_i && alu_operator_i == cve2_pkg::ALU_MAC)
            $display("[MAC CTRL] MAC detected: state_q=%0d mac_mul_en_d=%b", state_q, mac_mul_en_d);
        if (mac_mul_en_o)
            $display("[MAC CTRL] mac_mul_en_o asserted: state_q=%0d", state_q);
    end
    
endmodule