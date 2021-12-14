# terminal coloring

PL_BRANCH_CHAR=$'\ue0a0'
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}[$PL_BRANCH_CHAR "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}%{$fg[red]%}!%{$fg[green]%}]" # ✗
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}]"

KUBE_PS1_PREFIX=""
KUBE_PS1_SUFFIX=""
KUBE_PS1_SEPARATOR=""
KUBE_PS1_SYMBOL_USE_IMG=true
KUBE_PS1_DIVIDER="|"

PROMPT="  %(?:%{$fg_bold[green]%}😊 :%{$fg_bold[red]%}🔥 )"
PROMPT+="%{$fg[cyan]%}%~%{$reset_color%} \$(git_prompt_info)
╰─ λ %{$reset_color%}"

RPS1="\$(kube_ps1)"
