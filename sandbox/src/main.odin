package main

import "../../engine/core"

main :: proc() {
	core.init()
	
	core.run()

	core.terminate()
	return;
}