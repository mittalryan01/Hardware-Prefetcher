module prefetcher(
    input  logic        clk,
    input  logic        reset,

    input  logic        mem_access_valid,
    input  logic [31:0] mem_address,

    input  logic        cache_idle,     
    output logic        prefetch_req,   
    output logic [31:0] prefetch_addr  
);

    logic        pf_valid;  
    logic [31:0] pf_addr;   

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pf_valid <= 1'b0;
            pf_addr  <= 32'h0;
        end else begin
            if (mem_access_valid) begin
                pf_addr  <= mem_address + 4;  // next-line prediction
                pf_valid <= 1'b1;
            end
            else if (pf_valid && cache_idle) begin
                pf_valid <= 1'b0;
            end
        end
    end

   //prefetch req only if cpu re is 0 and cache is idle
    assign prefetch_req  = pf_valid && cache_idle;
    assign prefetch_addr = pf_addr;

endmodule