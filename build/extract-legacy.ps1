param(
    [string]$LegacyPath = "C:\Users\winner\Desktop\ww\Library.lua"
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Lines = [System.IO.File]::ReadAllLines($LegacyPath, [System.Text.UTF8Encoding]::new($false))
$Fragments = @(
    @{ Name = "00-bootstrap.lua"; Start = 1; End = 359 },
    @{ Name = "10-input-and-assets.lua"; Start = 360; End = 648 },
    @{ Name = "20-visuals.lua"; Start = 649; End = 899 },
    @{ Name = "30-watermark.lua"; Start = 900; End = 1211 },
    @{ Name = "40-shell.lua"; Start = 1212; End = 1658 },
    @{ Name = "50-navigation.lua"; Start = 1659; End = 2311 },
    @{ Name = "60-overlay-and-dialogs.lua"; Start = 2312; End = 2656 },
    @{ Name = "70-window.lua"; Start = 2657; End = 2799 },
    @{ Name = "80-window-utilities.lua"; Start = 2800; End = 3038 },
    @{ Name = "90-module-card.lua"; Start = 3039; End = 3307 },
    @{ Name = "100-module-state.lua"; Start = 3308; End = 3677 },
    @{ Name = "110-module-settings.lua"; Start = 3678; End = 3712 },
    @{ Name = "120-controls-basic.lua"; Start = 3713; End = 3843 },
    @{ Name = "130-controls-slider.lua"; Start = 3844; End = 4072 },
    @{ Name = "140-controls-dropdown.lua"; Start = 4073; End = 4420 },
    @{ Name = "150-controls-multi-dropdown.lua"; Start = 4421; End = 4776 },
    @{ Name = "160-controls-color.lua"; Start = 4777; End = 5237 },
    @{ Name = "170-controls-bind-and-export.lua"; Start = 5238; End = $Lines.Count }
)

if ($Lines.Count -lt 5489) {
    throw "Legacy library appears incomplete: expected at least 5489 lines, found $($Lines.Count)."
}

$Output = Join-Path $Root "src\fragments"
New-Item -ItemType Directory -Force -Path $Output | Out-Null

$LeadingLines = @()
foreach ($Fragment in $Fragments) {
    $Slice = @($LeadingLines) + @($Lines[($Fragment.Start - 1)..($Fragment.End - 1)])
    $LeadingLines = @()

    while ($Slice.Count -gt 1 -and [string]::IsNullOrWhiteSpace($Slice[$Slice.Count - 1])) {
        $LeadingLines = @($Slice[$Slice.Count - 1]) + $LeadingLines
        $Slice = $Slice[0..($Slice.Count - 2)]
    }

    [System.IO.File]::WriteAllLines((Join-Path $Output $Fragment.Name), [string[]]$Slice, [System.Text.UTF8Encoding]::new($false))
}

Write-Host "Extracted $($Fragments.Count) WinWare library fragments."
