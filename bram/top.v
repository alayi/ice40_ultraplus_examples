`include "implicit_bram.v"
`include "explicit_bram.v"

//example of a small memory implementation using bram, both inferred with a verilog array
//and an explicit using the bram primitive in yosys
//bram cannot be read and written at the same time

module top(input [3:0] SW, input clk, output LED_R, output LED_G, output LED_B);

   reg ib_rd_en;
   reg ib_wr_en;
   reg [7:0] ib_rd_addr;
   reg [7:0] ib_wr_addr;
   reg [15:0] ib_data_in;
   wire [15:0] ib_data_out;
   wire ib_valid_out;

   implicit_bram implicit_bram_inst(
    .clk(clk), .rd_en(ib_rd_en), .wr_en(ib_wr_en), .rd_addr(ib_rd_addr), .wr_addr(ib_wr_addr), .data_in(ib_data_in), .data_out(ib_data_out), .valid_out(ib_valid_out)
   );

   reg eb_rd_en;
   reg eb_wr_en;
   reg [7:0] eb_rd_addr;
   reg [7:0] eb_wr_addr;
   reg [15:0] eb_data_in;
   wire [15:0] eb_data_out;
   wire eb_valid_out;

   explicit_bram explicit_bram_inst(
    .clk(clk), .rd_en(eb_rd_en), .wr_en(eb_wr_en), .rd_addr(eb_rd_addr), .wr_addr(eb_wr_addr), .data_in(eb_data_in), .data_out(eb_data_out), .valid_out(eb_valid_out)
   );

   reg [7:0] state;
   reg [2:0] led;

   //leds are active low
   assign LED_R = ~led[0];
   assign LED_G = ~led[1];
   assign LED_B = ~led[2];

   initial begin
      ib_rd_en = 0;
      ib_wr_en = 0;
      ib_rd_addr = 0;
      ib_wr_addr = 0;
      ib_data_in = 0;

      eb_rd_en = 0;
      eb_wr_en = 0;
      eb_rd_addr = 0;
      eb_wr_addr = 0;
      eb_data_in = 0;

      state = 0;
      led = 0;
   end

   always @(posedge clk)
   begin

      ib_rd_en <= 0;
      ib_wr_en <= 0;
      ib_rd_addr <= 0;
      ib_wr_addr <= 0;
      ib_data_in <= 0;

      eb_rd_en <= 0;
      eb_wr_en <= 0;
      eb_rd_addr <= 0;
      eb_wr_addr <= 0;
      eb_data_in <= 0;

      state <= state + 1;

      //implicit/inferred module
      //commant this and uncomment the explicit logic below to use explicit module
      if (state == 0) begin
         ib_wr_en <= 1;
         ib_wr_addr <= 8'd14;
         ib_data_in <= 32'b010;
      end else if (state == 1) begin
         ib_wr_en <= 1;
         ib_wr_addr <= 8'd15;
         ib_data_in <= 32'b110;
      end else if (state == 3) begin
         ib_rd_en <= 1;
         ib_rd_addr <= 8'd14;
      end else if (state == 4) begin
         led <= ib_data_out[2:0];
      end

      //explicit module
      //uncomment this and comment the implicit logic above to use this
      // if (state == 0) begin
      //    eb_wr_en <= 1;
      //    eb_wr_addr <= 8'd14;
      //    eb_data_in <= 32'b010;
      // end else if (state == 1) begin
      //    eb_wr_en <= 1;
      //    eb_wr_addr <= 8'd15;
      //    eb_data_in <= 32'b110;
      // end else if (state == 3) begin
      //    eb_rd_en <= 1;
      //    eb_rd_addr <= 8'd14;
      // end else if (state == 4) begin
      //    led <= eb_data_out[2:0];
      // end
   end

endmodule
