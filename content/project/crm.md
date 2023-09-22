---
title: "Crm"
date: 2021-11-15T20:21:38-05:00
draft: true
---

# Personal CRM

* Monica
* Self-hosted, local vagrant box (I'm cheap)
* Built my own - had SSH issues with default instrs

## SMTP

* Protonmail bridge bc why not
* Used .deb file from protonmail
* Had to install and `init pass` (https://www.passwordstore.org/)
* Still couldn't find pass until `pass protonmail-credentials/<id?>/check` and
  enter password from `init pass`
* Then `protonmail-bridge --cli --no-window` success
* Then `login` - added account!
* From CLI `list` shows accounts and `info <idx>` shows IMAP/SMTP settings

## Monica Using SMTP

* Need to add env vars, but to who?
* Actually, what is running monica? Turns out apache
* Seems potentially easy to add to /etc/environment
* V useful test `sudo php /var/www/html/monica/artisan monica:test-email -v`

## TLS Errors

* Farts. I hate computers.
* Disable SSL in laravel? https://stackoverflow.com/questions/30714229/how-to-deal-with-self-signed-tls-certificates-in-laravels-smtp-driver/46783861#46783861
* Nope, let's try restarting the box?
