#!/bin/bash

# A script that checks read, write, execute permissions in a specificied directory for a specified set of users
# Use: bash directory-permissions.sh <directory> <user1> <user2> ...
# e.g. bash directory-permissions.sh /srv/labshare labuser serveradmin

# Get directory
directory=$1 
# Shift arguments along (now $1 is user1, etc.)
shift
# Loop over all remaining CL args
for user in "$@"; do
  echo
  echo "Checking user: $user"
  
  # Read test
  # The quoutes around $user stops it being split into multiple args if it contains spaces
  # >/dev/null: Redirects standard output (stdout) to /dev/null, a special destination that discards anything written to it
  # A command has three standard streams: 0 = stdin (input); 1 = stdout (normal output); 2 = stderr (error message)
  # 2>&1: Redirects standard error (stderr) to wherever standard output is currently going /dev/null
  if sudo -u "$user" ls "$directory" >/dev/null 2>&1; then
    echo "READ TEST (list directory): PASS ($user can read directory)"
  else 
    echo "READ TEST (list directory): FAIL ($user cannot read directory)"
  fi

  # Write test
  # Define write file and remove if already exists
  wfile="$directory/$user-write.txt"
  if [[ -f "$wfile" ]]; then
    sudo rm -- "$wfile"
  fi
  # Check if can create write file, removing afterwards if can
  if sudo -u "$user" touch "$wfile" 2>/dev/null; then
    echo "WRITE TEST (create a file): PASS ($user can write)"
    sudo rm -- "$wfile"
  else 
    echo "WRITE TEST (create a file): FAIL ($user cannot write)"
  fi

  # Execute test for directories
  # test: Tests a specific condition (0 if true, !0 if false)
  # x: Checks whether the specified user has execute access to the path.
  if sudo -u "$user" test -x "$directory"; then
    echo "EXECUTE TEST (traverse directory): PASS ($user can traverse directory)"
  else 
    echo "EXECUTE TEST (traverse directory): FAIL ($user cannot traverse directory)"
  fi
done
