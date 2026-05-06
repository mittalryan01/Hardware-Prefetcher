`timescale 1ns/1ps

module tb;

    logic clk   = 0;
    logic reset = 1;

    always #5 clk = ~clk;  

    // ---- DUT ----
    top uut (.clk(clk), .reset(reset));

    
    logic        mem_valid;
    logic [31:0] mem_addr;
    logic        pf_req;
    logic [31:0] pf_addr;
    logic        cpu_hit;
    logic        cache_idle;

    assign mem_valid  = uut.mem_valid;
    assign mem_addr   = uut.mem_addr;
    assign pf_req     = uut.pf_req;
    assign pf_addr    = uut.pf_addr;
    assign cpu_hit    = uut.cpu_hit;
    assign cache_idle = uut.cache_idle;

    int total_accesses   = 0;
    int total_hits       = 0;
    int steady_accesses  = 0;
    int steady_hits      = 0;
    int pf_fires         = 0;

    //num of cycles during which compulsory misses will happen because cache is empty
    localparam WARMUP_CYCLES = 4;
    int cycle_count = 0;

    // Track previous cycle's mem_valid to correctly sample cpu_hit
    // (cpu_hit is registered: valid 1 cycle after the access)
    logic        prev_mem_valid = 0;
    logic [31:0] prev_mem_addr  = 0;
    int          prev_cycle     = 0;

    logic isolation_violation = 0;

    always @(posedge clk) begin
        if (!reset) begin
            cycle_count <= cycle_count + 1;

            if (prev_mem_valid) begin
                total_accesses <= total_accesses + 1;

                if (prev_cycle >= WARMUP_CYCLES) begin
                    steady_accesses <= steady_accesses + 1;
                    if (cpu_hit) steady_hits <= steady_hits + 1;
                end

                if (cpu_hit) total_hits <= total_hits + 1;

                if (total_accesses < 30)
                    $display("[%0t] cycle=%0d | cpu_addr=%h | hit=%b | idle=%b | pf_req=%b pf_addr=%h",
                        $time, prev_cycle, prev_mem_addr, cpu_hit, cache_idle, pf_req, pf_addr);
            end

            prev_mem_valid <= mem_valid;
            prev_mem_addr  <= mem_addr;
            prev_cycle     <= cycle_count;

            if (pf_req) pf_fires <= pf_fires + 1;

            //pf_req must never be 1 when mem_valid=1
            if (mem_valid && pf_req) begin
                $display("ERROR [%0t]: pipeline isolation VIOLATION — pf_req=1 while cpu_req=1!", $time);
                isolation_violation <= 1;
            end
        end
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        // reset for 2cycles
        @(posedge clk); @(posedge clk);
        reset = 0;

        repeat(60) @(posedge clk);

        @(posedge clk);

        //Result
        $display("\n========================================");
        $display("  HARDWARE PREFETCHER —  RESULTS");
        $display("========================================");
        $display("  Total CPU accesses   : %0d", total_accesses);
        $display("  Total hits           : %0d", total_hits);
        $display("  Steady-state accesses: %0d", steady_accesses);
        $display("  Steady-state hits    : %0d", steady_hits);
        $display("  Prefetch fires       : %0d", pf_fires);

        if (steady_accesses > 0) begin
            real hit_pct;
            hit_pct = 100.0 * steady_hits / steady_accesses;
            $display("  Steady-state hit rate: %0.1f%%", hit_pct);

            if (isolation_violation)
                $display("\n  RESULT: FAIL — pipeline isolation violated!");
            else if (hit_pct < 50.0)
                $display("\n  RESULT: FAIL — hit rate below 50%% (%0.1f%%)", hit_pct);
            else
                $display("\n  RESULT: PASS — prefetcher working correctly");
        end else begin
            $display("\n  RESULT: FAIL — no steady-state accesses recorded");
        end

        $finish;
    end

    //Timeout
    initial begin
        #10000;
        $display("TIMEOUT: simulation exceeded 10000 ns");
        $finish;
    end

endmodule