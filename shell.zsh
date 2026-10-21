# 対話シェルでのみキーバインドを設定する。
[[ -o interactive ]] || return 0

# 入力行を色分けし、右端に現在の Git ブランチを表示する。
PROMPT='%B%F{cyan}%n@%m%f %F{blue}%1~%f %F{green}%#%f%b '
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b (%a)'
function mac_setup_prompt() {
  vcs_info
  RPROMPT=''
  if [[ -n "$vcs_info_msg_0_" ]]; then
    RPROMPT="%F{magenta}git: ${vcs_info_msg_0_//\%/%%}%f"
  fi
}
add-zsh-hook precmd mac_setup_prompt

# 履歴に一致しない入力には、zsh の補完候補を使う。
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
if (( ! $+functions[_zsh_autosuggest_start] )); then
  for autosuggest_file in /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
    if [[ -r "$autosuggest_file" ]]; then
      source "$autosuggest_file"
      break
    fi
  done
  unset autosuggest_file
fi

function peco-history-selection() {
  local selected
  selected=$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER") || return
  BUFFER="$selected"
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

function peco-src() {
  local selected_dir
  selected_dir=$(ghq list -p | peco --query "$LBUFFER") || return
  if [[ -n "$selected_dir" ]]; then
    BUFFER="cd -- ${(q)selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^G' peco-src
