#!/bin/bash

#command -v uuidgen >/dev/null 2>&1 && echo "uuidgen found" || echo "uuidgen not found"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"

source "$BASE_DIR/conf"
source "$BASE_DIR/utils.sh"
source "$BASE_DIR/todo_functions.sh"

mkdir -p "$TODO_DIR"

action=""
task=""
filters=()
while getopts "a:ls:cofhd:e:" opt; do
  case "$opt" in
    a)
      action="add"
      task="$OPTARG"
      ;;
    s)
      action="setdone"
      task="$OPTARG"
      ;;
    l)
      action="list"
      ;;
    f)      
      filters+=("show_todo")
      ;;
    c)
      filters+=("show_done")
      ;;
    o)
      sort_by_date=true
      ;;
    d)
      action="delete"
      task="$OPTARG"
      ;;
    e)
      action="edit"
      edit_args=($OPTARG)  
      ;;
    h|*)
      print_help
      exit 0
      ;;
  esac
done


case "$action" in 
  add)
    add_task "$task"
    ;;
  setdone)
    mark_task_done "$task"
    ;;
  delete)
    delete_task "$task"
    ;;
  edit)
    num="${edit_args[0]}"
    new_text="${edit_args[@]:1}"
    edit_task "$num" "$new_text"
    ;;
  list)
      list_tasks "${filters[@]}" "$sort_by_date"
      ;;
  *)
    echo "No valid action specified. Use -h for help."
    ;;
esac

