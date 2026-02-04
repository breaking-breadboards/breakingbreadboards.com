# Download Breaking Breadboards events from iCal feed and save as markdown files
param(
  [string]$ICalUrl = 'https://www.meetup.com/breaking-breadboards/events/ical/',
  [string]$OutputDir = 'content/events',
  [switch]$Force = $false
)

# https://datatracker.ietf.org/doc/html/rfc5545

function UnescapeICalContent {
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
      $title = UnescapeICalContent $Matches[1]
      break
    }

    '^URL(?:;[^:]+)?:(.+)' {
      $link = $Matches[1]
      break
    }

    '^DESCRIPTION:(.+)' {
      $description = UnescapeICalContent $Matches[1]
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

      if ((-not $Force) -and (Test-Path $filepath)) {
        Write-Host "Skipping existing file: $filename"
        break
      }

      $markdown = @"
---
title: '$($title -replace "'","''")'
link: $link
date: $isoDate
tags:
  - upcoming_events
---
$description
"@

      Set-Content -Path $filepath -Value $markdown -Encoding UTF8
      Write-Host "Saved: $filename"
      break
    }
  }
}
