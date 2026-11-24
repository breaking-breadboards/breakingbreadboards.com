# The Breaking Breadboards website

The website is built with [Eleventy](https://www.11ty.dev/).

## Getting started

Run a local dev server with live reload at http://localhost:8080/:

```sh
npm start
```

Build the static site into `_site/`:

```sh
npm run build
```

## Events

Each event is a Markdown file in `content/events/`, named `YYYY-MM-DD-Title.md`:

```md
---
title: 'Breaking Breadboards December 2026'
date: 2026-12-01
meetup: https://www.meetup.com/breaking-breadboards/events/123456789/
youtube: https://www.youtube.com/watch?v=VIDEO_ID
---
Event description, in Markdown.
```

- `meetup` (optional): the Meetup event page. A "Join us on Meetup" button is shown while the event is upcoming.
- `youtube` (optional): the live stream or recording. Any YouTube link format (or a bare video ID) works, so the stream link can be added as soon as it's scheduled. The video is embedded on the event page, with a "Watch live on YouTube" button while the event is upcoming.

Events are sorted into upcoming and previous automatically, based on `date` compared to the build date (UK time). An event stays upcoming until the end of its day. Rebuild the site after an event to move it to previous events.

## Updates

There are two scripts which can be run using GitHub Actions:
- `download-events.ps1`: This will query the Meetup iCal feed to get data on upcoming events, and will save each event to a Markdown-formatted page.
- `download-youtube-playlist.ps1`: This will download the list of videos in the Breaking Breadboards playlist on YouTube, and will create a page for each video that isn't already linked from an event page.

## Credits

Based on https://github.com/11ty/eleventy-base-blog
