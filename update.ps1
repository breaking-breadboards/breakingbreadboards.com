# Load environment variables from .env, then run the download scripts

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$envFile = Join-Path $PSScriptRoot '.env'
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#=\s][^=]*)\s*=\s*(.*?)\s*$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim('"').Trim("'")
            Set-Item -Path "env:$name" -Value $value
        }
    }
}

& (Join-Path $PSScriptRoot 'download-events.ps1')
& (Join-Path $PSScriptRoot 'download-youtube-playlist.ps1')
