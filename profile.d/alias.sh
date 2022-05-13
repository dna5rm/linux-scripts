alias _listen="lsof -nP -iTCP -sTCP:LISTEN | sed '1 s,.*,$(tput smso)&$(tput sgr0),'"
alias ls='ls --color=auto' 2>/dev/null
alias nmap='nmap -Pn -oG -'
alias pico=nano
alias rot13="tr a-zA-Z n-za-mN-ZA-M"
alias toilet="toilet --directory ${HOME}/.fonts/figlet"
