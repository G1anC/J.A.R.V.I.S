# Crush has no session-start hook, so wrap the binary to print the banner first.
# Source from ~/.zshrc:  source ~/.agents/crush/jarvis-crush.zsh
crush() {
    local banner="$HOME/.agents/scripts/jarvis-startup.sh"
    if [[ -t 1 && -x "$banner" && -z "$CRUSH_NO_BANNER" ]]; then
        "$banner"
    fi
    command crush "$@"
}
