/* 
 * Testbench for simple 8-bit CPU.
 * Copyright (C) 2015, 16 John Tzonevrakis.
 * License exception for cpu_tb.v *ONLY*!
 *
 * This testbench is licensed under the terms of the ISC license:
 * Permission to use, copy, modify, and/or distribute this software for any 
 * purpose with or without fee is hereby granted, provided that the above 
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
 * DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER 
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, 
 * ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF 
 * THIS SOFTWARE.
 *
 *
*/

// Modifications done by Al Williams (of HackADay) visible here:
// Added small program and user memory for simulation
module programmem(input [7:0] pgmaddr, output [7:0] pgmdata);
    reg [7:0] pmemory[255:0];
    assign pgmdata=pmemory[pgmaddr];

    initial
        begin
            /*pmemory[0]=8'hf0; // LDUMEM 00,0
            pmemory[0]=8'h00;
            pmemory[2]=8'h90; // JMP 40
            pmemory[3]=8'd40;
            pmemory[40]=8'h20; // NOT a
            pmemory[41]=8'he0; // ST a,ff
            pmemory[42]=8'hff;
            pmemory[43]=8'h90; //JMP 02
            pmemory[44]=8'd02;
            pmemory[254]=8'h90; // Interrupt vector
            pmemory[255]=8'd40;*/
            pmemory[0]=8'h80;
            pmemory[1]=8'hde;
            pmemory[2]=8'h20;
            pmemory[3]=8'h30;
            pmemory[4]=8'h90;
            pmemory[5]=8'd00;
    end
endmodule

// Simple user memory for simulation
module usermem(input clk, input [7:0] uaddr, inout [7:0] udata, input rw);
    reg [7:0] umemory[255:0];
    assign udata=rw?8'bz:umemory[uaddr];
    always @(negedge clk) 
        if (rw==1) umemory[uaddr]<=udata;
  
    initial
    begin
        umemory[0]=8'hff;
        umemory[1]=8'h33;
        umemory[2]=8'hAA;
    end
endmodule

module cpu_tb;
    reg clk, reset, interrupt;
    wire [7:0] datamem_data, usermem_data_in, usermem_data_out, datamem_address, usermem_address, idata;
    wire rw;
    programmem pgm(datamem_address,idata);
    usermem umem(clk, usermem_address,usermem_data,rw);
    cpu dut0(clk, reset, interrupt, idata, usermem_data_in, 
             datamem_address, usermem_address, usermem_data_out, rw);
    initial
    begin
        $display("NopCPU testbench. All waveforms will be dumped to the dump.vcd file.");
        $dumpfile("waves.vcd");
        $dumpvars(0, dut0);
        $monitor("Clock: %b Reset: %b \nAddress (Datamem): %h Address: (Usermem): %h)\n Data (Datamem): %h Data (Usermem) (in): %h Data (Usermem) (out): %h R/W: %b\n Time: %d\n",clk,reset,datamem_address,usermem_address,datamem_data, usermem_data_in, usermem_data_out,rw,$time);
        clk = 1'b0;
        reset = 1'b1;
        interrupt = 1'b0;
        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;
        end
        always begin
            forever begin
                #1 clk = !clk;
            end
        end
        /* Comment this out to test interrupts: */
        /*always
        begin
            #25 interrupt = ~interrupt;
            #2 interrupt = ~interrupt;
        end*/
endmodule //cpu_tb
