#!/bin/bash
# using https://github.com/dylanaraps/writing-a-tui-in-bash as guide

# Get the operating system name
# use: get_os
get_os() {
  os=$(uname -s)

  case $os in
    Linux*)     echo "Linux" ;;
    Darwin*)    echo "macOS" ;;
    CYGWIN*)    echo "Cygwin" ;;
    MINGW*)     echo "MinGW" ;;
    *)          echo "Unknown" ;;
  esac
}

# Get the terminal size in columns and rows
# use: get_term_size
get_term_size() {
  if [ -n "$TERM" ]; then
    rows=$(tput lines)
    cols=$(tput cols)
    echo "$rows $cols"
  else
    echo "not in term!"
  fi

}

# get cursor's current position
# use: get_cursor_pos
get_cursor_pos() {
  # Save cursor position
  printf '\033[s'

  # Query cursor position
  printf '\033[6n'

  # Read response from standard input
  local CURSOR_POSITION
  IFS=';' read -r -s CURSOR_POSITION

  # Extract row and column from response
  CURSOR_POSITION="${CURSOR_POSITION#*[}"
  local CURSOR_ROW="${CURSOR_POSITION%%;*}"
  local CURSOR_COLUMN="${CURSOR_POSITION#*;}"

  # Restore cursor position
  printf '\033[u'

  # Return cursor position
  echo "$CURSOR_ROW $CURSOR_COLUMN"
}

# Hide the cursor
# use: cursor_hide
cursor_hide() {
  printf '\033[?25l'
}

# Show the cursor
# use: cursor_show
cursor_show() {
  printf '\033[?25h'
}

# Enable line wrapping
# use: linewrap_enable
linewrap_enable() {
  printf '\033[?7h'
}

# Disable line wrapping
# use: linewrap_disable
linewrap_disable() {
  printf '\033[?7l'
}

# Moves the cursor to specific X Y coordinates
# use: cursor_goto 1 12
cursor_goto() {
  local row=$1
  local col=$2
  printf '\033[%s;%dH' "$row" "$col" #line 85
}


# Move the cursor in a specified direction by a given amount
# use: cursor_move up 3
cursor_move() {
  local direction=$1
  local amount=$2

  case $direction in
    up)
      printf '\033[%dA' "$amount"
      ;;
    down)
      printf '\033[%dB' "$amount"
      ;;
    left)
      printf '\033[%dD' "$amount"
      ;;
    right)
      printf '\033[%dC' "$amount"
      ;;
    *)
      echo "Invalid direction: $direction"
      ;;
  esac
}

# Save the cursor position
# use: cursor_save
cursor_save() {
  printf '\033[s'
}

# Restore the cursor position
# use: cursor_restore
cursor_restore() {
  printf '\033[u'
}

# Clear the screen
# use: screen_clear
screen_clear() {
  printf '\033[2J'
}

# Set the scrolling area between the specified top and bottom lines
# use: set_scrolling_area 0 10
set_scrolling_area() {
  local top_line=$1
  local bottom_line=$2
  printf '\033[%d;%dr' "$top_line" "$bottom_line"
}

# Reset the scrolling area to the default
# use: reset_scrolling_area
reset_scrolling_area() {
  printf '\033[r'
}

# Save the user's terminal screen
# use: save_terminal_screen
save_terminal_screen() {
  printf '\033[?1049h'
}

# Restore the user's terminal screen
# use: restore_terminal_screen
restore_terminal_screen() {
  printf '\033[?1049l'
}
