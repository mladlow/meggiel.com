---
title: "Waypoint"
date: 2021-04-10T08:22:27-04:00
draft: true
---

Today, I tried to use HashiCorp's Waypoint to do local development (and
eventually deploy) an AWS Lambda function written in Go. Ultimately I was not
successful.

# Lifecycle

It took me a while to untangle the Waypoint lifecycle.

Waypoint has lots of examples, but most of the deployed ones are languages that
don't compile (the Ruby Lambda example and the Python ECS example).

I eventually stumbled upon the go `waypoint.hcl` example, which build with
Heroku buildpacks.

# Build
* Building with a docker image would allow you to create a docker image with
  everything bundled in
* Is definitely excessive for very simple go app
  * If you were compiling your go app, you might want to do that compiliation in
    the docker image though

## Waypoint Build

* Docs say build step takes application source and converts into artifact
  * So in my case, I don't think I want to build on the image, necessarily
  * Well, I don't want to build on the AWS Go Lambda image
  * Or if I do, I'd want to edit it with the dockerfile
* Artifacts can then be deployed onto container images

## Docker Images

* A thing I've never quite understood
* Found
  https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324
  which was helpful for finding something with go
  * It uses `go mod -d` which doesn't "build or install packages", only updates
    "go.mod and download[s] source code needed to build packages".
  * Since go.mod is usually checked in, I wouldn't want `go get` to update
    `go.mod` when building?

# Entrypoint
* Waypoint failed to inject an entrypoint, which makes sense because I haven't
  defined one
  * If build is building a docker image though, what is the build step and where
    is the entry point defined?

# Deploy
* I wouldn't actually want to deploy a whole image though, I just want to push a
  go binary to lambda - is waypoint overkill in that case?

# Notes
* Hilariously, the lambda go image doesn't have go installed
  * I guess this is kind of fair because you should be able to build with just
    the GOOS/GOARCH as a target and it will Just Work
* I've never written go with dependencies before but you need some for lambda,
  so I had to `go mod init`, but didn't have to `go get`
* Can you use waypoint to run stuff locally? It kind of doesn't seem like it,
  which is annoying
  * Maybe what I actually want is Terraform
* As is often the case with HashiCorp documentation, I feel there are some key
  missing pieces between the words and the comprehension of readers. Undoubtedly
  a solid reference once the material is understood, there's nothing to help you
  reach that foundation of understanding.
* This was much easier with SAM - I get the cross-cloud workflow, but feel like
  at the hobbyist level it's not that useful.

## Lessons learned

* To run go on lambda you deploy binaries which run on a go lambda docker image
  * You can't _build_ binaries on that image - it doesn't have go installed, but
    that's where they run
* Waypoint doesn't seem to help with any kind of local simulation of deployment,
  which is a sadness
  * Waypoint "enables developers to describe how to get their applications from
    development to production in a single file"
  * "Developers just want to deploy" - but a big part of that is actually
    running locally?
  * "You don't need to write Dockerfiles" but I did need to, to deviate from the
    examples in any way
* If you're not going to offer local development, not being able to clean
  yourself up all the way is kind of...terrible? Like I'm getting billed for
  these images that you're deploying.
