import { DateTime } from "luxon";
import { default as metadata } from "./_data/metadata.js";

// Events are upcoming until the end of their day, local to where they're held
const EVENT_TIMEZONE = "Europe/London";

function isUpcoming(dateObj) {
  const eventDay = DateTime.fromJSDate(dateObj, { zone: "utc" }).toISODate();
  const today = DateTime.now().setZone(EVENT_TIMEZONE).toISODate();
  return eventDay >= today;
}

// Accepts a bare video ID or any common YouTube URL (watch, youtu.be, embed, live, shorts)
function youtubeId(value) {
  if (!value) {
    return undefined;
  }

  const input = String(value).trim();
  if (/^[\w-]{11}$/.test(input)) {
    return input;
  }

  const match = input.match(/(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/|live\/|shorts\/)|youtu\.be\/)([\w-]{11})/);
  if (!match) {
    throw new Error(`Unrecognised YouTube link: ${input}`);
  }

  return match[1];
}

export default function (eleventyConfig) {
  // Copy the contents of the `public` folder to the output folder
  // For example, `./public/css/` ends up in `_site/css/`
  eleventyConfig.addPassthroughCopy({ "./public/": "/" });

  // Watch CSS files
  eleventyConfig.addWatchTarget("css/**/*.css");
  // Watch images for the image pipeline.
  eleventyConfig.addWatchTarget("content/**/*.{svg,webp,png,jpg,jpeg,gif}");

  eleventyConfig.addFilter("readableDate", (dateObj, format, zone) => {
    // Formatting tokens for Luxon: https://moment.github.io/luxon/#/formatting?id=table-of-tokens
    return DateTime.fromJSDate(dateObj, { zone: zone || "utc" }).toFormat(format || "dd LLLL yyyy");
  });

  eleventyConfig.addFilter("htmlDateString", (dateObj) => {
    // dateObj input: https://html.spec.whatwg.org/multipage/common-microsyntaxes.html#valid-date-string
    return DateTime.fromJSDate(dateObj, { zone: "utc" }).toFormat('yyyy-LL-dd');
  });

  eleventyConfig.addFilter("absoluteUrl", (relativeUrl) => {
    return new URL(relativeUrl, metadata.url).toString();
  });

  eleventyConfig.addFilter("isUpcoming", isUpcoming);
  eleventyConfig.addFilter("youtubeId", youtubeId);

  eleventyConfig.addCollection("upcoming_events", (collectionApi) => {
    return collectionApi.getFilteredByTag("events").filter((item) => isUpcoming(item.date));
  });

  eleventyConfig.addCollection("previous_events", (collectionApi) => {
    return collectionApi.getFilteredByTag("events").filter((item) => !isUpcoming(item.date));
  });
};

export const config = {
  dir: {
    input: "content",          // default: "."
    includes: "../_includes",  // default: "_includes" (`input` relative)
    data: "../_data",          // default: "_data" (`input` relative)
    output: "."                // default: "_site"
  }
};
