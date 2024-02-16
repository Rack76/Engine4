package main

import "core:fmt"
import "core:c"
import "vendor:glfw"
import "vendor:OpenGL"

import "engine/core"
import "engine/core/window_manager"

main :: proc() {
	core.init()
	
	core.run()

	core.terminate()
	return;
}