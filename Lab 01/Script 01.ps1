# AD User Creation Script
$PASSWORD_FOR_DEFAULT = 'Password@123'
$USER_FIRST_LIST_AND_LAST_LIST = Get-Content .\new_names.txt
$PASSWORD = ConvertTo-SecureString $PASSWORD_FOR_DEFAULT -AsPlainText -Force

# Get the domain DN properly
$domainDN = (Get-ADDomain).DistinguishedName

# Define OUs and their paths
$OUs = @(
    @{Name = "_Customer Experience"; Path = "OU=_Customer Experience,$domainDN"},
    @{Name = "_HOD"; Path = "OU=_HOD,$domainDN"},
    @{Name = "_Utilities"; Path = "OU=_Utilities,$domainDN"}
)

# Create OUs with error handling
Write-Host "`nCreating Organizational Units..." -ForegroundColor Green
foreach ($ou in $OUs) {
    try {
        New-ADOrganizationalUnit -Name $ou.Name -Path $domainDN -ProtectedFromAccidentalDeletion $false
        Write-Host "Created OU: $($ou.Name)" -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Message -like "*already exists*") {
            Write-Host "OU $($ou.Name) already exists - continuing" -ForegroundColor Yellow
        }
        else {
            Write-Host "Error creating OU $($ou.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Split users into 3 groups of 4 each
$userGroups = @(
    $USER_FIRST_LIST_AND_LAST_LIST[0..3],   # First 4 users - Customer Experience
    $USER_FIRST_LIST_AND_LAST_LIST[4..7],   # Next 4 users - HOD
    $USER_FIRST_LIST_AND_LAST_LIST[8..11]   # Last 4 users - Utilities
)

Write-Host "`nCreating users in respective OUs..." -ForegroundColor Green

# Create users in each OU
for ($ouIndex = 0; $ouIndex -lt 3; $ouIndex++) {
    $currentOU = $OUs[$ouIndex]
    $currentUsers = $userGroups[$ouIndex]
    
    Write-Host "`nCreating users in $($currentOU.Name):" -ForegroundColor Cyan
    
    foreach($n in $currentUsers) {
        $first = $n.Split(" ")[0].ToLower()
        $second = $n.Split(" ")[1].ToLower()
        $username = "$($first.Substring(0,1)).$($second)".ToLower()
        Write-Host "Attempting to create user: $($username) in $($currentOU.Name)" -BackgroundColor Black -ForegroundColor Cyan
        
        try {
            New-AdUser -AccountPassword $PASSWORD `
                       -GivenName $first `
                       -Surname $second `
                       -DisplayName "$first $second" `
                       -Name $username `
                       -SamAccountName $username `
                       -UserPrincipalName "$username@$((Get-ADDomain).DNSRoot)" `
                       -EmployeeID $username `
                       -PasswordNeverExpires $true `
                       -Path $currentOU.Path `
                       -Enabled $true
            Write-Host "Successfully created: $username in $($currentOU.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create $username in $($currentOU.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`nUser creation process completed!" -ForegroundColor Yellow
Write-Host "Summary:" -ForegroundColor White
Write-Host "- Customer Experience OU: 4 users" -ForegroundColor White
Write-Host "- HOD OU: 4 users" -ForegroundColor White
Write-Host "- Utilities OU: 4 users" -ForegroundColor White