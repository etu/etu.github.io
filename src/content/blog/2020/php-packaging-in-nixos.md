---
title: PHP packaging in NixOS ❄
date: '2020-04-05T20:00:00+0200'
url: /blog/2020/04/php-packaging-in-nixos/
tags: [NixOS, Nix, PHP]
---

This is a sneak peak into the future 20.09 release of NixOS.

The PHP packaging ecosystem in NixOS has been in a quite sad state for a long
time. Partly because of the lack of people caring about PHP in Nix, but also
that PHP is a bit weird when it comes to packaging.

## State of PHP before NixOS 20.09

Due to the lack of ability to do clever things like the python community does
with =withPackages= to compose a package with the dependencies you need we
have defaulted to provide a huge default package to accommodate all needs.

We have been quite bad at accommodating all needs though…

I'm gonna give a few examples.

PHP in NixOS has defaulted to including for example the following modules:

- `curl`
- `pdo_mysql`
- `pdo_odbc`
- `pdo_pgsql`
- `imap`
- `ldap`

… among many other modules. Some of these are quite convenient to get (such
as database related extensions). But some of these are totally unreasonable
to have as default in a distribution. But due to the nature of Nix and the
lack of easily extending PHP we have just coped with having a huge
distribution of PHP.

Also, at the same time we have lacked some other notable extensions in the
default build, such as `opcache`, without recompiling PHP…

So users migrating from another distribution, for example anything based on
Debian that defaults to having opcache enabled by default will see a drastic
performance penalty by migrating to NixOS. This can be fixed by enabling the
opcache flag for the build and recompile the entire PHP package. How fun…

## The road to a better PHP packaging ecosystem

Real work and thought into this project started in December 2019 when I had a
chat with Grahamc about a packaging in PHP. And he referred me to talk to a
another person that was doing a modular PHP setup. I got some notes and
started to work on it but it proved to be a huge project. So it kinda died
off there.

Then [PHP: buildEnv function for additional config on the CLI SAPI](https://github.com/NixOS/nixpkgs/pull/79377) happened
that made it easier to extend PHP as it was, and I was really happy to see
this work happening since it really followed along some of the things I
wanted to do. So I set off and made [PHP extensions as packages](https://github.com/NixOS/nixpkgs/pull/82348) to package
almost all PHP extensions as separate packages. With this it would be easier
to pull in official PHP extensions into the PHP package without the need to
recompile it.

This led to the end game to have a really small PHP as base, but it's easy to
extend. This led me to the path to start with [PHP: Make the default package
more sane](https://github.com/NixOS/nixpkgs/pull/82794) of the first iteration.
But it proved to be a big project, so [@talyz](https://github.com/talyz/) and
me teamed up with to bring this project to what we wanted to achieve.

This finally ended up as the following pull request: [PHP: Make the default
package more sane (v3)](https://github.com/NixOS/nixpkgs/pull/83896). That
now has been merged into nixpkgs. This PR change the entire PHP ecosystem
in NixOS.

## State of PHP in NixOS in 20.09 and beyond

The things we have done:

- We have made a really small PHP as base
- But we extend it by default to contain a bigger set of packages to not for
  break our users.
- We provide almost all upstream extensions and a bunch of 3rd party ones for
  inclusion into your PHP.
- We have written the initial documentation for how to use PHP on Nix.
- We have enabled running tests for every upstream extension of PHP by
  default. And we do it when we build each extension in a sandbox separate
  from each other (This has some issues though).
- We have added =opcache= as a default extension.

So hereby I now make the following claim:

NixOS now have the best packaging of PHP on any distribution of any operating
system out there when it comes to the following properties:

- Opportunity for minimalist install
- Flexibility to select exactly which extensions you want

Example to build a PHP with exactly the extensions I want:

```nix
php.withExtensions ({ enabled, all }: with all; [
  curl imagick opcache redis pdo_mysql pdo mysqlnd
  openssl posix sodium sockets
])
```

And since Nix can be used to build Docker images and be used for deployments,
this becomes a damn powerful packaging even for users that don't want to run
NixOS but want to have the power of quickly customizing PHP to exactly their
needs for that specific application.

**Let's say it again:**
NixOS now has the single best PHP packaging that exists in terms of
flexibility, being reproducible and being minimalistic at the same time.
