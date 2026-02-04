# Download YouTube playlist videos metadata and save as markdown files

param(
  [string]$ApiKey = $env:YOUTUBE_API_KEY,
  [string]$PlaylistId = 'PLi0kHjUZDgWbJjhtQix-VUe9BoTAw50Hi',
  [string]$OutputDir = 'content/events',
  [switch]$Force = $false
)

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$allVideos = @()
$nextPageToken = $null

do {
  Write-Host "Fetching videos from playlist $PlaylistId..."
  $url = 'https://www.googleapis.com/youtube/v3/playlistItems'
  $params = @{
    part       = 'snippet,contentDetails'
    maxResults = 50
    playlistId = $PlaylistId
    key        = $ApiKey
  }

  if ($nextPageToken) {
    $params.pageToken = $nextPageToken
  }

  $response = Invoke-RestMethod -Uri $url -Method Get -Body $params
  $allVideos += $response.items
  $nextPageToken = $response.nextPageToken

  Write-Host "Fetched $($response.items.Count) videos (Total: $($allVideos.Count))"

} while ($nextPageToken)

foreach ($item in $allVideos) {
  $videoId = $item.contentDetails.videoId
  $publishedAt = $item.contentDetails.videoPublishedAt
  $title = $item.snippet.title
  $thumbnailUrl = $item.snippet.thumbnails.high.url

  $description = $item.snippet.description -replace '\r\n', "`n"
  # Format description for markdown (two spaces before newline for line breaks)
  $description = $description -replace '(\S)\s?\n(\S)', "`$1  `n`$2"

  # Subtract a day from the publish date because I guess they hit publish the next day?
  $isoDate = Get-Date ($publishedAt.AddDays(-1)) -UFormat "%F"
  $videoUrl = "https://www.youtube.com/embed/$videoId"

  # Create a safe filename from the title
  $filename = $title -replace '[^a-zA-Z0-9_]+', '-'
  $filename = "$isoDate-$filename.md"
  $filepath = Join-Path $OutputDir $filename

  if ((-not $Force) -and (Test-Path $filepath)) {
    Write-Host "Skipping existing file: $filename"
    continue
  }

  # Create markdown content
  $markdown = @"
---
title: '$($title -replace "'","''")'
link: $videoUrl
thumbnail: $thumbnailUrl
date: $isoDate
tags:
  - previous_events
---
$description
"@

  Set-Content -Path $filepath -Value $markdown -Encoding UTF8
  Write-Host "Saved: $filename"
}
