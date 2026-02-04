# The Breaking Breadboards website

The website is built with [Eleventy](https://www.11ty.dev/).

## Updates

There are two scripts which can be run using GitHub Actions:
- `download-events.ps1`: This will query the Meetup iCal feed to get data on upcoming events, and will save each event to a Markdown-formatted page.
- `download-youtube-playlist.ps1`: This will download the list of videos in the Breaking Breadboards playlist on YouTube, and will create a page for each.

## Credits

Based on https://github.com/11ty/eleventy-base-blog
