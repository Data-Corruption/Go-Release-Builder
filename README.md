# Go-Release-Builder

[Go](https://go.dev/) project template for automatically creating release zips with [GitHub Actions](https://docs.github.com/en/actions), targeting Linux and [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) environments.

This distribution method is ideal for:
- Projects aiming to release on Linux and WSL transparently.
- End users familiar with basic CLI operations.
- Projects seeking a lightweight distribution method.
- Small to medium projects looking for an easy-to-implement solution before moving to a signed installer.

## Transparent WSL operation

This template enhances the experience for Windows end users by providing a script that enables direct execution of your Go application within WSL, without needing to prefix the command with `wsl`. The script, placed in the Windows system path, redirects the command to the corresponding application in WSL, allowing users to run the application as if it were a native Windows command.

For example, instead of using:
```powershell
wsl example_app --arg
```
Users can simply type:
```powershell
example_app --arg
```

This functionality creates a seamless integration of Linux-only CLI tools within the Windows environment.

## Getting Started:

#### Prerequisites for Developers:
- [Git](https://git-scm.com/) (GitHub Actions handles the build process)
- [Go](https://go.dev/) (Recommended for local linting and testing before pushing to the main branch)

#### Prerequisites for End Users:
- Linux, or a Windows machine with WSL installed and a Debian-based distro

### Developer Instructions
1. Use this template to create your repository.
2. Modify the 'app name' variable in both install-linux.bash and install-win.ps1 scripts to match the name of your application instead of the placeholder example_app.
3. Develop your amazing Go application.
4. Push to your main branch.
5. Review and publish the release draft created by GitHub Actions.
6. Provide installation instructions to your users, as outlined below.

### End User install instruction template:

#### For Windows:
1. Ensure WSL is installed with a Debian-based Linux distribution.
2. Download and extract the release appropriate for your architecture.
3. Open a terminal with admin privileges, navigate to the extracted contents, then run:
```powershell
Set-ExecutionPolicy Bypass
```
```powershell
.\install-win.ps1
```
The install script will [set the execution policy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.4#-executionpolicy) to RemoteSigned

#### For Linux:
1. Download and extract the release for your architecture.
2. In a terminal, navigate to the extracted contents and run:
```shell
sudo ./install-linux.bash
```

### Troubleshooting

<details>
<summary><b>Issues with Creating Release on Main Push</b></summary>

Problem: The GitHub Action fails when pushing to main, with an error about creating the release.

Solution: Check your repository settings. Go to Settings -> Actions -> General -> Workflow permissions and ensure it's set to 'Read and write permissions'.
</details>