local help_message = "Available commands:\n"
  .."- run: Executes the specified core. If no core is specified, defaults to 'love'.\n"
  .."- init: create standard structure for project in gly-engine.\n"
  .."- meta: Displays metadata for the current game.\n"
  .."- build: Builds the game and prepares it for distribution.\n"
  .."- bundler: Builds the game using the bundler.\n"
  .."- compiler: translate lua source to bytecode. (specific uses)\n"
  .."- cli-test: Runs tests located in the './tests' directory.\n"
  .."- cli-dump: extract source code (when bootstrapped).\n"
  .."- cli-build: bootstrap from the CLI as a single file.\n"
  .."- fs-replace: pattern-matching lua text transformer.\n"
  .."\n"
  .."Available cores:\n"
  .."- repl: Runs the REPL core.\n"
  .."- love: Runs the Love2D core.\n"
  .."- ginga: Runs the Ginga core.\n"
  .."- html5_webos: Builds for HTML5 on WebOS.\n"
  .."- html5_tizen: Builds for HTML5 on Tizen.\n"
  .."- html5_ginga: Runs the Ginga core for HTML5.\n"
  .."- html5: Runs the standard HTML5 core.\n"
  .."- nintendo_wii: Builds for the Nintendo Wii.\n"
  .."\n"
  .."Usage:\n"
  .."- To run a command, use: ./cli.sh <command> <game_path> -".."-core <core_name> [options]\n"
  .."- For example: ./cli.sh build ./examples/asteroids/game.lua -".."-core ginga"

local version_message = '0.0.6'

local function help()
  return true, help_message
end

local function version()
  return true, version_message
end

--! @todo show all commands with complete flags
local function show(args)
  return false, 'not implemented!'
end

local function meta()
  local description = 'not implemented!'
  return {
    meta={
      title='gly-cli',
      version=version_message,
      author='RodrigoDornelles',
      description=description
    },
    callbacks={
      init=function() end,
      loop=function() end,
      draw=function() end,
      exit=function() end,
    }
  }
end

local function not_found(args)
  return false, 'command not found: '..args['command']
end

local function correct_usage(args)
  local index = 1
  local lua = args[0] or 'gly-cli'
  local command = 'usage: '..lua..' '..args.command

  while index <= #args.params do
    local param = args.params[index]
    command = command..' ['..param..']'
    index = index + 1
  end

  index = 1
  while index <= #args.option_get do
    local option = args.option_get[index]
    command = command..' --'..option..' ['..option..']'
    index = index + 1
  end

  index = 1
  while index <= #args.option_has do
    local option = args.option_has[index]
    command = command..' --'..option
    index = index + 1
  end

  return false, command
end

local P = {
  meta = meta,
  help = help,
  version = version,
  ['not-found'] = not_found,
  ['correct-usage'] = correct_usage
}

return P
