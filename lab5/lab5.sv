// A full memory hierarchy. 
//
// Parameter:
// MODEL_NUMBER: A number used to specify a specific instance of the memory.  Different numbers give different hierarchies and settings.
//   This should be set to your student ID number.
// DMEM_ADDRESS_WIDTH: The number of bits of address for the memory.  Sets the total capacity of main memory.
//
// Accesses: To do an access, set address, data_in, byte_access, and write to a desired value, and set start_access to 1.
//   All these signals must be held constant until access_done, at which point the operation is completed.  On a read,
//   data_out will be set to the correct data for the single cycle when access_done is true.  Note that you can do
//   back-to-back accesses - when access_done is true, if you keep start_access true the memory will start the next access.
// 
//   When start_access = 0, the other input values do not matter.
//   bytemask controls which bytes are actually written (ignored on a read).
//     If bytemask[i] == 1, we do write the byte from data_in[8*i+7 : 8*i] to memory at the corresponding position.  If == 0, that byte not written.
//   To do a read: write = 0,  data_in does not matter.  data_out will have the proper data for the single cycle where access_done==1.
//   On a write, write = 1 and data_in must have the data to write.
//
//   Addresses must be aligned.  Since this is a 64-bit memory (8 bytes), the bottom 3 bits of each address must be 0.
//
//   It is an error to set start_access to 1 and then either set start_access to 0 or change any other input before access_done = 1.
//
//   Accessor tasks (essentially subroutines for testbenches) are provided below to help do most kinds of accesses.

