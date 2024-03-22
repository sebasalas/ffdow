# Function to execute diskpart commands
function Run-DiskPart {
    param([string]$script)
    Write-Output "Executing diskpart script:"
    Write-Output $script
    $script | diskpart
}

# Start of the script
Write-Output "Script started at $(Get-Date)"

# List disks
Run-DiskPart 'list disk'
$diskNumber = Read-Host "Enter the number of the disk you want to select"
Write-Output "Selected disk number: $diskNumber"

# Confirm with the user before proceeding
$confirm = Read-Host "WARNING: You are about to clean and partition disk $diskNumber. This will erase all data on the disk. Are you sure you want to proceed? (y/n)"
Write-Output "User confirmation: $confirm"
if ($confirm -ne 'y') {
    Write-Output "Operation cancelled."
    exit
}

# Ask for format type before proceeding with disk operations
Write-Output "1: NTFS"
Write-Output "2: FAT32"
$formatChoice = Read-Host "Select the format by typing 1 or 2"
Write-Output "Format choice: $formatChoice"
$formatCommand = if ($formatChoice -eq '1') {
    "format fs=ntfs quick"
} elseif ($formatChoice -eq '2') {
    "format fs=fat32 quick"
} else {
    Write-Output "Invalid format choice."
    exit
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
Run-DiskPart $diskPartScript

Write-Output "Operation completed successfully."
Write-Output "Press 'q' to exit."
if (Read-Host -eq 'q') {
    exit
}

Write-Output "Script ended at $(Get-Date)"
