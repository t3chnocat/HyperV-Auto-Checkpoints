<#
.SYNOPSIS
This script creates checkpoints for a user-specifed list of VMs in Hyper-V and deletes checkpoints older than a user-specified age.

.DESCRIPTION
This script was written with the intention of being run as a weekly scheduled task, creating standard checkpoints for the specified VMs. Standard checkpoints are created so this is not suggested for VMs that recplicate data with others, e.g. Active Directory.

The default age is 30 days so you will have rolling checkpoints for a month.

.EXAMPLE
.\Auto-Checkpoint.ps1

.LINK
https://t3chnocat.com

#>

# User variables begin
# Checkpoints with an age greater than this in days will be deleted
$age = 30

# Comma separated list of VM names you want to have checkpoints for. Names are not case-sensitive but should be enclosed by single quotes.
$VMname = 'VM 1', 'VM 2'
# User variables end

# get list of VM names and assign to $VMlist
$VMlist = get-vm | Select-Object -ExpandProperty Name

# Check given VM names to make sure they exist in $VMlist and exit script if not
$VMname | ForEach-Object { if ($VMlist -notcontains $_) { Write-Error "$_ is not a valid VM, please check the `$VMlist user variable" -ErrorAction stop}}

# Set $date variable to current date and time in year/month/day - hour:time format
$date = get-date -Uformat "%Y/%m/%d - %H:%M"

# Create checkpoints
$VMname | ForEach { Write-Host "Creating checkpoint for $_..."; Checkpoint-VM -Name $_ -SnapshotName "Weekly Checkpoint - $date" }

# Delete checkpoints older than $age days
$VMname | ForEach { Write-Host "Deleting checkpoints for $_ that are older than $age days"; Get-VMSnapshot -VMName $_ | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$age)} | Remove-VMCheckpoint }
