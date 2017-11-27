%************************************************************
%* Name:               Ivaylo Nenovski                      *
%* Project:            Longana Prolog                       *
%* Class:              CMPS 366-01                          *
%* Date:               12/08/2017                           *
%************************************************************




%************************************************************************************************
%************************************ Round Implementation **************************************
%************************************************************************************************


%**************************************************************
%Function Name: initializeRound
%Purpose: To create a new round, i.e. generate a stock and deal tiles to each player
%Parameters: None
%Return Value: List containing Human hand, Computer hand, Stock after tiles we dealt i.e. ->
%              [HumanHand, ComputerHand, RoundStock].
%Local Variables:
%   Stock      - A newly generated and shuffled stock
%Algorithm: None
%Assistance Received: None 
%**************************************************************
initializeRound(Ret) :-
    createStock(Stock),
    dealTilesAtRoundBeginning(0, 8, Stock, [], [], Ret),
    printState(Ret).


%**************************************************************
%Function Name: printState
%Purpose: To print the current state of Longana, i.e. human hand, computer hand, stock
%Parameters:
%   State    - a list of human hand, computer hand, and stock
%Return Value: None
%Local Variables:
%   HummanHand    - Current human hand
%   ComputerHand  - Current computer hand
%   Stock         - Current stock
%Algorithm: None
%Assistance Received: None 
%**************************************************************
printState(State) :-
    [HumanHand | [ComputerHand | [Stock | _ ]]] = State,
    write("Humman hand: "), write(HumanHand), nl,
    write("Computer hand: "), write(ComputerHand), nl,
    write("Stock: "), write(Stock), nl, nl.












%************************************************************************************************
%********************************** Strategies Implementation ***********************************
%************************************************************************************************


computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles).


%**************************************************************
%Function Name: computerAvailableMoves
%Purpose: To get the available tiles of possible computer moves
%Parameters:
%   Hand    - computer's hand
%   Board   - the current board
%Return Value: A list of available tiles for the computer to play
%Local Variables:
%   Tile     - first tile of computer's hand
%   Rest     - the rest of the computer's hand
%Algorithm:
%   If a tile can be played on the right, or is double and can be played on the left,
%   then add it to the list of available tiles, otherwise recursively call the function
%   on the rest of the hand.
%Assistance Received: None 
%**************************************************************
computerAvailableTiles([], Board, []).

computerAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    canPlayRight(Tile, Board),
    computerAvailableTiles(Rest, Board, AvailableTiles).

computerAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    isDoubleTile(Tile),
    canPlayLeft(Tile, Board),
    computerAvailableTiles(Rest, Board, AvailableTiles).

computerAvailableTiles(Hand, Board, AvailableTiles) :-
    [ _ | Rest] = Hand,
    computerAvailableTiles(Rest, Board, AvailableTiles).



%**************************************************************
%Function Name: humanAvailableMoves
%Purpose: To get the available tiles of possible human moves
%Parameters:
%   Hand    - human's hand
%   Board   - the current board
%Return Value: A list of available tiles for the human to play
%Local Variables:
%   Tile     - first tile of human's hand
%   Rest     - the rest of the human's hand
%Algorithm:
%   If a tile can be played on the left, or is double and can be played on the right,
%   then add it to the list of available tiles, otherwise recursively call the function
%   on the rest of the hand.
%Assistance Received: None 
%**************************************************************
humanAvailableTiles([], Board, []).

humanAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    canPlayLeft(Tile, Board),
    humanAvailableTiles(Rest, Board, AvailableTiles).

humanAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    isDoubleTile(Tile),
    canPlayRight(Tile, Board),
    humanAvailableTiles(Rest, Board, AvailableTiles).

humanAvailableTiles(Hand, Board, AvailableTiles) :-
    [ _ | Rest] = Hand,
    humanAvailableTiles(Rest, Board, AvailableTiles).



