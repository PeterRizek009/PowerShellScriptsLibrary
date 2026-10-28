# # $Password = Read-Host -Prompt "Enter the password for the new user" -AsSecureString
# # $Username = Read-Host -Prompt "Enter the username for the new user"

# # New-LocalUser `
# #     -Name $Username `
# #     -Password $Password `
# #     -FullName "IT Administrator"



# # Remove-LocalUser -Name $Username

# $users=Get-LocalUser 

# foreach ($User in $Users) {

#     Write-Host "Name    : $($User.Name)"
#     Write-Host "Enabled : $($User.Enabled)"
#     Write-Host ""

# }

Clear-Host

Write-Host "----- LOCAL ADMINISTRATORS -----"
Write-Host ""

$Admins = Get-LocalGroupMember -Group "Administrators"

foreach ($Admin in $Admins) {

    Write-Host "Name  : $($Admin.Name)"
    Write-Host "Class : $($Admin.ObjectClass)"
    Write-Host ""

}