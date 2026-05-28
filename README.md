# Nim Todo CLI Manager

A minimalist, high-contrast, color-coded task list script designed to integrate perfectly with custom terminal environments and minimalist tiling desktop environments.

## Features

- **No Quotes Required**: Seamlessly add items by passing plain text.
- **Color Output Profiles**: Built-in high contrast ANSI coloring matching dark colorschemes.
- **Line Targeted Actions**: Drop or delete rows instantly using line coordinates.

## Quick Start Configuration

### Arch Linux
```fish

sudo pacman -S nim 
```

### Ubuntu/Debian/Kali Linux

```fish

sudo apt-get install nim
```


## Usage

```fish 
# Add an entry directly without string quotes
todo build an amazing nixOS config loop

# List all tasks
todo --list

# Delete task number 1
todo -d:1

# Empty the file
todo --clear
```

```
