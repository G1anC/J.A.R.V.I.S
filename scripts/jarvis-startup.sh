#!/usr/bin/env bash
msg='
        

           ██╗      █████╗      ██████╗     ██╗   ██╗    ██╗     ███████╗
           ██║     ██╔══██╗     ██╔══██╗    ██║   ██║    ██║     ██╔════╝
           ██║     ███████║     ██████╔╝    ██║   ██║    ██║     ███████╗
      ██   ██║     ██╔══██║     ██╔══██╗    ╚██╗ ██╔╝    ██║     ╚════██║
      ╚█████╔╝ ██╗ ██║  ██║ ██╗ ██║  ██║ ██╗ ╚████╔╝ ██╗ ██║ ██╗ ███████║
       ╚════╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝  ╚═╝ ╚═╝ ╚═╝ ╚══════╝


      ▸ ONLINE  ·  ALL SYSTEMS NOMINAL, SIR.'

# Claude Code wants a JSON hook payload; Crush and the shell want the raw banner.
if [[ "${1:-}" == "--json" ]]; then
    jq -n --arg msg "$msg" '{"systemMessage": $msg}'
else
    printf '%s\n\n' "$msg"
fi
