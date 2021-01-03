---
title: "Updated Maryland Farms"
date: 2021-01-01T18:55:14-05:00
description: "This project updates the original Maryland Farms project"
draft: false
---

# Horse Farms in Maryland

## The Map

{{< md-farms >}}

For a full page version, visit <https://meggiel.com/maryland-farms/>.
Source code is available on [GitHub](https://github.com/mladlow/maryland-farms).

## Background

Back in 2017, I obtained a CSV from the
[Maryland Horse Board](https://mda.maryland.gov/horseboard/Pages/horse_board.aspx).
The CSV contained information about all the registered horse farms in Maryland -
their addresses, telephone numbers, and websites or other contact information.

Since then, some of the farm information has changed, and the Horse Board has
updated its website. Now, you can search stables and view them individually
on maps.

Unfortunately, there's still no way to view _all_ of the stables on a single
map, so that you can find stables that are in convenient locations.

I was also unable to obtain another CSV with addresses, so I couldn't re-use my
previous geocoding code. Instead, I decided to write a crawler to obtain the
addresses and contact information of the farms.

## The Crawler

Currently, I'm employed as an engineering manager at
[HashiCorp](https://www.hashicorp.com/). HashiCorp mostly uses
[Go](https://golang.org/), but as a manager I don't do much coding at work.

Still, I decided it would be fun to use Go because I haven't used it before.
The crawler uses a couple of different flavors of concurrency as I played
around with different options. It breaks down operations into three main
phases: getting the stable IDs from pages on the Horse Board portal, getting
the individual stable data, and geocoding the addresses.

### Stable IDs

The Horse Board portal is structured as a paginated list. I just read the entire
page into memory and used a regular expression to get the IDs from the links to
individual stable pages.

I wrote each ID to an intermediate file.

### Stable Pages

I grabbed individual stable pages by constructing links from the IDs collected
in phase 1.

I also read these pages into memory and used more regular expressions to pull
out the bits I was interested in. Each page on the portal was pretty clearly
automatically generated, so this part was pretty smooth.

In the end, I was able to write a JSON array containing information about the
stables to a large file.

### Geocoding

For geocoding, I tried to use
[Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim) this time around.
I was trying to move away from Google Maps a little. I stood up a Nominatim
server using Vagrant to avoid sending lots of traffic to the Open Street Map
server. Even though it seemed that I was able to load data, when I started
trying to geocode, many addresses were not found.

I double-checked my data with a couple of addresses on the Open Street Map
servers themselves, but the official Nominatim servers couldn't geocode those
either. In the process, I also noticed that there were typos in the source
data ("Floremce" instead of "Florence" for example).

So back to Google Maps. Here my only problem was figuring out how to handle
multiple results, which I go for 6 of the 719 stables. I came up with an
approximate protocol for deciding which to use, but I'm not extremely confident
in it.

In the end, I was able to write a JSON array to a file that contained all the
information on the stables.

### Phases

I wanted to break things into files so that I could easily take a closer look if
anything went wrong in an intermediate step. This way I was also able to
minimize HTTP requests, which was important. I didn't want to overwhelm the
Horse Board servers and I'm billed for the Google Maps geocoding requests.

## Website

Previously, I'd made a React app to show the final map, which used Google Maps.

This time, I wanted to move away from Google Maps *and* see if I could simplify
the website.

I wound up using [Leaflet](https://leafletjs.com/) with tiles from
[Open Street Map](https://www.openstreetmap.org/). This wound up being very
simple, easier to deploy, and possible to embed on the blog page itself, so
definitely a big win.

## In Conclusion

Once again, this was a fun experience.

I learned a bunch about Go and had fun with concurrency.

I'm also very pleased with the simplifications to the end deployable, even
though it's not styled. Before, I felt like I was using the wrong tool for the
job.
