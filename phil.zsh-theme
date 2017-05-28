# Theme with full path names and hostname
# Handy if you work on different servers all the time;
PROMPT='[%{$fg_bold[green]%}%n%{$reset_color%}@%{$fg_bold[red]%}%m%{$reset_color%}:%{$fg_bold[blue]%}%1~%{$reset_color%}$(git_prompt_info)]%(!.#.$) %'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[cyan]%} ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
