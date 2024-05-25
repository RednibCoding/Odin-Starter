package main

import "core:fmt"
import "core:mem"

// --- Press F5 to start debugging / launch the project ---

main :: proc() {
	// Lets wrap the context allocator with a tracking allocator
	// This will track memory leaks from the context.allocator
	track_alloc: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track_alloc, context.allocator)
	context.allocator = mem.tracking_allocator(&track_alloc)
	defer {
		// At the end of the program, lets print out the results
		fmt.eprintf("\n")
		// Memory leaks
		for _, entry in track_alloc.allocation_map {
			fmt.eprintf("- %v leaked %v bytes\n", entry.location, entry.size)
		}
		// Double free etc.
		for entry in track_alloc.bad_free_array {
			fmt.eprintf("- %v bad free\n", entry.location)
		}
		mem.tracking_allocator_destroy(&track_alloc)
		fmt.eprintf("\n")

		// Free the temp_allocator so we don't forget it
		// The temp_allocator can be used to allocate temporary memory
		free_all(context.temp_allocator)
	}

	// --- User code starts here ---
	fmt.println("Hello Odin coder!")
}