%**************************************************************
%Function Name: canPlayLeft
%Purpose: To determine whether a tile can be played from the left side of the board
%Parameters:
%   Tile    - tile to be played
%   Board   - the current board
%Return Value: true if tile can be played, false otherwise
%Local Variables:
%   Pip1, Pip2   - left/right pip of tile to be played
%   LeftTile     - left most tile on the board
%   BoardPip1    - left pip of LeftTile
%Algorithm: None
%Assistance Received: None 
%**************************************************************
canPlayLeft(Tile, Board) :-
    [Pip1 | [Pip2 | _ ]] = Tile,
    [LeftTile | Rest] = Board,
    [BoardPip1 | _ ] = LeftTile,
    Pip2 = BoardPip1.

canPlayLeft(Tile, Board) :-
    reverseTile(Tile, ReversedTile),
    [Pip1 | [Pip2 | _ ]] = ReversedTile,
    [LeftTile | Rest] = Board,
    [BoardPip1 | _ ] = LeftTile,
    Pip2 = BoardPip1.



%**************************************************************
%Function Name: canPlayRight
%Purpose: To determine whether a tile can be played from the right side of the board
%Parameters:
%   Tile    - tile to be played
%   Board   - the current board
%Return Value: true if tile can be played, false otherwise
%Local Variables:
%   Pip1, Pip2   - left/right pip of tile to be played
%   LeftTile     - right most tile on the board
%   BoardPip1    - right pip of RightTile
%Algorithm: None
%Assistance Received: None 
%**************************************************************
canPlayRight(Tile, Board) :-
    [Pip1 | [Pip2 | _ ]] = Tile,
    last(Board, RightTile),
    [BoardPip1 | [BoardPip2 | _ ]] = RightTile,
    Pip1 = BoardPip2.

canPlayRight(Tile, Board) :-
    reverseTile(Tile, ReversedTile),
    [Pip1 | [Pip2 | _ ]] = ReversedTile,
    last(Board, RightTile),
    [BoardPip1 | [BoardPip2 | _ ]] = RightTile,
    Pip1 = BoardPip2.



%**************************************************************
%Function Name: highestTile
%Purpose: To determine the highest tile in the available tiles to play
%Parameters:
%   AvailableTiles    - tiles which can be played
%Return Value:
%             The tile with highest sum of the available tiles
%Local Variables:
%   First, Second        - first and second tiles of the available ones
%   SumFirst, SumSecond  - sum of the first tile and sum of the second tile
%Algorithm: Get the first 2 elements in the list and remove the one with lower pip sum.
%           Keep doing this, until only 1 tile is left. This is your answer.
%Assistance Received: None 
%**************************************************************
highestTile(AvailableTiles, Answer) :-
    length(AvailableTiles, L),
    L = 1,
    [Answer | _ ] = AvailableTiles.

highestTile(AvailableTiles, Answer) :-
    [First | [Second | _ ]] = AvailableTiles,
    pipSum(First, SumFirst),
    pipSum(Second, SumSecond),
    SumFirst > SumSecond,
    [ _ | [ _ | Rest]] = AvailableTiles,
    NewAvailableTiles = [First | Rest],
    highestTile(NewAvailableTiles, Answer).

highestTile(AvailableTiles, Answer) :-
    [First | [Second | _ ]] = AvailableTiles,
    pipSum(First, SumFirst),
    pipSum(Second, SumSecond),
    SumSecond > SumFirst,
    [ _ | Rest] = AvailableTiles,
    highestTile(Rest, Answer).

















%************************************************************************************************
%*********************************** Stock Implementation ***************************************
%************************************************************************************************

%**************************************************************
%Function Name: generateStock
%Purpose: To generate a stock for Longana
%Parameters:
%   Pip1 - pip1 starting point (e.g 0)
%   Pip2 - pip2 starting point (e.g 0)
%   Stock - the current stock
%Return Value: RetVal - a list of tiles (each tile is a list of 2 integers)
%Local Variables:
%   NewTile - the tile formed from Pip1 and Pip2
%   NewStock - the stock after the new tile is appened to it
%   NewPip1 - the updated pip1
%   NewPip2 - the updated pip2
%Algorithm: Recursively loop from 0,0 to 6,6 and record each pair in the variable Stock
%Assistance Received: None 
%**************************************************************

%Base case
generateStock(6, 6, Stock, [[6, 6] | Stock]).

