#!/bin/sh
# using https://github.com/dylanaraps/writing-a-tui-in-bash as guide

# Import the tui.sh library
. "$(dirname "$0")/tui.sh"

# Global variable to store the status bar process ID
status_bar_pid=""

export bar_status=" -- "

# Function to start the status bar
start_status_bar() {
  # Create the status bar
  create_status_bar &
  
  # Store the process ID of the status bar
  status_bar_pid=$!
}

# Function to stop the status bar
stop_status_bar() {
  # Check if the status bar process ID is set
  if [ -n "$status_bar_pid" ]; then
    # Send the SIGTERM signal to stop the status bar process
    kill "$status_bar_pid"
    
    # Clear the status bar process ID
    status_bar_pid=""
  fi
}

# Signal handler for the EXIT signal
on_exit() {
  # Stop the status bar process
  stop_status_bar
}

# Trap the EXIT signal and call the on_exit function
trap on_exit EXIT

# Create the status bar
create_status_bar() {

  # Start updating the clock every second
  while true; do
  
    terminal_cols="$(get_term_size | awk '{print $2}')"
    clock=$(date +"%H:%M:%S")

    # Calculate the clock width and position
    clock_len=${#clock}
    status_len=${#bar_status}
    
    spacer_len=$((terminal_cols - clock_len - status_len))

    # Save the cursor position
    cursor_save

    # Move the cursor to the top left of the terminal
    cursor_goto 1 1

    # Print the clock in the status bar
    printf "%s" "$clock"

    # Print spacer
    spacer=$(printf "%*s" "$spacer_len" | tr ' ' '_')
    printf "%s" "$spacer"

    # Print status
    # TODO bar status isn't updating from the ENV var
    printf "%s" "$bar_status"

    # Restore the cursor position
    cursor_restore

    move_if_first_line
    
    # Wait for 1 second before updating the clock again
    sleep 1
  done
}

move_if_first_line() {
  # check if cursor is on first row (after clear) and adjust
  cursor_position=$(get_cursor_pos)
  cursor_row=${cursor_position%% *}
  
  if [ "$cursor_row" = "1" ]; then 
    cursor_goto 1 "$((status_bar_height + 1))" 
  fi
}

# Create the shell terminal
# TODO upon creation, it does not print PS1
# TODO requires hitting enter once to enable PS1 (no cursor yet), 
#      and once more to show below bar (has cursor now)
create_shell_terminal() {
  # Save the cursor and hide it
  cursor_save
  cursor_hide

  # Get the terminal size
  terminal_height=$(get_term_size | awk '{print $1}')

  # Calculate the status bar height
  status_bar_height=1

  # Calculate the scrolling area
  # Adjusted for extra line
  scroll_area_start=$((status_bar_height + 1))
  scroll_area_end="$terminal_height"

  # Set the scrolling area below the status bar
  # printf "$scroll_area_start -- $scroll_area_end"
  set_scrolling_area "$scroll_area_start" "$scroll_area_end"

  # Store the current cursor position
  cursor_position=$(get_cursor_pos)
  echo "$cursor_position" | { read -r cursor_row cursor_column; }

  # Clear the screen
  screen_clear

  # Restore the cursor position within the scrolling area
  cursor_goto "$cursor_row" "$cursor_column"

  # Restore the cursor and show it
  cursor_restore

  move_if_first_line
  
  cursor_show

  # pS4="$()"

  # Run the shell
  "$SHELL" -i

  # Reset the scrolling area
  reset_scrolling_area
}

# Save the current terminal screen
save_terminal_screen

# Start the status bar
start_status_bar

# setup aliases

# Create the shell terminal
create_shell_terminal

