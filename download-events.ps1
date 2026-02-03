# Download Breaking Breadboards events from iCal feed and save as markdown files
param(
    [string]$ICalUrl = 'https://www.meetup.com/breaking-breadboards/events/ical/',
    [string]$OutputDir = 'events'
)

# https://datatracker.ietf.org/doc/html/rfc5545

function Unescape-ICalContent {
    param([string]$Content)

    $Content = $Content -replace '(?:\\[Rr])?\\[Nn]', "`n"
    $Content = $Content -replace '\\([,;\\])', '$1'

    return $Content
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

Write-Host "Downloading iCal feed from $ICalUrl..."

$response = Invoke-WebRequest -Uri $ICalUrl -UseBasicParsing
$icalContent = $response.Content -replace '\r\n', "`n"

# Unfold folded lines
$icalContent = $icalContent -replace '\n[ \t]', ''

$lines = $icalContent -split "`n"

foreach ($line in $lines) {
    switch -Regex ($line) {
        '^BEGIN\:VEVENT' {
            $title = ''
            $link = ''
            $description = ''
            $dtstart = ''
            break
        }

        '^SUMMARY:(.+)' {
            $title = Unescape-ICalContent $Matches[1]
            break
        }

        '^URL(?:;[^:]+)?:(.+)' {
            $link = $Matches[1]
            break
        }

        '^DESCRIPTION:(.+)' {
            $description = Unescape-ICalContent $Matches[1]
            break
        }

        '^DTSTART(?:;[^:]+)?:(.+)' {
            $dtstart = [DateTime]::ParseExact($Matches[1], 'yyyyMMddTHHmmssK', $null)
            $isoDate = Get-Date -Date $dtstart -UFormat '%F'
            break
        }

        '^END\:VEVENT' {
            # Create a safe filename from the title
            $filename = $title -replace '[^a-zA-Z0-9_]+', '-'
            $filename = "$isoDate-$filename.md"
            $filepath = Join-Path $OutputDir $filename

            if (Test-Path $filepath) {
                Write-Host "Skipping existing file: $filename"
                break
            }

            $markdown = @"
# $title

**Link:** $link

**Date:** $isoDate

## Description

$description

---
*Downloaded from Breaking Breadboards Meetup iCal feed*
"@

            Set-Content -Path $filepath -Value $markdown -Encoding UTF8
            Write-Host "Saved: $filename"
            break
        }
    }
}
