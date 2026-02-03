#!/bin/bash
print_mem_usage() {
  free -t | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}'
}

int_mem_usage() {
  free -t | grep Mem | awk '{printf("%d", $3/$2 * 100)}'
}

show_mem() {
  tmux set-option -g @mem_low_bg_color "$thm_yellow" # background color when cpu is low
  tmux set-option -g @mem_medium_bg_color "$thm_orange" # background color when cpu is medium
  tmux set-option -g @mem_high_bg_color "$thm_red" # background color when cpu is high

  local index=$1
  local icon=$(get_tmux_option "@catppuccin_mem_icon" "")
  local text="$(get_tmux_option "@catppuccin_mem_text" $(print_mem_usage)%)"
  if [ $(int_mem_usage) -lt 25 ]; then
    local color="$(get_tmux_option "@catppuccin_mem_color" "$thm_green")"
  elif [ $(int_mem_usage) -lt 50 ]; then
    local color="$(get_tmux_option "@catppuccin_mem_color" "$thm_yellow")"
  elif [ $(int_mem_usage) -lt 75 ]; then
    local color="$(get_tmux_option "@catppuccin_mem_color" "$thm_orange")"
  else
    local color="$(get_tmux_option "@catppuccin_mem_color" "$thm_red")"
  fi



  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
