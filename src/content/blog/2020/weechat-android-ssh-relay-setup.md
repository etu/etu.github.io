---
title: Weechat Android SSH relay setup
date: '2020-08-14T18:00:00+0100'
url: /blog/2020/08/weechat-android-ssh-relay-setup/
tags: [Weechat, Android, SSH]
---

Setting up the Weechat Android [{{< fa fab github>}} GitHub](https://github.com/ubergeek42/weechat-android)
[{{< fa fab google-play >}} Play Store](https://play.google.com/store/apps/details?id=com.ubergeek42.WeechatAndroid)

relay client over SSH can be a bit tricky and quite bad at giving useful error messages. So since I'm
going through a re-setup of that I'm also writing down my notes here.

## Weechat configuration

Type the following commands into Weechat.

Placeholders such as `{port}` and `{password}` will be used here and later
on. Suggested default port is `9000`, but you need to chose something
unique on your system. This is especially important if you have a multi user
system. Setting a `{password}` is also especially important if you have a
multi user system.

```plain
# Add a relay
/relay add weechat {port}

# Add a relay password
/set relay.network.password "{password}"
```

## Weechat Android configuration

### SSH setup

#### Generating an SSH key

You need to generate a separate private key for storage on the phone to be
able to connect to the server securely. So what I do is that I generate a new
private key on a laptop, then I transfer the private key in some secure
enough way to the phone and then make sure to deploy the public key to the
server where weechat runs.

```sh
# Generate a private RSA key using openssl.
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096

# Get the public SSH key from the private RSA key.
ssh-keygen -y -f private.pem
```

I know what you're thinking: “Why not just use ssh-keygen to begin with?”.
This is because of this which still seems to be an issue:
https://github.com/ubergeek42/weechat-android/issues/317#issuecomment-421756006

#### Add the public key to your server

Make sure to add the public ssh key to your `~/.ssh/authorized_keys` file on
your server to allow connections. You get the public key by running
`ssh-keygen -y -f private.pem` as described above.

If you want some extra limitations on how this key may be used you can
prepend the key with the following string:

```plain
no-agent-forwarding,no-X11-forwarding,permitopen="127.0.0.1:{port}",
command="echo 'This account can only be used for weechat relays'"
```

Remember to replace `{port}` in there. The IP in there may be replaced by a
local host name. But that must be reflected in the relay host settings in the
app.

#### Connection settings in Weechat Android

This is also part of the tricky bit, there's a big bunch of settings and all
of them needs to be “just right”, otherwise it will fail and you will have no
idea why.

So this is an ASCII reflection of the settings menu with descriptions of what
to insert:

```plain
Settings/
`-- Connection/
    |-- Connection type        => SSH tunnel
    |-- SSH tunnel settings/
    |   |-- SSH host           => Public DNS name or IP
    |   |
    |   |-- SSH port           => Public SSH port number
    |   |
    |   |-- SSH username       => Your SSH username
    |   |
    |   |-- Private key        => Paste the contents of private.pem here.
    |   |                      => You have to find your own way of
    |   |                      => transferring this file to your phone in
    |   |                      => a way that you think is “secure enough”
    |   |
    |   `-- Known hosts        => Paste the output of the command
    |                          => "ssh-keyscan {ssh-host}" in this field.
    |                          => This is less sensitive than the private key
    |                          => but it's still easiest to run it on a
    |                          => computer and transfer it to the phone and
    |                          => paste it.
    |
    |-- Relay host             => 127.0.0.1 is probably fine. This is the IP
    |                          => to connect to after you have tunneled over
    |                          => SSH. So that's why it becomes localhost.
    |
    |-- Relay port             => Port defined in weechat settings.
    |
    `-- Relay password         => Password defined in weechat settings.
```

### Other Weechat Android settings

These are more a documentation of my personal preferences, nothing really
required for it to work. Just my preferences.

```plain
Settings/
|-- Connection/
|   |-- Reconnect on connection loss     => [X]
|   |-- Connect on system boot           => [ ]
|   |-- Only sync open buffers           => [ ]
|   `-- Sync buffer read status          => [X]
|-- Buffer list/
|   |-- Sort buffer list                 => [ ]
|   |-- Hide non-conversation buffers    => [X]
|   |-- Hide hidden buffers              => [X]
|   `-- Show buffer filter               => [ ]
|-- Look & feel/
|   `-- Dim down non-human lines         => [X]
`-- Buttons/
    |-- Show tab button                  => [X]
    |-- Show send button                 => [X]
    `-- Volume buttons change text size  => [ ]
```