%Recursive cases
generateStock(Pip1, Pip2, Stock, RetVal) :-
    NewTile = [Pip1, Pip2],
    NewStock = [NewTile | Stock],
    Pip2 = 6,
    NewPip1 is Pip1 + 1,
    NewPip2 = NewPip1,
    generateStock(NewPip1, NewPip2, NewStock, RetVal).

generateStock(Pip1, Pip2, Stock, RetVal) :-
    NewTile = [Pip1, Pip2],
    NewStock = [NewTile | Stock],
    NewPip2 is Pip2 + 1,
    generateStock(Pip1, NewPip2, NewStock, RetVal).


%**************************************************************
%Function Name: shuffleStock
%Purpose: To randomly shuffle the stock
%Parameters:
%   Start - beginning number for shuffling, then go all the way to 1000
%   Stock - the newly generated stock
%Return Value:
%    RetVal - the shuffled stock
%Local Variables:
%Algorithm: Recursively iterate 1000 times over the generated Stock and
%    remove the first element and put it at a randomly generated index.
%Assistance Received: None 
%**************************************************************
shuffleStock(500, Stock, Stock).

shuffleStock(Start, Stock, RetVal) :-
    NewStart is Start + 1,
    [First | Rest] = Stock,
    random_between(0, 27, RandIndex),
    insertAt(0, RandIndex, First, Rest, NewStock),
    shuffleStock(NewStart, NewStock, RetVal).


%**************************************************************
%Function Name: createStock
%Purpose: To generate and randomly shuffle a new stock for a round of Longana
%Parameters: None
%Return Value:  A newly generated and shuffled stock!
%Local Variables:
%   GeneratedStock - the result of generateStock clause
%Algorithm: None, look at generateStock and shuffleStock for details
%Assistance Received: None 
%**************************************************************
createStock(Stock) :-
    generateStock(0, 0, [], GeneratedStock),
    shuffleStock(0, GeneratedStock, Stock).


%**************************************************************
%Function Name: dealTile
%Purpose: To deal a tile from the stock to the given hand
%Parameters:
%   1. Stock - the given stock for the game
%   2. Hand  - the hand to which to deal the tile
%Return Value:
%    The new hand with the given tile added
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
dealTile([], Hand, Hand).

dealTile([First | _ ], Hand, [First | Hand]).


%**************************************************************
%Function Name: dealTilesAtRoundBeginning
%Purpose: To distribute 8 tiles to each player at the beginning of a round.
%Parameters:
%   Start         - the beginning of a recursion, usually 0
%   End           - when to stop the recursion - usually 8, since each player needs to have 8 tiles distributed to her
%   Stock         - the given stock for the game
%   HumanHand     - the hand of the human player
%   ComputerHand  - the hand of the computer player
%Return Value:
%    A list containing 3 lists -> [HumanHand, ComputerHand, Stock].
%Local Variables:
%   NewHumanHand    - Human hand after a tile was given from the stock
%   NewStock1       - Stock after a tile was given to human
%   NewComputerHand - Computer hand after a tile was given from the stock
%   FinalStock      - Stock after a tile was given to computer
%Algorithm: None
%Assistance Received: None 
%**************************************************************
dealTilesAtRoundBeginning(Start, End, Stock, HumanHand, ComputerHand, Ret) :-
    Start = End,
    append([HumanHand], [ComputerHand], Hands),
    append(Hands, [Stock], Ret).

dealTilesAtRoundBeginning(Start, End, Stock, HumanHand, ComputerHand, Ret) :-
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock1),
    dealTile(NewStock1, ComputerHand, NewComputerHand),
    removeFirstTile(NewStock1, FinalStock),
    NewStart is Start + 1,
    dealTilesAtRoundBeginning(NewStart, End, FinalStock, NewHumanHand, NewComputerHand, Ret).















%************************************************************************************************
%************************************ Tile Implementation ***************************************
%************************************************************************************************


