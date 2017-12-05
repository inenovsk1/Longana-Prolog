%************************************************************
%* Name:               Ivaylo Nenovski                      *
%* Project:            Longana Prolog                       *
%* Class:              CMPS 366-01                          *
%* Date:               12/08/2017                           *
%************************************************************





welcomeScreen :-
    write("+---------------------------------------------------------------------------------------------------------------------------+"), nl,
    write("|  _       __       __                                 __            __                                              __ __  |"), nl,
    write("| | |     / /___   / /_____ ____   ____ ___   ___     / /_ ____     / /   ____   ____   ____ _ ____ _ ____   ____ _ / // /  |"), nl,
    write("| | | /| / // _ \\ / // ___// __ \\ / __ `__ \\ / _ \\   / __// __ \\   / /   / __ \\ / __ \\ / __ `// __ `// __ \\ / __ `// // /   |"), nl,
    write("| | |/ |/ //  __// // /__ / /_/ // / / / / //  __/  / /_ / /_/ /  / /___/ /_/ // / / // /_/ // /_/ // / / // /_/ //_//_/    |") , nl,
    write("| |__/|__/ \\___//_/ \\___/ \\____//_/ /_/ /_/ \\___/   \\__/ \\____/  /_____/\\____//_/ /_/ \\__, / \\__,_//_/ /_/ \\__,_/(_)(_)     |"), nl,  
    write("|                                                                                    /____/                                 |"), nl,
    write("+---------------------------------------------------------------------------------------------------------------------------+"), nl,
    write("An easy Dominoes game! Ready to play?!"), nl.




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
initializeRound(Engine, Ret) :-
    Board = [],
    createStock(Stock),
    dealTilesAtRoundBeginning(0, 8, Stock, [], [], State),
    [HumanHand | [ComputerHand | [Stock | _ ]]] = State,
    %ask for serialization here
    placeEngine(Board, Stock, HumanHand, ComputerHand, Engine, Ret).



% Human has engine
placeEngine(Board, Stock, HumanHand, ComputerHand, Engine, Ret) :-
    SkipLastTurn = false,
    EngineTile = [Engine, Engine],
    containsTile(EngineTile, HumanHand),
    playLeft(Board, Stock, EngineTile, SkipLastTurn, Ret),
    %[Board, Stock, true]
    %FIX RETURN VALUE
    [Board | [Stock | _ ] = Ret.

% Computer has engine
placeEngine(Board, Stock, HumanHand, ComputerHand, Engine, Ret) :-
    SkipLastTurn = false,
    EngineTile = [Engine, Engine],
    containsTile(EngineTile, ComputerHand).
    %do playLeft with computer..

% Draw one tile each
placeEngine(Board, Stock, HumanHand, ComputerHand, Engine, Ret) :-
    SkipLastTurn = false.
    %dealtile


playRound(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, NextPlayer) :-
    



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
    write("Current Longana State:"), nl,
    write("Humman hand: "), write(HumanHand), nl,
    write("Computer hand: "), write(ComputerHand), nl,
    write("Stock: "), write(Stock), nl, nl.


% dummy function to test human play
placeTurn(Board, Stock, Hand, SkipLastTurn) :-
    selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction),
    humanPlay(Board, Stock, Hand, SelectedTile, Direction, SkipLastTurn, Ret),
    [NewBoard | _ ] = Ret,
    drawBoard(NewBoard).















%************************************************************************************************
%********************************** Strategies Implementation ***********************************
%************************************************************************************************


