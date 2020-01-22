import constants::*;
import wires::*;

module csr
(
  input logic rst,
  input logic clk,
  input csr_in_type csr_in,
  output csr_out_type csr_out
);

  csr_machine_reg_type csr_machine_reg;

  logic [0:0] exception;
  logic [0:0] mret;

  always_comb begin
    if (csr_in.csr_rden == 1) begin
      case (csr_in.csr_raddr)
        csr_mstatus : csr_out.csr_rdata = csr_machine_reg.mstatus;
        csr_misa : csr_out.csr_rdata = csr_machine_reg.misa;
        csr_medeleg : csr_out.csr_rdata = csr_machine_reg.medeleg;
        csr_mideleg : csr_out.csr_rdata = csr_machine_reg.mideleg;
        csr_mie : csr_out.csr_rdata = csr_machine_reg.mie;
        csr_mtvec : csr_out.csr_rdata = csr_machine_reg.mtvec;
        csr_mcounteren : csr_out.csr_rdata = csr_machine_reg.mcounteren;
        csr_mscratch : csr_out.csr_rdata = csr_machine_reg.mscratch;
        csr_mepc : csr_out.csr_rdata = csr_machine_reg.mepc;
        csr_mcause : csr_out.csr_rdata = csr_machine_reg.mcause;
        csr_mtval : csr_out.csr_rdata = csr_machine_reg.mtval;
        csr_mip : csr_out.csr_rdata = csr_machine_reg.mip;
        csr_mcycle : csr_out.csr_rdata = csr_machine_reg.mcycle[31:0];
        csr_mcycleh : csr_out.csr_rdata = csr_machine_reg.mcycle[63:32];
        csr_minstret : csr_out.csr_rdata = csr_machine_reg.minstret[31:0];
        csr_minstreth : csr_out.csr_rdata = csr_machine_reg.minstret[63:32];
        default :;
      endcase
    end

    csr_out.exception = exception;
    csr_out.mret = mret;
    csr_out.mepc = csr_machine_reg.mepc;
    if (csr_machine_reg.mtvec[1:0] == 1) begin
      csr_out.mtvec = {(csr_machine_reg.mtvec[31:2] + {26'b0,csr_machine_reg.mcause[3:0]}),2'b0};
    end else begin
      csr_out.mtvec = {csr_machine_reg.mtvec[31:2],2'b0};
    end

  end

  always_ff @(posedge clk) begin

    if (rst == 0) begin

      csr_machine_reg <= init_csr_machine_reg;

    end else begin

      if (csr_in.csr_wren == 1) begin
        case (csr_in.csr_waddr)
          csr_mstatus : csr_machine_reg.mstatus <= csr_in.csr_wdata;
          csr_misa : csr_machine_reg.misa <= csr_in.csr_wdata;
          csr_medeleg : csr_machine_reg.medeleg <= csr_in.csr_wdata;
          csr_mideleg : csr_machine_reg.mideleg <= csr_in.csr_wdata;
          csr_mie : csr_machine_reg.mie <= csr_in.csr_wdata;
          csr_mtvec : csr_machine_reg.mtvec <= csr_in.csr_wdata;
          csr_mcounteren : csr_machine_reg.mcounteren <= csr_in.csr_wdata;
          csr_mscratch : csr_machine_reg.mscratch <= csr_in.csr_wdata;
          csr_mepc : csr_machine_reg.mepc <= csr_in.csr_wdata;
          csr_mcause : csr_machine_reg.mcause <= csr_in.csr_wdata;
          csr_mtval : csr_machine_reg.mtval <= csr_in.csr_wdata;
          csr_mip : csr_machine_reg.mip <= csr_in.csr_wdata;
          csr_mcycle : csr_machine_reg.mcycle[31:0] <= csr_in.csr_wdata;
          csr_mcycleh : csr_machine_reg.mcycle[63:32] <= csr_in.csr_wdata;
          csr_minstret : csr_machine_reg.minstret[31:0] <= csr_in.csr_wdata;
          csr_minstreth : csr_machine_reg.minstret[63:32] <= csr_in.csr_wdata;
          default :;
        endcase
      end

      if (csr_in.valid == 1) begin
        csr_machine_reg.minstret <= csr_machine_reg.minstret + 1;
      end

      csr_machine_reg.mcycle <= csr_machine_reg.mcycle + 1;

      if (csr_in.exception == 1) begin
        csr_machine_reg.mstatus[7] <= csr_machine_reg.mstatus[3];
        csr_machine_reg.mstatus[3] <= 0;
        csr_machine_reg.mepc <= csr_in.epc;
        csr_machine_reg.mtval <= csr_in.etval;
        csr_machine_reg.mcause <= {28'b0,csr_in.ecause};
        exception <= 1;
      end else begin
        exception <= 0;
      end

      if (csr_in.mret == 1) begin
        csr_machine_reg.mstatus[3] <= csr_machine_reg.mstatus[7];
        csr_machine_reg.mstatus[7] <= 0;
        mret <= 1;
      end else begin
        mret <= 0;
      end

    end
  end

endmodule