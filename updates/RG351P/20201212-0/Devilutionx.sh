#!/bin/bash
export SDL_GAMECONTROLLERCONFIG="$(cat /roms/ports/devilution/gamecontrollerdb.txt)"
/home/ark/.config/devilution/devilutionx
unset SDL_GAMECONTROLLERCONFIG