%**************************************************************
%Function Name: validTile
%Purpose: To make sure that the given tile is valid, i.e. it is in the range of
%         the 28 double tile set!
%Parameters:
%   Pip1    - left side of the tile
%   Pip2    - right side of the tile
%   Note*   - Should pass a tile as a list, such as ?- validTile( [2,3] ).
%Return Value:  true if tile is valid, false otherwise
%Local Variables: None
%Algorithm: Check for given conditions for a tile to be valid
%Assistance Received: None 
%**************************************************************
validTile([Pip1 | [Pip2 | _]]) :-
    Pip1 =< 6,
    Pip1 >= 0,
    Pip2 =< 6,
    Pip2 >= 0.


%**************************************************************
%Function Name: isDoubleTile
%Purpose: To determine whether a tile is double or not
%Parameters:
%   Pip1   - left side of tile
%   Pip2   - right side of tile
%Return Value:  true if tile is double, false otherwise
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
isDoubleTile([Pip1 | [Pip2 | _]]) :-
    Pip1 = Pip2.


%**************************************************************
%Function Name: reverseTile
%Purpose: To reverse a tile
%Parameters:
%   Pip1   - left side of tile
%   Pip2   - right side of tile
%Return Value:  the reversed tile
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
reverseTile([Pip1 | [Pip2 | _ ]], [Pip2 , Pip1]).


%**************************************************************
%Function Name: insertAt
%Purpose: To insert a given tile at a given position
%Parameters:
%   Start - 0 (beginning of the list)
%   Index - the index that we want to insert at
%   Tile  - the tile to be inserted
%   Stock - the stock to which we are inserting
%Return Value:
%    The stock with the new tile
%Local Variables:
%   NewStart - keeping track of the level of recursion
%   First, Rest - First element and the Rest of the stock respectively
%Algorithm: Recursively loop to the index position and append the element at
%    the beginning. Leave the recursion to do its work on the way back,
%    bringing back the rest of the elements
%Assistance Received: None
%**************************************************************
insertAt(Start, Index, Tile, Stock, [Tile | Stock]) :-
    Start = Index.

insertAt(Start, Index, Tile, Stock, [First | RetVal]) :-
    Start \= Index,
    NewStart is Start + 1,
    [First | Rest] = Stock,
    insertAt(NewStart, Index, Tile, Rest, RetVal).


%**************************************************************
%Function Name: insert
%Purpose: A shorthand clause to insert a tile at the beginning of a collection
%Parameters:
%   Tile         - the tile to be inserted
%   Collection   - the collection to which we are inserting
%Return Value:
%    The collection with the new tile up front
%Local Variables: None
%Algorithm: None
%Assistance Received: None
%**************************************************************
insert(Tile, Collection, [Tile | Collection]).


%**************************************************************
%Function Name: removeFirstTile
%Purpose: To remove the first tile from the stock/hand
%Parameters:
%   Stock/Collection - the given stock/collection of tiles
%Return Value:
%    The collection without the first tile
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
removeFirstTile([ _ | Rest], Rest).


%**************************************************************
%Function Name: removeTile
%Purpose: To remove a given tile from the collection of tiles
%Parameters:
%   Tile       - the given tile to remove
%   Collection - the given collection to remove the tile from
%Return Value:
%    New collection with the given tile removed
%Local Variables:
%   First   - first tile from the collection
%   Rest    - remaining tiles from the collection
%Algorithm: Recursively iterate over the collection until First = Tile,
%           then simply return Rest and backtrack to get the other tiles
%Assistance Received: None 
%**************************************************************
removeTile(Tile, Collection, Rest) :-
    [First | Rest] = Collection,
    First = Tile.

removeTile(Tile, Collection, [First | RetVal]) :-
    [First | Rest] = Collection,
    removeTile(Tile, Rest, RetVal).


%**************************************************************
%Function Name: pipSum
%Purpose: To get the sum of a tile's pips
%Parameters:
%   Tile       - the given tile to calculate
%Return Value:
%   Sum of the tile's pips
%Local Variables:
%   Pip1, Pip2 - left and right pip respectively
%Algorithm: None
%Assistance Received: None 
%**************************************************************
pipSum(Tile, Sum) :-
    [Pip1 | [Pip2 | _ ]] = Tile,
    Sum is Pip1 + Pip2.