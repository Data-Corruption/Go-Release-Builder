package main

import (
	"os"

	"example_app/internal/app/commands"
)

func main() {
	commands.HandleCommand(os.Args[1:])
}
