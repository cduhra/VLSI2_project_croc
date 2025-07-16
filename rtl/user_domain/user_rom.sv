// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

`include "common_cells/registers.svh"

// simple ROM
module user_rom #(
  parameter obi_pkg::obi_cfg_t ObiCfg = obi_pkg::ObiDefaultConfig,
  parameter type obi_req_t = logic,
  parameter type obi_rsp_t = logic
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  obi_req_t obi_req_i,
  output obi_rsp_t obi_rsp_o
);

  localparam Addr_Size = 8;

  // Registers to hold the request fields
  logic req_d, req_q, req_q2;
  logic we_d, we_q, we_q2;
  logic [ObiCfg.AddrWidth-1:0] addr_d, addr_q, addr_q2;
  logic [ObiCfg.IdWidth-1:0] id_d, id_q, id_q2;

  // Response signals
  logic [ObiCfg.DataWidth-1:0] rsp_data;
  logic rsp_err;

  // Register assignments
  assign req_d  = obi_req_i.req;
  assign id_d   = obi_req_i.a.aid;
  assign we_d   = obi_req_i.a.we;
  assign addr_d = obi_req_i.a.addr;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      req_q   <= '0;
      id_q    <= '0;
      we_q    <= '0;
      addr_q  <= '0;
      req_q2  <= '0;
      id_q2   <= '0;
      we_q2   <= '0;
      addr_q2 <= '0;
    end else begin
      req_q   <= req_d;
      id_q    <= id_d;
      we_q    <= we_d;
      addr_q  <= addr_d;
      req_q2  <= req_q;
      id_q2   <= id_q;
      we_q2   <= we_q;
      addr_q2 <= addr_q;
    end
  end

  logic [Addr_Size-1:0] word_addr;
  always_comb begin
    rsp_data = '0;
    rsp_err  = '0;
    word_addr = addr_q2[Addr_Size+1:2];
    if (req_q2) begin
      if (~we_q2) begin
        case (word_addr[2:0]) // Use only lower 3 bits for up to 8 words
          3'b000: rsp_data = 32'h49502E54; // T.PIG
          3'b001: rsp_data = 32'h414E4749; // INGA
          3'b010: rsp_data = 32'h2E43444E; // NDC.
          3'b011: rsp_data = 32'h27415248; // HRA'
          3'b100: rsp_data = 32'h53412073; // s AS
          3'b101: rsp_data = 32'h00004349; // IC\0\0
          3'b110: rsp_data = 32'h00000000;
          3'b111: rsp_data = 32'h00000000;
          default: rsp_data = 32'h0;
        endcase
      end else begin
        rsp_err = '1;
      end
    end
  end

  // OBI response assignments
  assign obi_rsp_o.gnt         = obi_req_i.req;
  assign obi_rsp_o.rvalid      = req_q2;
  assign obi_rsp_o.r.rdata     = rsp_data;
  assign obi_rsp_o.r.rid       = id_q2;
  assign obi_rsp_o.r.err       = rsp_err;
  assign obi_rsp_o.r.r_optional = '0;

endmodule