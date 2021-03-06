# PongVHDL
A superbly simplified version of the game "Pong", written in VHDL (targeted for the DE0 board)

### Features
+ Controllable & Automatic ball speed increase for each round
+ Player scoreboards using SSD
+ Debounced buttons
+ Multiplayer mode (2 buttons == 2 players, but you can play by yourself if you have at least 2 fingers)
+ Fun for the whole family (if everyone in your family is an engineer)

## Used in this project
+ DE0 board, running on top of a Cyclone III ep3c16f
+ 2 push buttons
+ Switches for game reset and ball speed control
+ A fantastic scoreboard, using SSDs, for each player
+ FSM for game control
+ Generic values for win conditions

## Notes
+ There is a reset input. Make sure it's set to '1' so the game can run
