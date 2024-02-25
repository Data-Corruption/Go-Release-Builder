package commands

import (
	"fmt"
)

type VersionCommand struct {
	Version string
}

// Set by the build system
var version string

func (v *VersionCommand) Name() string {
	return "version"
}

func (v *VersionCommand) Usage() string {
	return "version: Print the version information"
}

func (v *VersionCommand) Execute(args []string) error {
	fmt.Println("Version:", v.Version)
	return nil
}

func init() {
	AddCommand(&VersionCommand{Version: version})
}
