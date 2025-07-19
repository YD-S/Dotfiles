
alias 42format='find . -type f \( -name "*.c" -or -name "*.h" \) -and -not -wholename "*/libs/*" | xargs c_formatter_42'

alias clion='open -na "CLion.app" --args "$@"'

alias ga='git add .'

alias gc='git commit -m --args "$@"'

alias gp='git push'

alias l='ls -la'

alias cls='clear'

setopt  autocd autopushd

plugins=(m cargo git mercurial repo python history-substring-search osx vagrant docker brew zsh-syntax-highlighting encode64 web-search colored-man-pages extract)

export PATH=/opt/homebrew/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Users/yash/.cargo/bin:/Users/yash/Library/Application:/Users/yash/Downloads/apache-maven-3.9.6/bin

eval "$(starship init zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/yash/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH=$HOME/development/flutter/bin:$PATH

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

export PATH="$HOME/.symfony5/bin:$PATH"
