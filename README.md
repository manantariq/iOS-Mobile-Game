Group03
---

__OS:__ iOS

Project Structure
---
- __Game.swift__ <br>
This class contains the game logic and represents a game as a whole with its board and pieces. The principal method is the 'play' one, which is in charge of executing any type of action.
- __Board.swift__ <br>
This file contains the Board structure. A board is the virtual representation of a physical board.
It contains a matrix of board cells which can be flagged as special or not and can hold a piece. The methods declared here mainly deals with movements of pieces on the board.
Two methods are in charge of computing all the allowed moves and all the allowed attacks of a given piece standing the current board configuration.
- __Piece.swift__ <br>
Piece is defined as a class, so that we are able to use its reference throughout the code. Beside the trivial properties (name, vitality and so on) we have encoded the movement and the attack properties of the piece, making it as more generic as possible.
- __StringParser.swift__ <br>
This file contains all the functions needed to parse the input string, compute a game based on the current state described in the parsed string and execute the move listed in the last substring of the input string.

First Release Testing
---
Tests can be performed in '__MobileApp16Tests.swift__' where we have already prepared a function for this purpose, '_testFirstRelease()_'.
As per specifications, we have implemented the '_turnTest()_' function that takes as input the configuration+moves string and returns the resulting configuration.
