import std/[parseopt, strutils, os, terminal]

const HelpMessage = """
Nim Todo Manager
Usage:
  todo [options] [task description]

Options:
  -h, --help        Display this help message
  -v, --version     Display the current version
  -l, --list        List all current tasks
  -c, --clear       Clear the entire todo list
  -d, --delete:NUM  Delete a task by its line number (e.g., -d:2)
"""

const Version = "0.0.3"

# --- FIXED DYNAMIC DATA ROUTING ---
# Automatically targets /home/will/.config/todo/tasks.txt across your system
let configDir = getConfigDir() / "todo"
let TodoFile = configDir / "tasks.txt"

# Ensure the parent configuration directory path exists on startup
discard existsOrCreateDir(configDir)
# ----------------------------------

proc printError(msg: string) =
  styledWriteLine(stderr, fgRed, styleBright, "✗ Error: ", resetStyle, msg)

proc printSuccess(msg: string) =
  styledWriteLine(stdout, fgGreen, styleBright, "✔ ", resetStyle, msg)

proc listTasks() =
  if not fileExists(TodoFile) or readFile(TodoFile).strip() == "":
    styledWriteLine(stdout, fgYellow, "No tasks found! Your list is empty.")
    quit(0)
  
  styledWriteLine(stdout, styleUnderscore, styleBright, "=== YOUR TODO LIST ===")
  var lineNum = 1
  for line in lines(TodoFile):
    if line.strip() != "":
      styledWriteLine(stdout, fgCyan, $lineNum, " ", fgDefault, line)
      inc lineNum

proc deleteTask(targetIndex: int) =
  if not fileExists(TodoFile):
    printError("No tasks exist to delete.")
    quit(1)

  let linesList = readFile(TodoFile).splitLines()
  var updatedLines: seq[string] = @[]
  var found = false
  var currentIdx = 1

  for line in linesList:
    if line.strip() == "": continue
    if currentIdx == targetIndex:
      found = true
      printSuccess("Removed task: \"" & line.replace("- ", "") & "\"")
    else:
      updatedLines.add(line)
    inc currentIdx

  if not found:
    printError("Line number " & $targetIndex & " does not exist.")
    quit(1)

  writeFile(TodoFile, updatedLines.join("\n") & "\n")

proc main() =
  var args = initOptParser()
  var actionSelected = false
  var textArguments: seq[string] = @[]

  while true:
    args.next()
    case args.kind
    of cmdEnd: break
    
    of cmdShortOption, cmdLongOption:
      case args.key
      of "h", "help":
        echo HelpMessage
        quit(0)
      of "v", "version":
        styledWriteLine(stdout, fgBlue, "Ntodo Version: ", fgWhite, Version)
        quit(0)
      of "l", "list":
        actionSelected = true
        listTasks()
        quit(0)
      of "c", "clear":
        actionSelected = true
        if fileExists(TodoFile):
          removeFile(TodoFile)
        printSuccess("Cleared your todo list configuration completely!")
        quit(0)
      of "d", "delete":
        actionSelected = true
        if args.val == "":
          printError("You must provide a line number to delete (e.g., todo -d:2)")
          quit(1)
        try:
          let target = parseInt(args.val)
          deleteTask(target)
        except ValueError:
          printError("Please provide a valid integer line number.")
          quit(1)
        quit(0)
      else:
        printError("Unknown option: -" & args.key)
        quit(1)

    of cmdArgument:
      textArguments.add(args.key.strip())

  if textArguments.len > 0:
    actionSelected = true
    let fullTask = textArguments.join(" ")
    let file = open(TodoFile, fmAppend)
    file.writeLine("- " & fullTask)
    file.close()
    printSuccess("Added task: \"" & fullTask & "\"")
    quit(0)

  if not actionSelected:
    echo HelpMessage

main()

