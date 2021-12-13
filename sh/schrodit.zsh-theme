# terminal coloring

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

KUBE_PS1_PREFIX=""
KUBE_PS1_SUFFIX=""
KUBE_PS1_SEPARATOR=""
KUBE_PS1_SYMBOL_USE_IMG=true
KUBE_PS1_DIVIDER="|"

PROMPT="  %(?:%{$fg_bold[green]%}😊 :%{$fg_bold[red]%}🔥 )"
PROMPT+="%{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)
╰─ λ %{$reset_color%}"

RPS1="\$(kube_ps1)"
