module counter (
input wire clk,
input wire enable,
input wire reset,
output reg [3:0] count);

//you write the code!
    always @(posedge clk) begin
        if (reset == 1'b1)
        begin
            // <= is non-blocking assignment
            // always use <= in clocked processes
            count <= 4'd0;
        end
        else if (enable == 1'b1) begin
            count <= count + 1'b1;
        end
        else begin
            count <= count; // redundant but harmless
        end
      end

endmodule
