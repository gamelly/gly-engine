<div align="center">
<h1>:mechanical_arm:<br>GLY Engine<br><sup><sub>powered by <a href="https://gamely.com.br" target="_blank">gamely.com.br</a></sub></sup></h1>
</div>

[<img align="right" width="40%" src="https://raw.githubusercontent.com/RodrigoDornelles/RodrigoDornelles/master/media/ginga-asteroids.gif">](https://github.com/gamelly/gly-engine/blob/main/samples/asteroids/game.lua)

[![codecov](https://codecov.io/github/gamelly/gly-engine/graph/badge.svg?token=MM0TY7VVAT)](https://codecov.io/github/gamelly/gly-engine)

> A cross-platform embeddable LUA game engine such as ginga, pc, mobile, browser and its own console like a Wii clone.

 * **Progressive "Television" Apps** _(PWA but is for Brazilian TVs)_
 * **Many testing tools** _(REPL, Unit Tests, [TAS](https://tasvideos.org/WelcomeToTASVideos#WhatIsATas) Tests)_
 * **Pure functions**

### Love 2D :heart_decoration: :desktop_computer:

```sql
lua cli.lua build @asteroids --core love --run
```

### Browser :globe_with_meridians:

```sql
lua cli.lua build @asteroids --core html5
```

#### CLI Platform Support

| command | lua 5.4 | lua 5.3 | lua 5.1 | luajit | installation |
| :-----: | :-----: | :-----: | :-----: | :----: | :----------- |
| cli.sh  |    :ok: |    :ok: |    :ok: |   :ok: | `git clone https://github.com/gamelly/gly-engine`
| cli.lua |    :ok: |    :ok: |     :x: |   :ok: | `wget http://get.gamely.com.br/cli.lua`
| gly-cli |    :ok: |         |         |        | `npm install -g @gamely/gly-cli`

#### Engine Platform Support

| Tier 1 | HTML5, WebOS2020 or later | main platform for production |
| :----- | :------------------------ | :------------ |
| Tier 2 | Love2D                    | main plataform for development and tests
| Tier 3 | Tizen 8                   | full support WIP
| Tier 4 | WebOS 6                   | support
| Tier 5 | Native Core Desktop       | full support, not available for download yet
| Tier 6 | Native Core Arduino       | coming soon
| Tier 7 | Ginga                     | support
| Tier 8 | Console TUI (ASCII)       | support
| Tier 9 | Play Station 2            | coming soon
| Tier 9 | Nintendo Wii              | support is reworking
| Tier 10 | Nintendo DS              | support, except images
| Tier 11 | Nintendo GBA             | support, except images
| Tier 12 | Play Station 1           | support, very limited
