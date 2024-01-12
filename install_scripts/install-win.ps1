# Transparent WSL app installation script for Windows
# This script performs the following actions:
#   1. Creates the directory %APPDATA%\$appName and adds it to the system PATH
#   2. Creates the file %APPDATA%\$appName\$appName.ps1 and unblocks it
#   3. Sets the execution policy to RemoteSigned
#   4. Checks if a Debian-based distribution is installed in WSL
#   5. Executes the linux installation script with WSL

$appName = "example_app"

$linuxInstallScript = "install-linux.bash"
$dataPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData)
$appPath = Join-Path -Path $dataPath -ChildPath $appName

# Check if the app's directory already exists, if not, create it

if (-not (Test-Path $appPath)) {
  New-Item -ItemType Directory -Path $appPath | Out-Null
  Write-Host "The directory '$appPath' has been created."
} else {
  Write-Host "The directory '$appPath' already exists."
}

# Add the app's directory to the system PATH

$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
# Function to check if the path already exists in PATH
function PathExistsInPath($path, $currentPath) {
  $pathItems = $currentPath -split ';' | ForEach-Object { $_.TrimEnd('\') }
  return $pathItems -contains $path.TrimEnd('\')
}
# Check if the path already exists in PATH using the function, if not, add it
if (-not (PathExistsInPath $appPath $currentPath)) {
  $newPath = "$currentPath;$appPath"
  [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
  Write-Host "The path '$appPath' has been added to the PATH."
} else {
  Write-Host "The path '$appPath' is already in the PATH."
}

# Create the windows side run script

$scriptContent = @"
# Auto-generated script that bridges Windows to WSL for the app '`$appName'
param(`$args)
`$cwd = (Get-Location).Path
`$wslCwd = wsl -- bash -c "wslpath '`$cwd'"
wsl -- bash -c "cd `$wslCwd; $appName `$args"
"@
# Write the script content to the file, then unblock the file so it can be executed
$appRunScriptPath = Join-Path -Path $appPath -ChildPath "$appName.ps1"
Set-Content -Path $appRunScriptPath -Value $scriptContent
Unblock-File -Path $appRunScriptPath

# Set the execution policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned

# Check if a Debian-based distribution is installed in WSL

# Define the list of Debian-based distributions to check for
$debianBasedDistros = @("Ubuntu", "Debian", "kali-linux", "Pengwin")
# Get the list of all installed WSL distributions, then convert it to an array in case there's only one
$installedDistros = wsl --list --quiet
$installedArray = @($installedDistros)
# Search for a Debian-based distro in the list of installed distros
$foundDebianBased = $false
foreach ($distro in $debianBasedDistros) {
  if ($installedArray -contains $distro) {
    $foundDebianBased = $true
    break
  }
}
# If no Debian-based distro was found, ask the user if they want to continue anyway
if (-not $foundDebianBased) {
  Write-Host "Failed to detect a Debian-based distribution installed in WSL."
  $userChoice = Read-Host "Do you want to attempt the installation anyway? (yes/no)"
  if ($userChoice -ne "yes") {
    Write-Host "Exiting installation.."
    exit 1
  }
}

# Execute the linux installation script with WSL

# Make sure the script exists
if (-not (Test-Path $linuxInstallScript)) {
  throw "The linux installation script '$linuxInstallScript' does not exist."
}
# Execute the linux installation script with WSL
$cwd = (Get-Location).Path
$wslCwd = wsl -- bash -c "wslpath '$cwd'"
wsl -- bash -c "cd $wslCwd; ./$linuxInstallScript"