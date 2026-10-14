# 対話シェルでのみキーバインドを設定する。
[[ -o interactive ]] || return 0

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
