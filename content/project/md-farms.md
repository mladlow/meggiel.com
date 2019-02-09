---
title: "Maryland Horse Farms"
date: 2019-02-03T11:20:16-08:00
description: "This post describes a project to geocode and plot the registered horse farms in Maryland."
draft: false
---

# Horse Farms in Maryland

## End Results

Link to project: <https://meggiel.com/maryland-farms/index.html>
Link to source: <https://github.com/mladlow/maryland-farms>

## Background

Since 2015, I've had occasion to move my horse, Gus, twice. Each move was spurred by different reasons, but ultimately I had similar challenges both times.

Maryland is a strange state. It awkwardly spoons the eastern side of the District of Columbia, and vacillates very quickly from urban, to suburban, to rural, then back to suburban planned community. Maryland has regions with strong agricultural roots, as well as roads with mind-breakingly horrific traffic.

When I was looking for a barn, I naturally wanted one that would take good care of my horse. I was looking for reasonable facilities, lighted arenas, and staff that prioritizes horse safety. In Maryland, however, I __also__ wanted a barn that I can drive to in under 30 minutes, most times of the day.

I struggled in discovery - aside from pure word of mouth, how could I find what barns were close to my house? If I could find what was close to my house, I could at least start by calling those barns, figuring out what they had available, and visiting the ones that seemed promising, but finding barns in close proximity to my home turned out to be difficult.

I eventually stumbled upon a list of all registered horse farms produced by the Maryland Horse Board. The list, which I first obtained in 2015, included the name, phone number, and the address of the farm. If I had been familiar with the approximate location of all of the cities in Maryland, this list would have been perfect. Unfortunately, the addresses alone didn't give me much indication of how close the barn actually was to my house.

Still, I thought, I am a software engineer. I can use APIs. I can __fix__ this.

## Process

For my overall process, I geocoded the address of each stable in the Excel spreadsheet. I saved the lat/long coordinates of each stable in a JSON file on disk that I could regenerate later if needed.

### Data Preparation

I started with an Excel spreadsheet containing all the farm information. For my final product, I wanted to be able to view all those farms on a map that I could reference later.

I initially thought I might try to use Dynamo DB as an external data store, but in the end, I didn't, so my Python source files for geocoding refer confusingly to Dynamo DB. I'd like to go back and re-do the geocoding portion of the project to write to Dynamo after all.

I first exported the relevant columns from the spreadsheet as a CSV file. I only wanted the stable name, street address, city, state, zip, and phone number. I also exported the county, but I think in retrospect I would leave that part off.

### Geocoding and Storing Results

I used the Google Maps API to acquire an API key. I recommend checking out the documentation for the most up to date description of how to do this.

I had about 800 stables, and I knew that I wouldn't want to geocode each one every time I viewed the website, because I'd be hitting the Google Maps API a lot in that case, and the coordinate data for the farm shouldn't change.

Because of that, once I had all the farms in a CSV, I simply iterated through the CSV rows, geocoded each farm, and wrote the stable ID, title, lat/long, Google Maps-friendly address, and phone number of the stable out to JSON files on disk.

Again, ideally, I would have iterated through the CSV rows and wrote the results to Dynamo DB or something similar instead of to disk.

### Using My Data

I decided to use React to render my geocoded data. Now that I have a bit more familiarity with web development, I probably should have just made a static website with the map on it - I definitely didn't need a single page app framework for this project.

I decided that my list of stables and associated metadata was fine to import as part of my Javascript code, so I wrote a bash script to concatenate all the individual files into a large JSON file containing a single array. The Javascript code imports the array, and the default `create-react-app` webpack config works its magic to make the array accessible in the Javascript.

I had to use a Javascript library called `loadjs` (<https://github.com/muicss/loadjs>) to actually load a map into a `div` in my React application. Google Maps don't expect to be associated with the React component lifecycle.

From that point on, I mostly followed the Google Maps documentation to configure what was visible in the info window when the user clicked on one of the stables. I didn't include the phone number - this was also a mistake.

## Deploys

Using the default `create-react-app` command produces a webpack configuration that will build an index.html and an associated Javascript file (`yarn build`). I like bash scripts for simple things, so there is a deploy script that copies the generated HTML, CSS, and JS files to a public bucket on Amazon S3.

At this point, it was very simple to see what farms were close to my house. I was able to find one a short drive away, and it was much easier than having to work through the information on the Maryland Horse Board website.

This project was a fun learning experience - I should probably go back and work through the stuff I'd like to change, but I code full-time at my day job, so working through personal projects is slow.
