#!/bin/bash

# Set the path to the Homebrew installed figlet fonts directory for M1 Mac
figlet_dir="/opt/homebrew/Cellar/figlet/2.2.5/share/figlet/fonts/"

# List all .flf font files in the directory, choose a random font file
random_font_file=$(find "$figlet_dir" -type f -name "*.flf" | gshuf -n 1)

# Print a message with the random font
figlet -f "$random_font_file" "Kubernetes"
