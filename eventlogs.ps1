Clear-Host

Write-Host "===================================="
Write-Host "        EVENT LOG ANALYZER"
Write-Host "===================================="
Write-Host ""

$StartTime = (Get-Date).AddHours(-24)

$Logs = @(
    "System",
    "Application"
)

foreach ($Log in $Logs) {

    Write-Host ""
    Write-Host "----- $Log LOG -----"

    Get-WinEvent -FilterHashtable @{
        LogName   = $Log
        StartTime = $StartTime
        Level     = 1,2
    } -ErrorAction SilentlyContinue |
    Select-Object `
        TimeCreated,
        Id,
        LevelDisplayName,
        ProviderName,
        Message
}