%**************************************************************
%Function Name: selectTile
%Purpose: To ask the user for a tile input
%Parameters:
%   Board          - current board
%   Hand           - player's hand
%   SkipLastTurn   - whether last turn was skipped or not
%Return Value: Either the selected tile, or if a tile was not available, then an empty list
%Local Variables:
%   TileToPlay     - user's input
%   AvailableTiles - the available tiles to play for the human
%Algorithm: If a move can be done, keep asking the user until a valid tile is inputted.
%           Otherwise, return an empty list.
%Assistance Received: None 
%**************************************************************
selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = true,
    not(hasOptionsWhenSkipped(Hand, Board)),
    SelectedTile = [],
    Direction = "".

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = false,
    not(hasNormalOptions(Hand, Board)),
    SelectedTile = [],
    Direction = "".

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = true,
    write("This is your current hand: "), write(Hand), nl,
    write("Please select a tile to play: "),
    read(SelectedTile),
    validTile(SelectedTile),
    containsTile(SelectedTile, Hand),
    anyAvailableTiles(Hand, Board, AvailableTiles),
    containsTile(SelectedTile, AvailableTiles),
    write("Please select a direction to play (0=Left, 1=Right): "),
    read(Direction),
    validateDirection(Direction).

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = false,
    write("This is your current hand: "), write(Hand), nl,
    write("Please select a tile to play: "),
    read(SelectedTile),
    validTile(SelectedTile),
    containsTile(SelectedTile, Hand),
    humanAvailableTiles(Hand, Board, AvailableTiles),
    containsTile(SelectedTile, AvailableTiles),
    write("Please select a direction to play (0=Left, 1=Right): "),
    read(Direction),
    validateDirection(Direction).

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    nl, write("Wrong tile! Please, try again! "), nl,
    selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction).



validateDirection(Direction) :-
    Direction = 0.

validateDirection(Direction) :-
    Direction = 1.



humanPlay(Board, Stock, HumanHand, TileToPlay, Direction, SkipLastTurn, Ret) :-
    SkipLastTurn = true,
    Direction = 0,
    not(TileToPlay = []),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the left!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

humanPlay(Board, Stock, HumanHand, TileToPlay, Direction, SkipLastTurn, Ret) :-
    SkipLastTurn = true,
    Direction = 1,
    not(TileToPlay = []),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the right!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

humanPlay(Board, Stock, HumanHand, TileToPlay, Direction, SkipLastTurn, Ret) :-
    SkipLastTurn = false,
    not(TileToPlay = []),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the left!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

humanPlay(Board, Stock, HumanHand, TileToPlay, Direction, SkipLastTurn, Ret) :-
    SkipLastTurn = false,
    not(TileToPlay = []),
    isDoubleTile(TileToPlay),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the right!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

% Last turn skipped -> try to play left
humanPlay(Board, Stock, HumanHand, [], "", SkipLastTurn, Ret) :-
    SkipLastTurn = true,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    removeTile(TileToPlay, NewHumanHand, HumanHandAfterPlay),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("No available moves! "), nl,
    write("You drew and played tile "), write(TileToPlay), write(" to the right!") nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, HumanHandAfterPlay, NewSkip].

% Last turn skipped -> try to play right
humanPlay(Board, Stock, HumanHand, [], "", SkipLastTurn, Ret) :-
    SkipLastTurn = true,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    removeTile(TileToPlay, NewHumanHand, HumanHandAfterPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("No available moves! "), nl,
    write("You drew and played tile "), write(TileToPlay), write(" to the left!") nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, HumanHandAfterPlay, NewSkip].

% Last turn NOT skipped -> try to play normally
humanPlay(Board, Stock, HumanHand, [], "", SkipLastTurn, Ret) :-
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    removeTile(TileToPlay, NewHumanHand, HumanHandAfterPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("No available moves! "), nl,
    write("You drew and played tile "), write(TileToPlay), write(" to the left!") nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, HumanHandAfterPlay, NewSkip].

% No move was available, therefore draw a tile and skip a turn
humanPlay(Board, Stock, HumanHand, [], "", SkipLastTurn, Ret) :-
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    [Drawn | _ ] = NewHumanHand,
    not(Drawn = []),
    write("You have no moves available even after drawing "), write(Drawn), nl,
    write("Skipping a turn.."), nl,
    Ret = [Board, NewStock, NewHumanHand, true].

humanPlay(Board, Stock, HumanHand, [], "", SkipLastTurn, Ret) :-
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    [Drawn | _ ] = NewHumanHand,
    Drawn = [],
    write("No moves available!"), nl,
    write("No more tiles left in stock.. Skipping turn.."), nl,
    Ret = [Board, Stock, HumanHand, true].


