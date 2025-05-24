add_task() {
  local task="$1"
  local id

  if command -v uuidgen >/dev/null 2>&1; then
    id=$(uuidgen)
  else
    id="$(date +%s%N)$RANDOM"
  fi

  local date_added
  date_added=$(date -Iseconds)

  # ID | Status | Date | Text
  local encoded_task
  encoded_task=$(encode_pipe "$task")
  echo "$id|false|$date_added|$encoded_task" >> "$TODO_FILE"

  echo "Task added with ID $id: $task"
}
mark_task_done() {
  local prefix="$1"
  local task_id

  task_id=$(find_task_by_prefix "$prefix") || return 1

  if grep -q "^$task_id|" "$TODO_FILE"; then
    sed -i "s/^$task_id|false|/$task_id|true|/" "$TODO_FILE"
    echo "Task $task_id marked as done."
  else
    echo "Error: task $task_id not found in todo file." >&2
    return 1
  fi
}
delete_task() {
  local prefix="$1"
  local task_id

  task_id=$(find_task_by_prefix "$prefix") || return 1

  if grep -q "^$task_id|" "$TODO_FILE"; then
    sed -i "/^$task_id|/d" "$TODO_FILE"
    echo "Task $task_id deleted."
  else
    echo "Error: task $task_id not found in todo file." >&2
    return 1
  fi
}

edit_task() {
  local prefix="$1"
  shift
  local new_text="$*"
  local task_id

  task_id=$(find_task_by_prefix "$prefix") || return 1

  if grep -q "^$task_id|" "$TODO_FILE"; then
    local old_line
    old_line=$(grep "^$task_id|" "$TODO_FILE")
    local id status date
    IFS='|' read -r id status date _ <<< "$old_line"
    local new_line="$id|$status|$date|$new_text"
    sed -i "s/^$task_id|.*/$new_line/" "$TODO_FILE"
    echo "Task $task_id edited."
  else
    echo "Error: task $task_id not found in todo file." >&2
    return 1
  fi
}

list_tasks() {
  local filters=("$@")  
  local sort_by_date="${filters[-1]}"
  unset 'filters[-1]'   

  if [ ${#filters[@]} -eq 0 ]; then
    filters=("show_todo" "show_done")
  fi

  local status_pattern=""
  for f in "${filters[@]}"; do
    case "$f" in
      show_todo) status_pattern+="false|" ;;
      show_done) status_pattern+="true|" ;;
    esac
  done
  status_pattern="${status_pattern%|}"

  if [ "$sort_by_date" = true ]; then
    grep -E "^[^|]+\|($status_pattern)\|" "$TODO_FILE" | sort -t'|' -k3
  else
    grep -E "^[^|]+\|($status_pattern)\|" "$TODO_FILE"
  fi
}

