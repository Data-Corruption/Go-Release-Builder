package commands

import (
	"errors"
)

// Command interface for all commands
type Command interface {
	Name() string                // Name returns the name of the command
	Usage() string               // Usage returns a string describing the command
	Execute(args []string) error // Execute runs the command
}

var (
	// Commands is a slice of all available commands
	Commands []Command
	// ErrNoCommand is returned when no command is provided
	ErrNoCommand = errors.New("no command provided")
	// ErrUnknownCommand is returned when an unknown command is provided
	ErrUnknownCommand = errors.New("unknown command")
)

// AddCommand is used by commands to register themselves via their init functions
// For those unfamiliar with init functions, they are called automatically at program startup
func AddCommand(cmd Command) {
	Commands = append(Commands, cmd)
}

// HandleCommand takes a slice of command line arguments and executes the appropriate command
func HandleCommand(args []string) error {
	if len(args) < 1 {
		return ErrNoCommand
	}

	for _, cmd := range Commands {
		if cmd.Name() == args[0] {
			return cmd.Execute(args[1:])
		}
	}

	return ErrUnknownCommand
}