%**************************************************************
%Function Name: computerPlay
%Purpose: To either do a computer move, or to help the human
%Parameters:
%   Board           - The current board
%   Stock           - The current stock
%   Hand            - This parameter differs from when the predicate is called in help mode vs. normal mode.
%                     In help mode this is the human's hand, whereas in normal mode it is the computer's hand.
%   SkipLastTurn    - Whether last turn was skipped or not
%   Help            - Whether this predicate was called in help mode or not.
%Return Value:
%   A list of: new baord, new stock, new human/computer hand, whether turn was skipped or not
%Local Variables:
%   AvailableTiles           - the available tiles during this turn
%   AvailableTilesAfterDraw  - the available tiles after drawing from the stock
%   L                        - length of the available tiles
%   Len                      - length of the available tiles after a draw from the stock
%   TileToPlay               - the tile with the highest pip sum, chosen to be played
%   RecommendedTile          - if predicate in help mode, then this is the recomended tile to be played
%   NewStock                 - Stock after a tile has been drawn once
%   NewBoard                 - Board after a tile has been placed
%   Drawn                    - the drawn tile from the stock, if a tile was drawn
%Algorithm:
%   The strategy for the computer is to first find all available tiles that it can play,
%   and then to find the highest of those tiles according to pip sum. If there aren't any
%   available tiles, then draw a tile from stock and try to play it again. If none of the
%   above worked, then the computer skips a turn. The same strategy is used for the help mode.
%Assistance Received: None
%**************************************************************

