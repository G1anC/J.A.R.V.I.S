#!/usr/bin/env bash
msg='
        

       888888        d8888 8888888b.  888     888 8888888 .d8888b.
         "88b       d88888 888   Y88b 888     888   888  d88P  Y88b
          888      d88P888 888    888 888     888   888  Y88b.
          888     d88P 888 888   d88P Y88b   d88P   888   "Y888b.
          888    d88P  888 8888888P"   Y88b d88P    888      "Y88b.
          888   d88P   888 888 T88b     Y88o88P     888        "888
          88P  d8888888888 888  T88b     Y888P      888  Y88b  d88P
          888 d88P     888 888   T88b     Y8P     8888888 "Y8888P"
        .d88P
      .d88P"
      888P"


      ▸ ONLINE  ·  ALL SYSTEMS NOMINAL, SIR.'

jq -n --arg msg "$msg" '{"systemMessage": $msg}'
