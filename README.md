# Nim Todo CLI Manager

A minimalist, high-contrast, color-coded task list script designed to integrate perfectly with custom terminal environments and minimalist tiling desktop environments.

## Features

- **No Quotes Required**: Seamlessly add items by passing plain text.
- **Color Output Profiles**: Built-in high contrast ANSI coloring matching dark colorschemes.
- **Line Targeted Actions**: Drop or delete rows instantly using line coordinates.

## Quick Start Configuration

## First Install Nim

### Arch Linux:
```fish

sudo pacman -S nim 
```

### Ubuntu/Debian/Kali Linux:

```fish

sudo apt-get install nim
```


### Clone the repo https://github.com

```fish
git clone https://github.com
cd Ntodo
chmod +x install.sh 
./install.sh
```



## Usage:

```fish 
# Add an entry directly without string quotes
todo build an amazing nixOS config loop

# Shows the help menu 
todo 

# List all tasks
todo --list

# Delete task number 1
todo -d:1

# Empty the file
todo --clear

# Show the version
todo --version
```

## Flags:
```fish
Nim Todo Manager
Usage:
  todo [options] [task description]

Options:
  -h, --help        Display this help message
  -v, --version     Display the current version
  -l, --list        List all current tasks
  -c, --clear       Clear the entire todo list
  -d, --delete:NUM  Delete a task by its line number (e.g., -d:2)
```

