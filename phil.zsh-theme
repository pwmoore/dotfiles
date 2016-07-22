# Theme with full path names and hostname
# Handy if you work on different servers all the time;
PROMPT='[%{$fg[green]%}%n%{$reset_color%}@%{$fg[red]%}%m$reset_color%}:%{$fg[cyan]%}%1~%{$reset_color%}%{$fg[magenta]$(git_prompt_info)$reset_color%}]%(!.#.$) '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
