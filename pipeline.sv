module pipeline(
    input  logic        clk,
    input  logic        reset,

    
    input  logic        cpu_hit,       
    input  logic        cache_idle,     

    output logic        mem_access_valid,
    output logic [31:0] mem_address
);

    logic [31:0] pc;
    logic        miss_pending; 

    logic stall;
    assign stall = miss_pending;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc           <= 32'h0000_1000;
            miss_pending <= 1'b0;
        end else begin
            if (!stall) begin
                
                pc <= pc + 4;
                miss_pending <= 1'b0;   
            end

            if (!stall && !cpu_hit) begin
                miss_pending <= 1'b1;
            end else begin
                miss_pending <= 1'b0;
            end
        end
    end

    assign mem_access_valid = ~reset && ~stall;
    assign mem_address      = pc;

endmodule