% Help mode
computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, RecommendedTile),
    canPlayLeft(RecommendedTile, Board, NeedsReversal),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, RecommendedTile),
    canPlayRight(RecommendedTile, Board, NeedsReversal),
    isDoubleTile(RecommendedTile),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the right!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayLeft(RecommendedTile, Board, NeedsReversal),
    writeln("No moves available! Drawing from stock.."),
    write("You drew and can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayRight(RecommendedTile, Board, NeedsReversal),
    isDoubleTile(RecommendedTile),
    writeln("No moves available! Drawing from stock.."),
    write("You drew and can play tile "), write(RecommendedTile), write(" to the right!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewHumanHand,
    not(Drawn = []),
    writeln("No moves available! Drawing from stock.."),
    write("You drew tile "), write(Drawn), write(". Skipping a turn due to inability to play!"), nl,
    Ret = [Board, NewStock, NewHumanHand, true].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, RecommendedTile),
    canPlayLeft(RecommendedTile, Board, NeedsReversal),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, RecommendedTile),
    canPlayRight(RecommendedTile, Board, NeedsReversal),
    isDoubleTile(RecommendedTile),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the right!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayLeft(RecommendedTile, Board, NeedsReversal),
    writeln("No moves available! Drawing from stock.."),
    write("You drew and can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayRight(RecommendedTile, Board, NeedsReversal),
    isDoubleTile(RecommendedTile),
    writeln("No moves available! Drawing from stock.."),
    write("You drew and can play tile "), write(RecommendedTile), write(" to the right!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewHumanHand,
    not(Drawn = []),
    writeln("No moves available! Drawing from stock.."),
    write("You drew tile "), write(Drawn), write(". Skipping a turn due to inability to play!"), nl,
    Ret = [Board, NewStock, NewHumanHand, true].

% Normal case - computer play mode
computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, ComputerHand, NewComputerHand),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the right, because it was its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, NewComputerHand, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, ComputerHand, NewComputerHand),
    isDoubleTile(TileToPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the left, because it was a double tile and its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, NewComputerHand, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the right, because it was its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    isDoubleTile(TileToPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the left, because it was a double tile and its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewComputerHand,
    not(Drawn = []),
    write("Computer drew tile "), write(Drawn),
    write(" and skips a turn, because it was unable to play."), nl,
    Ret = [Board, NewStock, NewComputerHand, true].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, ComputerHand, NewComputerHand),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer played tile "), write(TileToPlay),
    write(" to the right, because it had highest pip count."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, NewComputerHand, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, ComputerHand, NewComputerHand),
    isDoubleTile(TileToPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer played tile "), write(TileToPlay),
    write(" to the left, because it had highest pip count."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, NewComputerHand, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the right, because it was its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    isDoubleTile(TileToPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the left, because it was a double tile and its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewComputerHand,
    not(Drawn = []),
    write("Computer drew tile "), write(Drawn),
    write(" and skips a turn, because it was unable to play."), nl,
    Ret = [Board, NewStock, NewComputerHand, true].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewComputerHand,
    Drawn = [],
    write("No moves available!"), nl,
    write("No more tiles left in stock.. Skipping turn.."), nl,
    Ret = [Board, Stock, ComputerHand, true].


%**************************************************************
%Function Name: playRight
%Purpose: To play a tile on the right side of the board
%Parameters:
%   Board         - current board
%   Stock         - current stock
%   TileToPlay    - the tile that is being placed on the board
%   SkipLastTurn  - Whether turn was skipped or not
%Return Value: A list containing new board, new stock and whether turn was skipped
%Local Variables:
%   L, Len          - length of the board
%   NeedsReversal   - whether the tile needs to be reversed or not
%   NewBoard        - the board after tile insertion
%Algorithm: Check if tile can be placed on the right, then if it should be reversed
%           or not. After that place it on the board
%Assistance Received: None 
%**************************************************************
playRight(Board, Stock, [], SkipLastTurn, [Board, Stock, true]).

playRight(Board, Stock, TileToPlay, SkipLastTurn, Ret) :-
    length(Board, Len),
    canPlayRight(TileToPlay, Board, NeedsReversal),
    NeedsReversal = false,  % If reverseal is needed, then backtrack and call the other case
    insertAt(0, Len, TileToPlay, Board, NewBoard),
    Ret = [NewBoard, Stock, false].

playRight(Board, Stock, TileToPlay, SkipLastTurn, Ret) :-
    length(Board, Len),
    reverseTile(TileToPlay, ReversedTile),
    canPlayRight(ReversedTile, Board, NeedsReversal),
    insertAt(0, Len, ReversedTile, Board, NewBoard),
    Ret = [NewBoard, Stock, false].


%**************************************************************
%Function Name: playLeft
%Purpose: To play a tile on the left side of the board
%Parameters:
%   Board         - current board
%   Stock         - current stock
%   TileToPlay    - the tile that is being placed on the board
%   SkipLastTurn  - Whether turn was skipped or not
%Return Value: A list containing new board, new stock and whether turn was skipped
%Local Variables:
%   L, Len          - length of the board
%   NeedsReversal   - whether the tile needs to be reversed or not
%   NewBoard        - the board after tile insertion
%Algorithm: Check if tile can be placed on the left, then if it should be reversed
%           or not. After that place it on the board
%Assistance Received: None 
%**************************************************************
playLeft(Board, Stock, [], SkipLastTurn, [Board, Stock, true]).

playLeft(Board, Stock, TileToPlay, SkipLastTurn, Ret) :-
    length(Board, Len),
    L is Len -1,
    canPlayLeft(TileToPlay, Board, NeedsReversal),
    NeedsReversal = false,  % If reverseal is needed, then backtrack and call the other case
    NewBoard = [TileToPlay | Board],
    Ret = [NewBoard, Stock, false].

playLeft(Board, Stock, TileToPlay, SkipLastTurn, Ret) :-
    length(Board, Len),
    L is Len -1,
    reverseTile(TileToPlay, ReversedTile),
    canPlayLeft(ReversedTile, Board, NeedsReversal),
    NewBoard = [ReversedTile | Board],
    Ret = [NewBoard, Stock, false].


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
    canPlayRight(Tile, Board, _ ),
    computerAvailableTiles(Rest, Board, AvailableTiles).

computerAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    isDoubleTile(Tile),
    canPlayLeft(Tile, Board, _ ),
    computerAvailableTiles(Rest, Board, AvailableTiles).

computerAvailableTiles(Hand, Board, AvailableTiles) :-
    [ _ | Rest] = Hand,
    computerAvailableTiles(Rest, Board, AvailableTiles).


%**************************************************************
%Function Name: humanAvailableTiles
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
    canPlayLeft(Tile, Board, _ ),
    humanAvailableTiles(Rest, Board, AvailableTiles).

humanAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    isDoubleTile(Tile),
    canPlayRight(Tile, Board, _ ),
    humanAvailableTiles(Rest, Board, AvailableTiles).

humanAvailableTiles(Hand, Board, AvailableTiles) :-
    [ _ | Rest] = Hand,
    humanAvailableTiles(Rest, Board, AvailableTiles).


%**************************************************************
%Function Name: anyAvailableTiles
%Purpose: To get the available tiles for any possible moves
%Parameters:
%   Hand    - caller's hand
%   Board   - the current board
%Return Value: A list of available tiles to be played on both ends
%Local Variables:
%   Tile     - first tile of caller's hand
%   Rest     - the rest of the caller's hand
%Algorithm:
%   If a tile can be played on either side of the board, then add it to the AvailableTiles
%Assistance Received: None 
%**************************************************************
anyAvailableTiles([], Board, []).

anyAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    canPlayLeft(Tile, Board, _ ),
    anyAvailableTiles(Rest, Board, AvailableTiles).

anyAvailableTiles(Hand, Board, [Tile | AvailableTiles]) :-
    [Tile | Rest] = Hand,
    canPlayRight(Tile, Board, _ ),
    anyAvailableTiles(Rest, Board, AvailableTiles).

anyAvailableTiles(Hand, Board, AvailableTiles) :-
    [ _ | Rest] = Hand,
    anyAvailableTiles(Rest, Board, AvailableTiles).


%**************************************************************
%Function Name: hasNormalOptions
%Purpose: To check if the human can do any moves.
%Parameters:
%   Hand    - caller's hand
%   Board   - the current board
%Return Value: true if moves are available, false otherwise.
%Local Variables:
%   First    - first tile of caller's hand
%   Rest     - the rest of the caller's hand
%Algorithm: Linearly check if any tile can be played.
%Assistance Received: None 
%**************************************************************
hasNormalOptions([], Board) :-
    false.

hasNormalOptions(Hand, Board) :-
    [First | Rest] = Hand,
    canPlayLeft(First, Board, _ ).

hasNormalOptions(Hand, Board) :-
    [First | Rest] = Hand,
    isDoubleTile(First),
    canPlayRight(First, Board, _ ).

hasNormalOptions(Hand, Board) :-
    [First | Rest] = Hand,
    hasNormalOptions(Rest, Board).


%**************************************************************
%Function Name: hasOptionsWhenSkipped
%Purpose: To check if the human can do any moves, when other player has skipped turn.
%Parameters:
%   Hand    - caller's hand
%   Board   - the current board
%Return Value: true if moves are available, false otherwise.
%Local Variables:
%   First    - first tile of caller's hand
%   Rest     - the rest of the caller's hand
%Algorithm: Linearly check if any tile can be played.
%Assistance Received: None 
%**************************************************************
hasOptionsWhenSkipped([], Board) :-
    false.

hasOptionsWhenSkipped(Hand, Board) :-
    [First | Rest] = Hand,
    canPlayLeft(First, Board, _ ).

hasOptionsWhenSkipped(Hand, Board) :-
    [First | Rest] = Hand,
    canPlayRight(First, Board, _ ).

hasOptionsWhenSkipped(Hand, Board) :-
    [First | Rest] = Hand,
    hasOptionsWhenSkipped(Rest, Board).


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
canPlayLeft(Tile, Board, NeedsReversal) :-
    [Pip1 | [Pip2 | _ ]] = Tile,
    [LeftTile | Rest] = Board,
    [BoardPip1 | _ ] = LeftTile,
    Pip2 = BoardPip1,
    NeedsReversal = false.

canPlayLeft(Tile, Board, NeedsReversal) :-
    reverseTile(Tile, ReversedTile),
    [Pip1 | [Pip2 | _ ]] = ReversedTile,
    [LeftTile | Rest] = Board,
    [BoardPip1 | _ ] = LeftTile,
    Pip2 = BoardPip1,
    NeedsReversal = true.


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
canPlayRight(Tile, Board, NeedsReversal) :-
    [Pip1 | [Pip2 | _ ]] = Tile,
    last(Board, RightTile),
    [BoardPip1 | [BoardPip2 | _ ]] = RightTile,
    Pip1 = BoardPip2,
    NeedsReversal = false.

canPlayRight(Tile, Board, NeedsReversal) :-
    reverseTile(Tile, ReversedTile),
    [Pip1 | [Pip2 | _ ]] = ReversedTile,
    last(Board, RightTile),
    [BoardPip1 | [BoardPip2 | _ ]] = RightTile,
    Pip1 = BoardPip2,
    NeedsReversal = true.


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
highestTile([], []).

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
%********************************** Board Draw Implementation ***********************************
%************************************************************************************************


%**************************************************************
%Function Name: drawDoubleTiles
%Purpose: To draw double tiles on the board
%Parameters:
%   Board   - current board for longana (list of all tiles)
%Return Value: None
%Local Variables:
%   First, Rest        - first tile and rest of the tiles on the board
%   Pip1               - one of the pips on the double tile
%Algorithm: Print one side of the double tile followed by a space, if tile is not
%           double, then print 4 spaces.
%Assistance Received: None 
%**************************************************************
drawDoubleTiles([]).

drawDoubleTiles(Board) :-
    [First | Rest] = Board,
    isDoubleTile(First),
    [Pip1 | _ ] = First,
    write(Pip1), write(" "),
    drawDoubleTiles(Rest).

drawDoubleTiles(Board) :-
    [ _ | Rest] = Board,
    write("    "),
    drawDoubleTiles(Rest).


%**************************************************************
%Function Name: drawSingleTiles
%Purpose: To draw single tiles on the board
%Parameters:
%   Board   - current board for longana (list of all tiles)
%Return Value: None
%Local Variables:
%   First, Rest        - first tile and rest of the tiles on the board
%   Pip1, Pip2         - left and right pip respectively of tile First (the one that is being drawn)
%Algorithm: Print the tile as is with a space at the end. If tile is double just print a bar followed by
%           a space. This bar will connect the double tiles
%Assistance Received: None 
%**************************************************************
drawSingleTiles([]).

drawSingleTiles(Board) :-
    [First | Rest] = Board,
    isDoubleTile(First),
    write("| "),
    drawSingleTiles(Rest).

drawSingleTiles(Board) :-
    [First | Rest] = Board,
    [Pip1 | [Pip2 | _ ]] = First,
    write(Pip1), write("-"), write(Pip2), write(" "),
    drawSingleTiles(Rest).


%**************************************************************
%Function Name: drawBoard
%Purpose: To draw the board on the screen
%Parameters:
%   Board   - current board for longana (list of all tiles)
%Return Value: None
%Local Variables: None
%Algorithm: Draw in order double tiles, then single tiles , then again double tiles.
%           The code for the 2 predicates used takes care of displaying everything correctly.
%Assistance Received: None 
%**************************************************************
drawBoard(Board) :-
    write("***********************************************************************************************"), nl,
    write("***********************************************************************************************"), nl,
    drawDoubleTiles(Board), nl,
    drawSingleTiles(Board), nl,
    drawDoubleTiles(Board), nl,
    write("***********************************************************************************************"), nl,
    write("***********************************************************************************************"), nl.
















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
removeFirstTile([], []).
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
removeTile([], Collection, Collection).

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


%**************************************************************
%Function Name: containsTile
%Purpose: To determine whether the given hand contains the given tile
%Parameters:
%   TileToPlay       - the given tile that we are checking
%Return Value: true if tile is in hand, false otherwise
%Local Variables:
%   First, Rest      - First tile in hand, Rest of the tiles in hand
%Algorithm: None
%Assistance Received: None 
%**************************************************************
containsTile(TileToPlay, []) :-
    false.

containsTile(TileToPlay, Hand) :-
    [First | Rest] = Hand,
    First = TileToPlay.

containsTile(TileToPlay, Hand) :-
    [First | Rest] = Hand,
    reverseTile(First, ReversedTile),
    ReversedTile = TileToPlay.

containsTile(TileToPlay, Hand) :-
    [First | Rest] = Hand,
    containsTile(TileToPlay, Rest).