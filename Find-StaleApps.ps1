Clear-Host

Write-Host "=========================================="
Write-Host "        INSTALLED APPS USAGE REPORT"
Write-Host "=========================================="
Write-Host ""

# Number of days before an application is considered possibly unused
$UnusedDays = 90

$CutoffDate = (Get-Date).AddDays(-$UnusedDays)

# Registry locations for installed applications
$RegistryPaths = @(

    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",

    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",

    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"

)


# Get installed applications
$InstalledApps = foreach ($Path in $RegistryPaths) {

    Get-ItemProperty $Path -ErrorAction SilentlyContinue |

    Where-Object {

        $_.DisplayName

    } |

    Select-Object `
        DisplayName,
        DisplayVersion,
        Publisher,
        InstallDate,
        InstallLocation,
        DisplayIcon,
        UninstallString

}


# Remove duplicates
$InstalledApps = $InstalledApps |
    Sort-Object DisplayName -Unique


$Results = @()


foreach ($App in $InstalledApps) {

    Write-Host "Checking: $($App.DisplayName)"

    $ExeName = $null
    $LastSeen = $null
    $DaysSinceUsed = $null
    $Status = "Unknown"


    # -----------------------------------
    # Try to find EXE name
    # -----------------------------------

    if ($App.DisplayIcon) {

        $IconPath = $App.DisplayIcon -replace '"', ''

        $IconPath = $IconPath -replace ',\d+$', ''

        if ($IconPath -match "\.exe$") {

            $ExeName = Split-Path $IconPath -Leaf

        }

    }


    # -----------------------------------
    # If DisplayIcon did not give EXE,
    # try InstallLocation
    # -----------------------------------

    if (-not $ExeName -and $App.InstallLocation) {

        if (Test-Path $App.InstallLocation) {

            $Executables = Get-ChildItem `
                $App.InstallLocation `
                -Filter "*.exe" `
                -File `
                -ErrorAction SilentlyContinue


            if ($Executables) {

                $MainExe = $Executables |
                    Sort-Object Length -Descending |
                    Select-Object -First 1


                $ExeName = $MainExe.Name

            }

        }

    }


    # -----------------------------------
    # Search Prefetch
    # -----------------------------------

    if ($ExeName) {

    $PrefetchFile = Get-ChildItem `
    "C:\Windows\Prefetch\$ExeName-*.pf" `
    -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1


        if ($PrefetchFile) {

            $LastSeen = $PrefetchFile.LastWriteTime

            $DaysSinceUsed = ((Get-Date) - $LastSeen).Days


            if ($LastSeen -lt $CutoffDate) {

                $Status = "Possibly Unused"

            }
            else {

                $Status = "Active"

            }

        }
        else {

            $Status = "No Usage Evidence"

        }

    }


    # -----------------------------------
    # Create result object
    # -----------------------------------

    $Result = [PSCustomObject]@{

        Application   = $App.DisplayName

        Version       = $App.DisplayVersion

        Publisher     = $App.Publisher

        Executable    = $ExeName

        InstallDate   = $App.InstallDate

        LastSeen      = $LastSeen

        DaysSinceUsed = $DaysSinceUsed

        Status        = $Status

    }


    $Results += $Result

}


# -----------------------------------
# Show report
# -----------------------------------

Clear-Host

Write-Host "=========================================="
Write-Host "             APPLICATION REPORT"
Write-Host "=========================================="
Write-Host ""


$Results |
Sort-Object Status, Application |
Format-Table `
    Application,
    Version,
    Executable,
    DaysSinceUsed,
    Status `
    -AutoSize


# -----------------------------------
# Export CSV
# -----------------------------------

$ReportPath = "$PSScriptRoot\StaleAppsReport.csv"

$Results |
Export-Csv `
    -Path $ReportPath `
    -NoTypeInformation `
    -Encoding UTF8


Write-Host ""
Write-Host "Report saved to:"
Write-Host $ReportPath