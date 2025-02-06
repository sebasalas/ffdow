# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You need to run this script as an Administrator."
    exit 1
}

# Function to execute diskpart commands
function Run-DiskPart {
    param([string]$script)
    Write-Output "Executing diskpart script:"
    Write-Output $script
    try {
        $output = $script | diskpart
        Write-Output $output
        if ($LASTEXITCODE -ne 0) {
            throw "Diskpart command failed with exit code $LASTEXITCODE."
        }
    } catch {
        Write-Error "ERROR: $_"
        exit 1
    }
}

# Start of the script
Write-Output "Script started at $(Get-Date)"

# List disks
Run-DiskPart 'list disk'
$diskNumber = Read-Host "Enter the number of the disk you want to select"

# Validate disk number input
if (-not $diskNumber -match '^\d+$') {
    Write-Error "Invalid disk number entered."
    exit 1
}

Write-Output "Selected disk number: $diskNumber"

# Confirm with the user before proceeding
$confirm = Read-Host "WARNING: You are about to clean and partition disk $diskNumber. This will erase all data on the disk. Are you sure you want to proceed? (y/n)"
if ($confirm.Trim().ToLower() -ne 'y') {
    Write-Output "Operation cancelled."
    exit
}

# Ask for format type before proceeding with disk operations
Write-Output "1: NTFS"
Write-Output "2: FAT32"
Write-Output "3: exFAT"
$formatChoice = Read-Host "Select the format by typing 1, 2, or 3"
Write-Output "Format choice: $formatChoice"
$formatCommand = switch ($formatChoice) {
    1 { "format fs=ntfs quick" }
    2 { "format fs=fat32 quick" }
    3 { "format fs=exfat quick" }
    default {
        Write-Error "ERROR: Invalid format choice."
        exit 1
    }
}

# Prepare diskpart commands
$diskPartScript = @"
select disk $diskNumber
clean
create partition primary
select partition 1
active
$formatCommand
assign
"@

# Execute the diskpart commands
try {
    Run-DiskPart $diskPartScript
    Write-Output "Operation completed successfully."
} catch {
    Write-Error "ERROR: An error occurred during disk operations: $_"
    exit 1
}

Write-Output "Press 'q' to exit."
if ((Read-Host) -eq 'q') {
    exit
}

Write-Output "Script ended at $(Get-Date)"
