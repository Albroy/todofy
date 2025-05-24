find_task_by_prefix() {
  local prefix="$1"
  local matches

  matches=$(grep "^$prefix" "$TODO_FILE" | cut -d'|' -f1)

  if [[ $(wc -l <<< "$matches") -eq 1 ]]; then
    echo "$matches"
  elif [[ $(wc -l <<< "$matches") -gt 1 ]]; then
    echo "Error: multiple matches found for prefix '$prefix'. Please use a longer prefix." >&2
    return 1
  else
    echo "Error: no task found with prefix '$prefix'." >&2
    return 1
  fi
}
print_help() {
  cat << EOF
Usage: $0 [OPTIONS]

Options:
  -a 'task'         Add a new task with the given description.
  -l                List tasks. Use filters -f and/or -c to show only todo or done tasks.
  -s NUM            Mark the task with ID prefix NUM as done.
  -f                Filter list: show only tasks not done (todo).
  -c                Filter list: show only tasks done.
  -o                Sort tasks by date in the list.
  -d NUM            Delete the task with ID prefix NUM.
  -e 'NUM NEW_TEXT' Edit the task with ID prefix NUM and replace its text with NEW_TEXT.
  -h                Show this help message and exit.

Notes:
- Task IDs can be referenced by their unique prefix when using -s, -d, or -e.
- Multiple filters -f and -c can be combined for customized listing.
EOF
}
encode_pipe() {
  local text="$1"
  echo "${text//|/%7C}"
}
decode_pipe() {
  local text="$1"
  echo "${text//%7C/|}"
}