// Line to set up the timing of simulation: says units to use are ns, and smallest resolution is 10ps.
`timescale 1ns/10ps

module lab5 #(parameter [22:0] MODEL_NUMBER = 1350364, parameter DMEM_ADDRESS_WIDTH = 20) (
	// Commands:
	//   (Comes from processor).
	input		logic [DMEM_ADDRESS_WIDTH-1:0]	address,			// The byte address.  Must be word-aligned if byte_access != 1.
	input		logic [63:0]							data_in,			// The data to write.  Ignored on a read.
	input		logic [7:0]								bytemask,		// Only those bytes whose bit is set are written.  Ignored on a read.
	input		logic										write,			// 1 = write, 0 = read.
	input		logic										start_access,	// Starts a memory access.  Once this is true, all command inputs must be stable until access_done becomes 1. 
	output	logic										access_done,	// Set to true on the clock edge that the access is completed.
	output	logic	[63:0]							data_out,		// Valid when access_done == 1 and access is a read.
	// Control signals:
	input		logic										clk,
	input		logic										reset				// A reset will invalidate all cache entries, and return main memory to the default initial values.
); 
	
	DataMemory #(.MODEL_NUMBER(MODEL_NUMBER), .DMEM_ADDRESS_WIDTH(DMEM_ADDRESS_WIDTH)) dmem
		(.address, .data_in, .bytemask, .write, .start_access, .access_done, .data_out, .clk, .reset);
	
	always @(posedge clk)
		assert(reset !== 0 || start_access == 0 || address[2:0] == 0); // All accesses must be aligned.
	
endmodule

// Test the data memory, and figure out the settings.

module lab5_testbench ();
	localparam USERID = 2235352;  // Set to your student ID #
	localparam ADDRESS_WIDTH = 20;
	localparam DATA_WIDTH = 8;
	
	logic [ADDRESS_WIDTH-1:0]			address;		   // The byte address.  Must be word-aligned if byte_access != 1.
	logic [63:0]							data_in;			// The data to write.  Ignored on a read.
	logic [7:0]								bytemask;		// Only those bytes whose bit is set are written.  Ignored on a read.
	logic										write;			// 1 = write, 0 = read.
	logic										start_access;	// Starts a memory access.  Once this is true, all command inputs must be stable until access_done becomes 1. 
	logic										access_done;	// Set to true on the clock edge that the access is completed.
	logic	[63:0]							data_out;		// Valid when access_done == 1 and access is a read.
	// Control signals:
	logic										clk;
	logic										reset;				// A reset will invalidate all cache entries, and return main memory to the default initial values.

	lab5 #(.MODEL_NUMBER(USERID), .DMEM_ADDRESS_WIDTH(ADDRESS_WIDTH)) dut
		(.address, .data_in, .bytemask, .write, .start_access, .access_done, .data_out, .clk, .reset); 

	// Set up the clock.
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 5, " ns", 10);

	// --- Keep track of number of clock cycles, for statistics.
	integer cycles;
	always @(posedge clk) begin
		if (reset)
			cycles <= 0;
		else
			cycles <= cycles + 1;
	end
		
	// --- Tasks are subroutines for doing various operations.  These provide read and write actions.
	
	// Set memory controls to an idle state, no accesses going.
	task mem_idle;
		address			<= 'x;
		data_in			<= 'x;
		bytemask			<= 'x;
		write				<= 'x;
		start_access	<= 0;
		#1;
	endtask
	
	// Perform a read, and return the resulting data in the read_data output.
	// Note: waits for complete cycle of "access_done", so spends 1 cycle more than the access time.
	task readMem;
		input		[ADDRESS_WIDTH-1:0]		read_addr;
		output	[DATA_WIDTH-1:0][7:0]	read_data;
		output	int							delay;		// Access time actually seen.
		
		int startTime, endTime;
		
		startTime = cycles;
		address			<= read_addr;
		data_in			<= 'x;
		bytemask			<= 'x;
		write				<= 0;
		start_access	<= 1;
		@(posedge clk);
		while (~access_done) begin
			@(posedge clk);
		end
		mem_idle(); #1;
		read_data = data_out;
		endTime = cycles;
		delay = endTime - startTime - 1;
	endtask
	
	function int min;
		input int x;
		input int y;
		
		min = ((x<y) ? x : y);
	endfunction
	function int max;
		input int x;
		input int y;
		
		max = ((x>y) ? x : y);
	endfunction
	
	// Perform a series of reads, and returns the min and max access times seen.
	// Accesses are at read_addr, read_addr+stride, read_addr+2*stride, ... read_addr+(num_reads-1)*stride.
	task readStride;
		input		[ADDRESS_WIDTH-1:0]		read_addr;
		input		int							stride;
		input		int							num_reads;
		output	int							min_delay;	// Fastest access time actually seen.
		output	int							max_delay;	// Slowest access time actually seen.
		
		int i, delay;
		logic [DATA_WIDTH-1:0][7:0]		read_data;
		
		//$display("%t readStride(%d, %d, %d)", $time, read_addr, stride, num_reads);
		readMem(read_addr, read_data, delay);
		min_delay = delay;
		max_delay = delay;
		//$display("1  delay: %d", delay);
		
		for(i=1; i<num_reads; i++) begin
			readMem(read_addr+stride*i, read_data, delay);
			min_delay = min(min_delay, delay);
			max_delay = max(max_delay, delay);
			//$display("2  delay: %d", delay);
		end
		//$display("%t min_delay: %d max_delay: %d", $time, min_delay, max_delay);

		mem_idle(); #1;
	endtask
	
	// Perform a write.
	// Note: waits for complete cycle of "access_done", so spends 1 cycle more than the access time.
	task writeMem;
		input [ADDRESS_WIDTH-1:0]			write_address;
		input [DATA_WIDTH-1:0][7:0]		write_data;
		input [DATA_WIDTH-1:0]				write_bytemask;
		output	int							delay;		// Access time actually seen.
		
		int	startTime, endTime;
		
		startTime = cycles;
		address			<= write_address;
		data_in			<= write_data;
		bytemask			<= write_bytemask;
		write				<= 1;
		start_access	<= 1;
		@(posedge clk);
		while (~access_done) begin
			@(posedge clk);
		end
		mem_idle(); #1;
		endTime = cycles;
		delay = endTime - startTime - 1;
	endtask
	
	// Perform a series of writes, and returns the min and max access times seen.
	// Accesses are at write_addr, write_addr+stride, write_addr+2*stride, ... write_addr+(num_writes-1)*stride.
	task writeStride;
		input		[ADDRESS_WIDTH-1:0]		write_addr;
		input		int							stride;
		input		int							num_writes;
		output	int							min_delay;	// Fastest access time actually seen.
		output	int							max_delay;	// Slowest access time actually seen.
		
		int i, delay;
		logic [DATA_WIDTH-1:0][7:0]		write_data;
		
		//$display("%t writeStride(%d, %d, %d)", $time, write_addr, stride, num_writes);
		writeMem(write_addr, write_data, 8'hFF, delay);
		min_delay = delay;
		max_delay = delay;
		//$display("1  delay: %d", delay);
		
		for(i=1; i<num_writes; i++) begin
			writeMem(write_addr+stride*i, write_data, 8'hFF, delay);
			min_delay = min(min_delay, delay);
			max_delay = max(max_delay, delay);
			//$display("2  delay: %d", delay);
		end
		//$display("%t min_delay: %d max_delay: %d", $time, min_delay, max_delay);

		mem_idle(); #1;
	endtask
	
	// Skip doing an access for a cycle.
	task noopMem;
		mem_idle();
		@(posedge clk); #1;
	endtask
	
	// Reset the memory.
	task resetMem;
		mem_idle();
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		#1;
	endtask
	
	logic [DATA_WIDTH-1:0][7:0] dummy_data;
	logic [ADDRESS_WIDTH-1:0] addr;
	logic [DATA_WIDTH-1:0][7:0] read_data, read_back, write_data;
	logic [DATA_WIDTH-1:0][7:0] test_data = 64'hDEADBEEFCAFEBABE;

	int base_addr = 0;
	int stride = 8;
	int read_count = 64;
	int min_delay, max_delay;
	int i, delay;
	int addr1, addr2;
	int addr_a = 0;
	int addr_b = 256;
	int test_addr = 0;

	int l2_base = 8192;         // Start in L2 region
	int l2_stride = 32;         // L2 block size
	int l2_blocks = 64;         // Try up to 64 blocks

	// Pick two addresses with same index but different tags
	int l2_addr1 = 8192;       // base
	int l2_addr2 = l2_addr1 + 64 * 64; // 64 blocks * 64B spacing = far enough for tag diff

	int index_base = 8192;
	int index_stride = 16384; // Keeps index same, changes tag
	int set_size = 32;
	int evict_addr, flush_addr;

	int refresh_addrs[3] = '{8192, 8192 + 4*16384, 8192 + 28*16384};

	int num_test_blocks = 4;
	int num_writes = 0;
	int max_writes = 0;

	logic [63:0] l3_read_data;
	int l3_probe_addr;

	initial begin
		dummy_data <= '0;
		resetMem(); // Initialize memory


		$display("\n=== Measuring L1 Block Size ===");
		readStride(base_addr, stride, read_count, min_delay, max_delay);
		for (i = 0; i < read_count; i++) begin
			readMem(base_addr + i * stride, read_data, delay);
			$display("%t ns | Addr = %0d | Delay = %0d cycles", $time, base_addr + i*stride, delay);
		end


		$display("\n=== Binary search: Testing 12 real blocks (spaced by 32) ===");
		resetMem();
		for (i = 0; i < 12; i++) begin
			readMem(i * 32, read_data, delay);
			$display("Fill %2d | Addr = %0d | Delay = %0d cycles", i, i * 32, delay);
		end
		for (i = 0; i < 12; i++) begin
			readMem(i * 32, read_data, delay);
			$display(" Re-read Addr = %0d | Delay = %0d cycles", i * 32, delay);
		end


		$display("\n=== Robust Test: Multiple Conflicting Blocks ===");
		resetMem();
		for (i = 0; i < 4; i++) begin
			addr1 = 0 + i * 2048;
			addr2 = 256 + i * 2048;

			$display("---- Conflict Pair %0d ----", i);
			readMem(addr1, read_data, delay);
			$display("Load A | Addr = %0d | Delay = %0d", addr1, delay);

			readMem(addr2, read_data, delay);
			$display("Load B | Addr = %0d | Delay = %0d", addr2, delay);

			readMem(addr1, read_data, delay);
			$display("Re-read A | Addr = %0d | Delay = %0d", addr1, delay);

			readMem(addr2, read_data, delay);
			$display("Re-read B | Addr = %0d | Delay = %0d", addr2, delay);
		end

		$display("\n=== Associativity Check: Simulating 2-Way Associative ===");
		resetMem();
		readMem(addr_a, read_data, delay);
		$display("Load A | Addr = %0d | Delay = %0d", addr_a, delay);

		readMem(addr_b, read_data, delay);
		$display("Load B | Addr = %0d | Delay = %0d", addr_b, delay);

		readMem(addr_a, read_data, delay);
		$display("Re-read A (should be hit in 2-way) | Addr = %0d | Delay = %0d", addr_a, delay);

		readMem(addr_b, read_data, delay);
		$display("Re-read B (should be hit in 2-way) | Addr = %0d | Delay = %0d", addr_b, delay);


		$display("\n=== Testing Write Policy (Write-through vs. Write-back) ===");
		resetMem();
		writeMem(test_addr, test_data, 8'hFF, delay);
		$display("Wrote value to Addr = %0d | Delay = %0d", test_addr, delay);

		resetMem();
		readMem(test_addr, read_back, delay);
		$display("Read after reset from Addr = %0d | Delay = %0d | Data = %h", test_addr, delay, read_back);
		if (read_back === test_data)
			$display("Data survived reset --> WRITE-THROUGH");
		else
			$display("Data lost after reset --> WRITE-BACK");

		$display("\n=== Robust Test for L1 Write Policy (Write-through vs. Write-back) ===");
		resetMem();
		for (i = 0; i < 4; i++) begin
			addr = base_addr + i * 64;
			write_data = 64'h11110000 + i;
			writeMem(addr, write_data, 8'hFF, delay);
			$display("Write %0d | Addr = %0d | Delay = %0d", i, addr, delay);

			readMem(addr, read_data, delay);
			$display("Immediate Re-read | Addr = %0d | Delay = %0d | Data = %h", addr, delay, read_data);
		end

		resetMem();
		for (i = 0; i < 4; i++) begin
			addr = base_addr + i * 64;
			readMem(addr, read_data, delay);
			$display("Post-reset Read | Addr = %0d | Delay = %0d | Data = %h", addr, delay, read_data);
		end


		$display("\n=== Testing for Write Buffer Presence ===");
		resetMem();

		// Fill up L1 cache with dirty blocks
		for (i = 0; i < 12; i++) begin
			addr = i * 32;
			write_data = 64'hABC00000 + i;
			writeMem(addr, write_data, 8'hFF, delay);
			$display("Write %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Write to new address to cause eviction
		addr = 12 * 32;
		write_data = 64'hDEAD1234CAFEBEEF;
		writeMem(addr, write_data, 8'hFF, delay);
		$display("Evicting Write | Addr = %0d | Delay = %0d", addr, delay);

		// Immediately do another write
		addr = 13 * 32;
		write_data = 64'hFACEB00CDEADBEEF;
		writeMem(addr, write_data, 8'hFF, delay);
		$display("Post-eviction Write | Addr = %0d | Delay = %0d", addr, delay);



		$display("\n=== Measuring L2 Block Size ===");
		resetMem();

		// Step 1: Evict L1 by filling it
		for (i = 0; i < 16; i++) begin
			readMem(i * 32, read_data, delay); // L1 block size = 32B from earlier
		end

		// Step 2: Access an address that causes L2 to be hit and L1 to miss
		base_addr = 8192;       // Large enough to guarantee L1 miss
		stride = 8;
		read_count = 32;

		// Read base address to trigger block fill into L2 (and possibly L1)
		readMem(base_addr, read_data, delay);
		$display("Trigger Addr = %0d | Delay = %0d", base_addr, delay);

		// Now read forward in strides to see how many reads are fast (hits)
		for (i = 1; i < read_count; i++) begin
			readMem(base_addr + i * stride, read_data, delay);
			$display("Offset Addr = %0d | Delay = %0d", base_addr + i * stride, delay);
		end


		$display("\n=== Finding L2 Number of Blocks ===");
		resetMem();

		for (i = 0; i < l2_blocks; i++) begin
			addr = l2_base + i * l2_stride;
			readMem(addr, read_data, delay);
			$display("Fill %2d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		for (i = 0; i < l2_blocks; i++) begin
			addr = l2_base + i * l2_stride;
			readMem(addr, read_data, delay);
			$display(" Re-read Addr = %0d | Delay = %0d", addr, delay);
		end


		$display("\n=== L2 Replacement Policy Check ===");
		resetMem();

		// Step 1: Fill L2 with 64 distinct blocks
		for (i = 0; i < 64; i++) begin
			addr = 8192 + i * 32;
			readMem(addr, read_data, delay);
			$display("L2 Fill %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Step 2: Re-access all blocks to update recency
		for (i = 0; i < 64; i++) begin
			addr = 8192 + i * 32;
			readMem(addr, read_data, delay);
			$display("L2 Refresh %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Step 3: Access one new block to cause an eviction
		addr = 8192 + 64 * 32;
		readMem(addr, read_data, delay);
		$display("Eviction Trigger | Addr = %0d | Delay = %0d", addr, delay);

		// Step 4: Check which block was evicted
		for (i = 0; i < 64; i++) begin
			addr = 8192 + i * 32;
			readMem(addr, read_data, delay);
			$display("Re-read %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		$display("\n=== L2 Associativity Check: 2-Way Conflict Test ===");
		resetMem();

		// Load both into cache
		readMem(l2_addr1, read_data, delay);
		$display("Load A | Addr = %0d | Delay = %0d", l2_addr1, delay);

		readMem(l2_addr2, read_data, delay);
		$display("Load B | Addr = %0d | Delay = %0d", l2_addr2, delay);

		// Re-read both (should both be hits if 2-way)
		readMem(l2_addr1, read_data, delay);
		$display("Re-read A | Addr = %0d | Delay = %0d", l2_addr1, delay);

		readMem(l2_addr2, read_data, delay);
		$display("Re-read B | Addr = %0d | Delay = %0d", l2_addr2, delay);

		$display("\n=== L2 Associativity Check: 5 Blocks to Same Index ===");
		resetMem();

		// These addresses differ by 16 KB (16384 = 2^14), ensuring same index
		l2_base = 8192; // Must be aligned to L2 block spacing (32)
		for (i = 0; i < 5; i++) begin
			addr = l2_base + i * 16384;
			readMem(addr, read_data, delay);
			$display("Load %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Re-read all
		for (i = 0; i < 5; i++) begin
			addr = l2_base + i * 16384;
			readMem(addr, read_data, delay);
			$display("Re-read %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		$display("\n=== L2 Associativity Check: 8 Blocks to Same Index ===");
		resetMem();

		// These addresses differ by 16 KB (16384 = 2^14), ensuring same index
		l2_base = 8192; // Must be aligned to L2 block spacing (32)
		for (i = 0; i < 8; i++) begin
			addr = l2_base + i * 16384;
			readMem(addr, read_data, delay);
			$display("Load %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Re-read all
		for (i = 0; i < 8; i++) begin
			addr = l2_base + i * 16384;
			readMem(addr, read_data, delay);
			$display("Re-read %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		$display("\n=== L2 Associativity Check: 32 Blocks to Same Index ===");
		resetMem();

		// These addresses differ by 16 KB (16384 = 2^14), ensuring same index
		l2_base = 8192; // Must be aligned to L2 block spacing (32)
		for (i = 0; i < 32; i++) begin
			addr = l2_base + i * 16384;
			readMem(addr, read_data, delay);
			$display("Load %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Re-read all
		for (i = 0; i < 32; i++) begin
			addr = l2_base + i * 16384;
			readMem(addr, read_data, delay);
			$display("Re-read %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end


		$display("\n=== L2 Robust LRU Check ===");
		resetMem();

		// Step 1: Fill 32 blocks to same index
		for (i = 0; i < set_size; i++) begin
			addr = index_base + i * index_stride;
			readMem(addr, read_data, delay);
			$display("Fill %2d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Step 2: Refresh some blocks (simulate recent usage)
		for (i = 0; i < 4; i++) begin
			addr = index_base + i * index_stride;
			readMem(addr, read_data, delay);
			$display("Refresh %2d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Step 3: Cause an eviction with 33rd block
		evict_addr = index_base + set_size * index_stride;
		readMem(evict_addr, read_data, delay);
		$display("Eviction Trigger | Addr = %0d | Delay = %0d", evict_addr, delay);

		// Step 4: Re-read all 33 and detect the eviction
		for (i = 0; i <= set_size; i++) begin
			addr = index_base + i * index_stride;
			readMem(addr, read_data, delay);
			$display("Re-read %2d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		$display("\n=== L2 Random Replacement Rejection Test ===");
		resetMem();

		// Step 1: Fill 32 ways for index (same index every 16KB apart)
		for (i = 0; i < 32; i++) begin
			addr = 8192 + i * 16384;
			readMem(addr, read_data, delay);
			$display("Fill %2d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Step 2: Re-access a few blocks — these should be preserved under LRU
		for (i = 0; i < 3; i++) begin
			readMem(refresh_addrs[i], read_data, delay);
			$display("Refresh Block %0d | Addr = %0d | Delay = %0d", i, refresh_addrs[i], delay);
		end

		// Step 3: Trigger eviction
		addr = 8192 + 32*16384;
		readMem(addr, read_data, delay);
		$display("Eviction Trigger | Addr = %0d | Delay = %0d", addr, delay);

		// Step 4: Re-read refreshed blocks — must be hits under LRU
		for (i = 0; i < 3; i++) begin
			readMem(refresh_addrs[i], read_data, delay);
			$display("Re-read Block %0d | Addr = %0d | Delay = %0d", i, refresh_addrs[i], delay);
		end


		$display("\n=== L2 Write Policy Test ===");
		resetMem();  // Reset memory and caches

		// Use an address known to map to L2 (e.g., offset from L1 with stride)
		test_addr = 8192;
		test_data = 64'hA5A5A5A5DEADBEEF;

		writeMem(test_addr, test_data, 8'hFF, delay);
		$display("Wrote to Addr = %0d | Delay = %0d", test_addr, delay);

		// Flush just L1 by writing to enough new blocks
		for (i = 0; i < 12; i++) begin
			flush_addr = i * 64;
			writeMem(flush_addr, 64'h0, 8'hFF, delay);
		end

		readMem(test_addr, read_back, delay);
		$display("Read after L1 flush | Addr = %0d | Delay = %0d | Data = %h", test_addr, delay, read_back);

		if (read_back === test_data)
			$display("Data survived --> WRITE-THROUGH");
		else
			$display("Data lost --> WRITE-BACK");

		$display("\n=== Robust L2 Write Policy Test (Write-back vs. Write-through) ===");
		resetMem();
		stride = 32;

		// Step 1: Write distinct values to multiple addresses known to go to L2
		for (i = 0; i < num_test_blocks; i++) begin
			addr = 8192 + i * stride;
			write_data = 64'hAA00000000000000 + i;
			writeMem(addr, write_data, 8'hFF, delay);
			$display("Write %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		// Step 2: Flush L1 by writing to many new conflicting lines
		for (i = 0; i < 12; i++) begin
			addr = 16384 + i * stride;
			writeMem(addr, 64'h0, 8'hFF, delay);
		end

		// Step 3: Read back original addresses
		for (i = 0; i < num_test_blocks; i++) begin
			addr = 8192 + i * stride;
			readMem(addr, read_data, delay);
			$display("Post-L1 flush Read %0d | Addr = %0d | Delay = %0d | Data = %h", i, addr, delay, read_data);

			// Validate
			if (read_data === (64'hAA00000000000000 + i))
				$display("Data survived --> WRITE-THROUGH");
			else
				$display("Data lost --> WRITE-BACK");
		end


		$display("\n=== L2 Write Buffer Presence Test ===");
		resetMem();

		base_addr = 8192;
		stride = 32; // block size
		num_writes = 12;

		for (i = 0; i < num_writes; i++) begin
			addr = base_addr + i * stride;
			writeMem(addr, 64'hAABB000000000000 + i, 8'hFF, delay);
			$display("Write %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end

		$display("\n=== Robust L2 Write Buffer Depth Test ===");
		resetMem();

		max_writes = 40;  // Sweep deep enough to exceed buffer
		for (i = 0; i < max_writes; i++) begin
			addr = 8192 + i * 32;  // L2-only addresses, 32B stride
			writeMem(addr, i, 8'hFF, delay);
			$display("Write %0d | Addr = %0d | Delay = %0d", i, addr, delay);
		end


		$display("\n=== L3 Cache Existence Check ===");
		resetMem();

		// Step 1: Cause a full miss (should take full memory latency)
		l3_probe_addr = 123456;
		readMem(l3_probe_addr, l3_read_data, delay);
		$display("Initial miss | Addr = %0d | Delay = %0d", l3_probe_addr, delay);

		// Step 2: Re-read (still in L2 if no L3)
		readMem(l3_probe_addr, l3_read_data, delay);
		$display("Second read | Addr = %0d | Delay = %0d", l3_probe_addr, delay);

		// Step 3: Evict from L1 + L2
		for (int i = 0; i < 100; i++) begin
			flush_addr = 8192 + i * 64;
			readMem(flush_addr, l3_read_data, delay);  // force other blocks into L1 + L2
		end

		// Step 4: Read again (check if it's faster than memory)
		readMem(l3_probe_addr, l3_read_data, delay);
		$display("Post-eviction read | Addr = %0d | Delay = %0d", l3_probe_addr, delay);

		$stop();
	end

		// // Do 20 random reads.
		// for (i=0; i<20; i++) begin
		// 	addr = $random()*8; // *8 to doubleword-align the access.
		// 	readMem(addr, dummy_data, delay);
		// 	$display("%t Read took %d cycles", $time, delay);
		// end
		
		// // Do 5 random double-word writes of random data.
		// for (i=0; i<5; i++) begin
		// 	addr = $random()*8; // *8 to doubleword-align the access.
		// 	dummy_data = $random();
		// 	writeMem(addr, dummy_data, 8'hFF, delay);
		// 	$display("%t Write took %d cycles", $time, delay);
		// end
		
		// // Reset the memory.
		// resetMem();
		
		// // Read all of the first KB
		// readStride(0, 8, 1024/8, minval, maxval);
		// $display("%t Reading the first KB took between %d and %d cycles each", $time, minval, maxval);
	
endmodule
