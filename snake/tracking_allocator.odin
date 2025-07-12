package main

import "core:fmt"
import "core:mem"

// Checks if the provided tracking allocator has found any memory leaks.
//
// Inputs:
// - alloc: Tracking allocator to check for memory leaks.
// - reset: Whether the allocator should be reset.
//
// Returns: Whether the allocator leaked memory.
check_tracking_allocator :: proc(alloc: ^mem.Tracking_Allocator, reset: bool = false) -> bool {
	for _, leak in alloc.allocation_map {
		fmt.printf("==== %v leaked %m\n", leak.location, leak.size)
	}

	if reset {
		mem.tracking_allocator_destroy(alloc)
	}

	if len(alloc.allocation_map) == 0 {
		fmt.println("==== no allocations leaked")
	}

	return len(alloc.allocation_map) > 0
}

