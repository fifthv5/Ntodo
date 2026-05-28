import std/[parseopt, strutils, os, terminal]

let width = terminalWidth()

const HelpMessage = """
Nim Todo CLI Manager
Usage:
  todo [options] [task description]

Options:
  -h, --help        Display this help message
  -v, --version     Display the current version
  -l, --list        List all current tasks
  -c, --clear       Clear the entire todo list
  -t, --tui         Open interactive TUI dashboard mode
  -d, --delete:NUM  Delete a task by its line number (e.g., -d:2)
"""

const Version = "0.0.4"
const TodoFileDir = "todo"
const TodoFileName = "tasks.txt"

let configDir = getConfigDir() / TodoFileDir
let TodoFile = configDir / TodoFileName

discard existsOrCreateDir(configDir)

proc printError(msg: string) =
  styledWriteLine(stderr, fgRed, styleBright, "✗ Error: ", resetStyle, msg)

proc printSuccess(msg: string) =
  styledWriteLine(stdout, fgGreen, styleBright, "✔ ", resetStyle, msg)

# Helper to read non-blank tasks securely into a raw array seq
proc loadTasks(): seq[string] =
  result = @[]
  if fileExists(TodoFile):
    for line in lines(TodoFile):
      if line.strip() != "":
        result.add(line)

# Helper to sync the live state array cleanly back to the text file
proc saveTasks(tasks: seq[string]) =
  var linesOut: seq[string] = @[]
  for task in tasks:
    if task.strip() != "":
      linesOut.add(task)
  if linesOut.len > 0:
    writeFile(TodoFile, linesOut.join("\n") & "\n")
  else:
    if fileExists(TodoFile): removeFile(TodoFile)

proc listTasks() =
  let tasks = loadTasks()
  if tasks.len == 0:
    styledWriteLine(stdout, fgYellow, "No tasks found! Your list is empty.")
    quit(0)
  
  styledWriteLine(stdout, styleUnderscore, styleBright, "=== YOUR TODO LIST ===")
  for index, line in tasks:
    styledWriteLine(stdout, fgCyan, $(index + 1), " ", fgDefault, line)

# --- FIX: POSIX Raw Mode Binding Imports for Linux/macOS ---
# These low-level headers read keyboard ticks instantly without external libraries.
type Termios {.importc: "struct termios", header: "<termios.h>".} = object
proc tcgetattr(fd: cint, termios_p: ptr Termios): cint {.importc, header: "<termios.h>".}
proc tcsetattr(fd: cint, optional_actions: cint, termios_p: ptr Termios): cint {.importc, header: "<termios.h>".}
proc cfmakeraw(termios_p: ptr Termios) {.importc, header: "<termios.h>".}
proc runTui() =
  let tasksRaw = loadTasks()
  if tasksRaw.len == 0:
    write(stdout, "\e[33mNo tasks found to navigate in interactive mode!\e[39m\r\n")
    quit(0)

  var tasks = tasksRaw
  var selectedIndex = 0
  
  var origTermios, rawTermios: Termios
  discard tcgetattr(0, addr origTermios)
  rawTermios = origTermios
  cfmakeraw(addr rawTermios)

  hideCursor()
  discard tcsetattr(0, 0, addr rawTermios)

  while true:
    # Use explicit ANSI escape sequences to clear and home the screen safely in raw mode
    write(stdout, "\e[2J\e[H")

    # Explicitly append \r\n to keep lines starting cleanly at the left margin
    stdout.write(" ".repeat((terminalWidth() - 28) div 2) & "\e[1m\e[34m=== INTERACTIVE TODO TUI ===\e[22m\e[39m\r\n")
    write(stdout, "\e[36mControls: [↑/↓] or [j/k] Move | [Space] Delete | [q/Esc] Exit\e[39m\r\n\r\n")

    for i, task in tasks:
      let displayLine = task.replace("- ", "")
      if i == selectedIndex:
        # Highlighted line block using manual ANSI rows
        write(stdout, "\e[30m\e[46m\e[1m > " & displayLine & " \e[0m\r\n")
      else:
        write(stdout, "   " & displayLine & "\r\n")

    # Flush output buffer immediately to prevent rendering lag
    flushFile(stdout)

    let ch = getch()
    case ch.int
    of 27:
      let nextCh = getch()
      if nextCh.int == 91: 
        let arrow = getch()
        case arrow.int
        of 65: # Arrow Up
          if selectedIndex > 0: dec selectedIndex
        of 66: # Arrow Down
          if selectedIndex < tasks.high: inc selectedIndex
        else: discard
      else:
        break 
    of 106, 66: # 'j' key down
      if selectedIndex < tasks.high: inc selectedIndex
    of 107, 65: # 'k' key up
      if selectedIndex > 0: dec selectedIndex
    of 32: # Spacebar deletes the highlighted task row
      tasks.delete(selectedIndex)
      saveTasks(tasks)
      if tasks.len == 0: break
      if selectedIndex > tasks.high: selectedIndex = tasks.high
    of 113, 81: # 'q' or 'Q' exit signals
      break
    else:
      discard

  # Restore standard terminal processing states cleanly
  discard tcsetattr(0, 0, addr origTermios)
  showCursor()
  write(stdout, "\e[2J\e[H")
  write(stdout, "\e[32m✔ Returned from Interactive dashboard session successfully.\e[39m\n")
  flushFile(stdout)



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
        styledWriteLine(stdout, fgBlue, "Todo CLI Version: ", fgWhite, Version)
        quit(0)
      of "l", "list":
        actionSelected = true
        listTasks()
        quit(0)
      of "t", "tui":
        actionSelected = true
        runTui()
        quit(0)
      of "c", "clear":
        actionSelected = true
        if fileExists(TodoFile): removeFile(TodoFile)
        printSuccess("Cleared your todo list configuration completely!")
        quit(0)
      of "d", "delete":
        actionSelected = true
        if args.val == "":
          printError("You must provide a line number to delete (e.g., todo -d:2)")
          quit(1)
        try:
          let target = parseInt(args.val) - 1
          var tasks = loadTasks()
          if target >= 0 and target <= tasks.high:
            printSuccess("Removed task: \"" & tasks[target].replace("- ", "") & "\"")
            tasks.delete(target)
            saveTasks(tasks)
          else:
            printError("Provided line target index out of range bounds.")
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

