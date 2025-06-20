#!/bin/bash
max=6
count=0
width=50  # approximate characters per line (adjust as needed)

w -h | awk '
{
  user = $1
  source = $3
  if (source ~ /^[0-9.]+$/)
    printf "${color1}%s${color} (SSH from ${color1}%s${color})\n", user, source
  else
    printf "${color2}%s${color} (Local)\n", user
}' | while IFS= read -r line; do
  printf "%-${width}s\n" "$line"  # pad to fixed width
  count=$((count + 1))
done

# Pad remaining lines
while [ $count -lt $max ]; do
  printf "%-${width}s\n" " "
  count=$((count + 1))
done
