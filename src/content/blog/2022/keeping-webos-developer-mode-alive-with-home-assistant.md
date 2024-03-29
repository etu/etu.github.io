---
title: Keeping LG webOS Developer Mode alive with Home Assistant
date: '2022-07-25T20:00:00+0100'
url: /blog/2022/07/keeping-webos-developer-mode-alive-with-home-assistant/
tags: [Jellyfin, LG, Home Assistant, Linux]
---

For over 10 years I've used [Kodi](https://kodi.tv/) on a separate PC connected to a TV to play
back local media.

A couple of weeks ago everything changed in a matter of days. I listened to
[Late Night Linux – Episode 179](https://latenightlinux.com/late-night-linux-episode-179/)
where they talked about [Jellyfin](https://jellyfin.org/). I have
looked into Jellyfin before, however I've disregarded it due to the lack of
app for LG webOS. This changed because the podcast episode told that there
was a webOS app for Jellyfin.

So I did what most people would do, I went into the LG Content Store and
searched for "jellyfin", no result. So I went and searched on the
internet. There I found that there was a [webOS client for Jellyfin](https://github.com/jellyfin/jellyfin-webos/). However
at this point it wasn't pushed to the content store (yet), so I followed
their directions in the README to enable the Developer Mode and to install it
myself.

Some time passed by and then the Jellyfin app just "went away" and we didn't
know what happened.

Since starting to use Jellyfin on webOS they have officially launched a webOS
app for webOS 6 or newer, however, if you're on an older version of webOS
it's not out just yet [Comment in thread for Publish to Store for 10.8](https://github.com/jellyfin/jellyfin-webos/issues/69#issuecomment-1179454229).
However, I manage to have a LG TV from 2021 that has webOS 5.4. So I
have to wait a bit longer.

## Keeping the session alive

So the Developer Mode app has a session timer within itself, this is lasting
50 hours. When 50 hours has passed it will log out and remove your developer
mode apps.

This 50 hours doesn't seem to be "powered on hours", instead it's human time
passed amount in hours.

This is a bit inconvenient since it would mean that you'd have to go into the
Developer Mode app every second day and press a button to not have Jellyfin
going away.

### First attempt using a systemd timer

Some time passed by, then I listened to [Late Night Linux – Episode 183](https://latenightlinux.com/late-night-linux-episode-183/) where
they talked about the webOS device manager and that one could use a cron-job
to renew the session, so I found this script [devmode-reset.sh from webosbrew](https://github.com/webosbrew/dev-utils/blob/main/scripts/devmode-reset.sh).
So I integrated it into my [NixOS configuration](https://github.com/etu/nixconfig/commit/e5eb4272f96af0625f59f0c0b23b3bf6e880696b) to run this script
every night.

The script, all the bits worked, like fetching the token from the TV itself
and posting it to LG all seemed to work. I got a `200 OK` back from LG with
some JSON telling me that it seemed fine.

However, the session never extended from this method.

### Second attempt using Home Assistant

Then it struck me, [Home Assistant](https://www.home-assistant.io/) is capable of running series of commands,
including sending Wake-On-LAN packages, switching input on TV's, sending fake
button presses and turning of TV's. So it requires to have the line
`wake_on_lan:` in `configuration.yaml` to enable Wake-On-LAN, then you'd have
to have the Home Assistant integration set up with the TV itself.

So now I have a script in home assistant that does exactly this:

1. Turn on TV (then wait 10 seconds)
1. Switch to the Developer Mode app (then wait 5 seconds)
1. Loop twice to press the DOWN button (then wait 1 second)
1. Press the ENTER button (then wait 5 seconds)
1. Turn off the TV

This script is then put in an automation that is executed in the middle of
the night (if the TV is off to not disrupt any late night TV watching).

This is pulled from my `scripts.yaml`:

```yaml
tv_extend_developer_session_time:
  alias: 'TV: Extend developer session time'
  sequence:
    - service: wake_on_lan.send_magic_packet
      data:
        mac: "" # INSERT YOUR TV's MAC ADDRESS HERE
        # The following options may be required in some network setups.
        broadcast_address: "xxx.xxx.xxx.xxx"
        broadcast_port: 9
    - delay:
        hours: 0
        minutes: 0
        seconds: 10
        milliseconds: 0
    - service: media_player.select_source
      data:
        source: Developer Mode
      target:
        entity_id: media_player.lg_webos_smart_tv # MAKE SURE THIS MATCHES YOUR INTEGRATION SETUP
    - delay:
        hours: 0
        minutes: 0
        seconds: 5
        milliseconds: 0
    - repeat:
        count: 2
        sequence:
        - service: webostv.button
          data:
            entity_id: media_player.lg_webos_smart_tv # MAKE SURE THIS MATCHES YOUR INTEGRATION SETUP
            button: DOWN
    - delay:
        hours: 0
        minutes: 0
        seconds: 1
        milliseconds: 0
    - service: webostv.button
      data:
        entity_id: media_player.lg_webos_smart_tv # MAKE SURE THIS MATCHES YOUR INTEGRATION SETUP
        button: ENTER
    - delay:
        hours: 0
        minutes: 0
        seconds: 5
        milliseconds: 0
    - service: media_player.turn_off
      data: {}
      target:
        entity_id: media_player.lg_webos_smart_tv # MAKE SURE THIS MATCHES YOUR INTEGRATION SETUP
    mode: single
    icon: mdi:remote-tv
```

This is pulled from my `automations.yaml`:

```yaml
- alias: 'TV: Extend developer session time automation'
  description: ''
  trigger:
  - platform: time
    at: 04:00:00
  condition:
  - condition: device
    device_id: 03387d9e75f0ab1b4e81c6a249f9806e # MAKE SURE THIS MATCHES YOUR INTEGRATION SETUP
    domain: media_player
    entity_id: media_player.lg_webos_smart_tv # MAKE SURE THIS MATCHES YOUR INTEGRATION SETUP
    type: is_off
  action:
  - service: script.tv_extend_developer_session_time
    data: {}
  mode: single
```
