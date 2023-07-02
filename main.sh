#!/bin/sh

# requires go
# requires gum
#     https://github.com/charmbracelet/gum#installation
#       or
#     go install github.com/charmbracelet/gum@latest


# see ./specs.md for reqs and main thoughts

logo=$(cat << "EOV"
   ___  _______ __ _  __ ____ __
  / _ \/ __/ -_)    \/ // /\ \ /
 / .__/_/  \__/_/_/_/\_,_//_\_\
/_/
EOV
)



# Get the width of the terminal
width=$(stty size | awk '{print $2}')

# Generate a string of spaces with the specified width
spaces=$(printf '%*s' "$width" "")

# style logo
LOGO=$(gum style --padding "5 5" --foreground 212 "$logo")

# center in screen
gum join --align center --vertical "$LOGO" "$spaces"


# ========================================================================



# ========================================================================


# get all panes/windows/sessions
# tmux list-panes -a -F '#{pane_current_command}'

# Get list of all tmux sessions
session_list=$(tmux list-sessions -F "#S")

# Loop through each session

# Get list of all tmux sessions
session_list=$(tmux list-sessions -F "#S")

# Loop through each session
for session_name in $session_list; do
    echo "Session: $session_name"

    # Get list of windows within the session
    window_list=$(tmux list-windows -F "#I:#W" -t "$session_name")

    # Loop through each window
    while IFS=':' read -r window_index window_name; do
        echo "├─ Window $window_index: $window_name"

        # Get list of panes within the window
        pane_list=$(tmux list-panes -F "#P" -t "$session_name:$window_index")

        # Loop through each pane
        for pane_index in $pane_list; do
            pane_command=$(tmux display-message -p -t "$session_name:$window_index.$pane_index" "#{pane_current_command}")
            if [ "$pane_index" == "${pane_list##* }" ]; then
                echo "│  └─ $pane_index ($pane_command)"
            else
                echo "│  ├─ $pane_index ($pane_command)"
            fi
        done
        echo ""
    done <<< "$window_list"
    echo ""
done

