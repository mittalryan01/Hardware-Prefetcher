module cache(
    input  logic        clk,
    input  logic        reset,

    input  logic        cpu_req,        
    input  logic [31:0] cpu_addr,       
    output logic        cpu_hit,        

    input  logic        prefetch_req,  
    input  logic [31:0] prefetch_addr,  

    output logic        cache_idle      
);

    localparam SIZE = 16;

    logic [31:0] tag   [0:SIZE-1];
    logic        valid [0:SIZE-1];
    logic [3:0] index_cpu;
    logic [3:0] index_pf;

    assign index_cpu = cpu_addr[5:2];
    assign index_pf  = prefetch_addr[5:2];

    assign cache_idle = ~cpu_req;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cpu_hit <= 1'b0;
            for (int i = 0; i < SIZE; i++) begin
                valid[i] <= 1'b0;
                tag[i]   <= 32'h0;
            end
        end else begin

            cpu_hit <= 1'b0;

            // CPU request
            if (cpu_req) begin
                if (valid[index_cpu] && tag[index_cpu] == cpu_addr) begin
                    cpu_hit <= 1'b1;
                end else begin
                    cpu_hit          <= 1'b0;
                    valid[index_cpu] <= 1'b1;
                    tag[index_cpu]   <= cpu_addr;
                end
            end

           //prefetch only if cpu req is idle
            else if (prefetch_req) begin
                if (!(valid[index_pf] && tag[index_pf] == prefetch_addr)) begin
                    valid[index_pf] <= 1'b1;
                    tag[index_pf]   <= prefetch_addr;
                end
            end

        end
    end

endmodule