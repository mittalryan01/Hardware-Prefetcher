module top(
    input logic clk,
    input logic reset
);

    logic        mem_valid;
    logic [31:0] mem_addr;

    logic        pf_req;
    logic [31:0] pf_addr;

    logic        cpu_hit;
    logic        cache_idle;

    //Pipeline
    pipeline u_pipeline (
        .clk              (clk),
        .reset            (reset),
        .cpu_hit          (cpu_hit),       
        .cache_idle       (cache_idle),    
        .mem_access_valid (mem_valid),
        .mem_address      (mem_addr)
    );

    // Next line prefetcher
    prefetcher u_prefetcher (
        .clk              (clk),
        .reset            (reset),
        .mem_access_valid (mem_valid),   
        .mem_address      (mem_addr),    
        .cache_idle       (cache_idle),
        .prefetch_req     (pf_req),
        .prefetch_addr    (pf_addr)
    );

    //Direct-mapped cache 
    cache u_cache (
        .clk          (clk),
        .reset        (reset),
        .cpu_req      (mem_valid),  
        .cpu_addr     (mem_addr),
        .cpu_hit      (cpu_hit),
        .prefetch_req (pf_req),     
        .prefetch_addr(pf_addr),
        .cache_idle   (cache_idle)  
    );

endmodule