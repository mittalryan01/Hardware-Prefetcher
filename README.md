# Hardware Prefetcher with Pipeline and Cache


## 📌 Description

This project implements a **simple CPU pipeline + direct-mapped cache + next-line hardware prefetcher** in SystemVerilog.

The goal is to demonstrate:

* Cache behavior (hits/misses)
* Performance improvement using prefetching
* Proper **pipeline isolation** (prefetcher does not interfere with CPU requests)

---

## 🧠 Architecture

```
Pipeline ──► Cache (CPU port)
     │
     └──► Prefetcher (observe only)

Prefetcher ──► Cache (prefetch port)
Cache ───────► Prefetcher (cache_idle signal)
```

### Key Design Principle:

* ✅ Prefetcher **only observes** CPU accesses
* ❌ No direct connection from prefetcher → pipeline
* ✅ Prefetch occurs **only when cache is idle**

---

## 📁 Files Description

### 1. `pipeline.sv`

* Generates sequential memory accesses (`pc + 4`)
* Stalls on cache miss
* Outputs:

  * `mem_access_valid`
  * `mem_address`

---

### 2. `cache.sv`

* Direct-mapped cache
* Handles:

  * CPU requests
  * Prefetch requests
* Outputs:

  * `cpu_hit`
  * `cache_idle`

---

### 3. `prefetcher.sv`

* Observes memory access pattern
* Implements **next-line prefetching**
* Generates:

  * `pf_req`
  * `pf_addr = mem_addr + 4`

---

### 4. `top.sv`

* Integrates all modules
* Ensures **structural isolation**
* Connects:

  * Pipeline → Cache
  * Pipeline → Prefetcher (read-only)
  * Prefetcher → Cache

---

### 5. `testbench.sv`

* Drives simulation
* Tracks:

  * Total accesses
  * Hits
  * Prefetch activity
* Computes:

  * **Steady-state hit rate**
* Dumps waveform (`wave.vcd`)

---

## ⚙️ How to Run

### Compile

```bash
iverilog -g2012 -o sim.vvp *.sv
```

### Run

```bash
vvp sim.vvp
```

### View Waveform

```bash
gtkwave wave.vcd
```

---

## 📊 Output Metrics

At the end of simulation, the testbench prints:

* Total CPU accesses
* Total hits
* Steady-state accesses
* Steady-state hits
* Prefetch fires
* Hit rate (%)

---
<img width="1129" height="1032" alt="image" src="https://github.com/user-attachments/assets/4f11a8f4-2fd7-417c-8f9b-0fb008499fa9" />


## 🧠 Key Concepts

### 🔹 Cold Miss

* First-time access → unavoidable miss

### 🔹 Steady-State

* Performance after initial warmup phase

### 🔹 Next-Line Prefetching

* Predicts:

  ```
  next_address = current_address + 4
  ```

---

## 📈 Expected Behavior

### Warmup Phase

* Initial accesses → misses

### Steady State

* Prefetcher loads data early
* Majority accesses → **hits**

### Ideal Case (Sequential Access)

* Near **100% hit rate**

---

## 🔍 GTKWave Signals

```
mem_valid
mem_addr
cpu_hit
pf_req
pf_addr
cache_idle
clk
reset
```
<img width="1600" height="218" alt="image" src="https://github.com/user-attachments/assets/c9748c4c-48e1-4c0f-b052-11b2148579cc" />



## ✅ Key Achievements

* ✔ Functional cache + pipeline integration
* ✔ Working hardware prefetcher
* ✔ Structural isolation enforced
* ✔ High hit rate in steady-state

---

## ⚠️ Limitations

* Assumes sequential access pattern
* No replacement policy (LRU/FIFO)
---

