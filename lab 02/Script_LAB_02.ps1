#Requires -Version 5.1
#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Creates a secure SMB share with NTFS permissions and AD group integration.

.PARAMETER FolderPath
    Path for the shared folder (default: "E:\MarketingShare")

.PARAMETER ShareName
    SMB share name (default: "Marketing")

.PARAMETER ADGroupName
    AD group name for access (default: "Marketing")

.EXAMPLE
    .\New-SMBShare.ps1 -FolderPath "D:\Sales" -ShareName "Sales" -ADGroupName "SalesTeam"
#>

param(
    [string]$FolderPath = "D:\MarketingShare",
    [string]$ShareName = "Marketing",
    [string]$ADGroupName = "Marketing"
)

function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch($Type) { "SUCCESS" { "Green" } "ERROR" { "Red" } "WARNING" { "Yellow" } default { "White" } }
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

try {
    # Import required modules
    Import-Module ActiveDirectory, SmbShare -ErrorAction Stop
    
    # Create folder
    if (!(Test-Path $FolderPath)) {
        New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
        Write-Status "Created folder: $FolderPath" "SUCCESS"
    } else {
        Write-Status "Folder exists: $FolderPath"
    }
    
    # Create AD group
    if (!(Get-ADGroup -Filter "Name -eq '$ADGroupName'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $ADGroupName -SamAccountName $ADGroupName -GroupScope Global -GroupCategory Security
        Write-Status "Created AD group: $ADGroupName" "SUCCESS"
    } else {
        Write-Status "AD group exists: $ADGroupName"
    }
    
    # Set NTFS permissions
    $acl = Get-Acl $FolderPath
    $acl.SetAccessRuleProtection($true, $false)
    $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
    
    # Add permissions: System, Administrators, Target Group
    @(
        @("NT AUTHORITY\SYSTEM", "FullControl"),
        @("BUILTIN\Administrators", "FullControl"),
        @("$env:USERDOMAIN\$ADGroupName", "Modify")
    ) | ForEach-Object {
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $_[0], $_[1], "ContainerInherit,ObjectInherit", "None", "Allow"
        )
        $acl.AddAccessRule($rule)
    }
    
    Set-Acl -Path $FolderPath -AclObject $acl
    Write-Status "NTFS permissions configured" "SUCCESS"
    
    # Remove existing share and create new one
    Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue | Remove-SmbShare -Force
    New-SmbShare -Name $ShareName -Path $FolderPath -FullAccess "BUILTIN\Administrators","$env:USERDOMAIN\$ADGroupName"
    
    Write-Status "Share created: \\$env:COMPUTERNAME\$ShareName" "SUCCESS"
    
} catch {
    Write-Status "Error: $_" "ERROR"
    exit 1
}