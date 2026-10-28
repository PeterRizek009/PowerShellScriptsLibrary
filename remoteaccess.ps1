Enable-PSRemoting -Force


# Invoke-Command `
#     -ComputerName PC001 `
#     -ScriptBlock {

#         Get-Service Spooler

#     }


#     $Computers = @(
#     "PC001",
#     "PC002",
#     "PC003"
# )

# Invoke-Command `
#     -ComputerName $Computers `
#     -ScriptBlock {

#         Get-Service Spooler

#     }