# =======
# Imports
# =======

import os
import json
import logging
import parseopt2
import httpclient

import cmd

# =======
# Globals
# =======

const
  auth_token_environment_variable_name: string = "HOMEBREW_PIPELINE_API_TOKEN"

# =========
# Functions
# =========

proc Usage(): void =
  echo("help!")

proc StartLogging(verbose_flag: bool, debug_flag: bool, quiet_flag: bool): void =
  var logging_level = logging.lvlNotice
  if verbose_flag:
    logging_level = logging.lvlInfo
  if debug_flag:
    logging_level = logging.lvlDebug
  if debug_flag and verbose_flag:
    logging_level = logging.lvlAll
  if quiet_flag:
    logging_level = logging.lvlNone
  let console_logger = logging.newConsoleLogger(logging_level, "[$levelname] ")
  logging.addHandler(console_logger)
  
# ===========
# Entry Point
# ===========

let authentication_token: string = os.getEnv(auth_token_environment_variable_name)
var
  command_line_auth_token: string
  verbose_logging_flag: bool
  debug_logging_flag: bool
  quiet_logging_flag: bool
  help_flag: bool

for kind, key, value in parseopt2.getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      help_flag = true
    of "verbose", "v":
      verbose_logging_flag = true
    of "debug", "d":
      debug_logging_flag = true
    of "quiet", "q":
      quiet_logging_flag = true
    of "token", "t":
      command_line_auth_token = value
    else: discard
  else: discard

if help_flag:
  Usage()
else:
  StartLogging(verbose_logging_flag, debug_logging_flag, quiet_logging_flag)


# let client = newHttpClient()
# client.headers = newHttpHeaders({ "Authorization": "token " & authentication_token })
# echo json.parseJson(client.request("https://api.github.com/user/repos").body)
