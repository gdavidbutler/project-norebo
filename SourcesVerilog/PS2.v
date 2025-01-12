// Project Oberon, Revised Edition 2013
// Copyright (C)2013 Niklaus Wirth (NW), Juerg Gutknecht (JG), Paul Reed (PR/PDR).
//
// Permission to use, copy, modify, and/or distribute this software and its
// accompanying documentation (the "Software") for any purpose with or
// without fee is hereby granted, provided that the above copyright notice
// and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
// WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
// CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
// AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.

`timescale 1ns / 1ps  // NW 20.10.2012
// PS2 receiver for keyboard, 8 bit data
// clock is 25 MHz; 25000 / 1302 = 19.2 KHz

module PS2(
    input clk, rst,
    input done,   // "byte has been read"
    output rdy,   // "byte is available"
    output shift, // shift in, tramsmitter
    output [7:0] data,
    input PS2C,   // serial input
    input PS2D);
	 
reg Q0, Q1;  // synchronizer and falling edge detector
reg [10:0] shreg;
reg [3:0] inptr, outptr;
reg [7:0] fifo [15:0];  // 16 byte buffer
wire endbit;

assign endbit = ~shreg[0];  //start bit reached correct pos
assign shift = Q1 & ~Q0;
assign data = fifo[outptr];
assign rdy = ~(inptr == outptr);

always @ (posedge clk) begin
  Q0 <= PS2C; Q1 <= Q0;
  shreg <= (~rst | endbit) ? 11'h7FF :
    shift ? {PS2D, shreg[10:1]} : shreg;
  outptr <= ~rst ? 0 : rdy & done ? outptr+1 : outptr;
  inptr <= ~rst ? 0 : endbit ? inptr+1 : inptr;
  if (endbit) fifo[inptr] <= shreg[8:1];
end	 
endmodule
