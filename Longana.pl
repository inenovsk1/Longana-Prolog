%************************************************************
%* Name:               Ivaylo Nenovski                      *
%* Project:            Longana Prolog                       *
%* Class:              CMPS 366-01                          *
%* Date:               12/08/2017                           *
%************************************************************





splashScreen :-
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
%********************************* Serialization Implementation *********************************
%************************************************************************************************


%**************************************************************
%Function Name: promptToLoadFromFile
%Purpose: To validate user input at the beginning of Longana
%Parameters: None
%Return Value: 0 or 1 depending on whether the user wants a new game or to load from file
%Local Variables:
%   X      - the user's input
%Algorithm: None
%Assistance Received: None 
%**************************************************************
promptToLoadFromFile(Ans) :-
    write("Would you like to load a game from a file(1) or start a new one(0) ? "),
    read(X),
    validatePromptFromFile(X),
    Ans = X.

validatePromptFromFile(Input) :-
    Input = 0.

validatePromptFromFile(Input) :-
    Input = 1.



%**************************************************************
%Function Name: readFile
%Purpose: To read the contents of a file
%Parameters:
%   FileName     - name of the file to be read from
%Return Value:  A list with the contents of the read file
%Local Variables:
%   Stream      - the opened file that this predicate is reading from
%Algorithm:
%    Change to the working directory, read the contents of the specified file and save them
%    into the list 'Contents'
%Assistance Received: None 
%**************************************************************
readFile(FileName, Contents) :-
    working_directory(_, 'C:\\ivo\\programming\\Fall17\\OPL\\prolog\\Longana-Prolog'),
    open(FileName, read, Stream),
    read(Stream, Contents),
    close(Stream).



%**************************************************************
%Function Name: parseFile
%Purpose: To parse the given file and split it into individual parameters that would
%         be later given to a tournament instance of longana
%Parameters:
%   Contents     - the contents of the file that was read
%Return Value:
%   All of the next parameters given are values to be returned by this function
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
parseFile(Contents, TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, Board,
          Stock, SkipLastTurn, NextPlayer) :-
    length(Contents, L),
    L = 9,     % this means that no nextPlayer was given
    [TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, Board, Stock,
    SkipLastTurn | _ ] = Contents,
    NextPlayer = -1.

parseFile(Contents, TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, Board,
          Stock, SkipLastTurn, NextPlayer) :-
    length(Contents, L),
    L = 10,     % this means that no nextPlayer was given
    [TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, Board, Stock,
    SkipLastTurn, NextPlayer | _ ] = Contents.




%**************************************************************
%Function Name: determineEngineFromRound
%Purpose: To determine the engine from the given round number
%Parameters:
%   RoundNo      - the given round number
%Return Value:
%   The corresponding engine for that round number
%Local Variables:
%   NewRound     - if the round is a big number, then mod it by 7 and store the result here
%   ActualRound  - add 1 to the NewRound to get into the proper bounds
%Algorithm:
%   7 base cases for rounds 1 through 7. If round is bigger than 7, then mod the round by 7
%   and add 1 so that you can back to the proper bounds. Then determine the engine from the base cases
%Assistance Received: None 
%**************************************************************
determineEngineFromRound(1, 6).
determineEngineFromRound(2, 5).
determineEngineFromRound(3, 4).
determineEngineFromRound(4, 3).
determineEngineFromRound(5, 2).
determineEngineFromRound(6, 1).
determineEngineFromRound(7, 0).

determineEngineFromRound(RoundNo, Engine) :-
    RoundNo >= 7,
    NewRound is RoundNo mod 7,
    ActualRound is NewRound + 1,
    determineEngineFromRound(ActualRound, Engine).


%**************************************************************
%Function Name: initiateGameFromFile
%Purpose: To properly load a game from a file depending on the data given
%Parameters:
%   File       - the given file name
%Return Value: None
%Local Variables:
%   Contents               - contents of the given file
%   Tgoal                  - the given tournament goal
%   RoundNo                - given round number
%   ComputerHand           - given computer hand
%   ComputerScore          - given computer score
%   HumanHand              - given human hand
%   HumanScore             - given human score
%   Board                  - given board in format [l, tiles...., r].
%   ParsedBoard            - parsed board without the 'l r' elements 
%   Stock                  - given stock
%   SkipLastTurn           - whether last turn was skipped or not
%   NextPlayer             - given next player
%Algorithm:
%   Load the data from a given file and determine whether a new round needs to be started or an old one continued.
%   Then handle the cases for each occurence
%Assistance Received: None 
%**************************************************************
initiateGameFromFile(File) :-
    readFile(File, Contents),
    parseFile(Contents, TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, Board, Stock, SkipLastTurn, NextPlayer),
    determineEngineFromRound(RoundNo, Engine),
    NextPlayer = 'computer',
    NewNextPlayer = 1,
    determineBoardFromFile(Board, ParsedBoard),
    roundLoop(ParsedBoard, Stock, HumanHand, ComputerHand, SkipLastTurn, 0, NewNextPlayer, false, RoundResult),
    continueTournament(RoundResult, HumanScore, ComputerScore, TGoal, Engine).

initiateGameFromFile(File) :-
    readFile(File, Contents),
    parseFile(Contents, TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, Board, Stock, SkipLastTurn, NextPlayer),
    determineEngineFromRound(RoundNo, Engine),
    NextPlayer = 'human',
    NewNextPlayer = 0,
    determineBoardFromFile(Board, ParsedBoard),
    roundLoop(ParsedBoard, Stock, HumanHand, ComputerHand, SkipLastTurn, 0, NewNextPlayer, true, RoundResult),
    continueTournament(RoundResult, HumanScore, ComputerScore, TGoal, Engine).

initiateGameFromFile(File) :-
    readFile(File, Contents),
    parseFile(Contents, TGoal, RoundNo, ComputerHand, ComputerScore, HumanHand, HumanScore, _, Stock, _, NextPlayer),
    determineEngineFromRound(RoundNo, Engine),
    NextPlayer = -1,
    placeEngine([], Stock, HumanHand, ComputerHand, Engine, Ret),
    [BoardAfterEngine | [StockAfterEngine | [HumanHandAfterEngine | [ComputerHandAfterEngine | [SkipAfterEngine | [NewNextPlayer | _ ]]]]]] = Ret,
    drawBoard(BoardAfterEngine),
    printState(HumanHandAfterEngine, ComputerHandAfterEngine, StockAfterEngine),
    roundLoop(BoardAfterEngine, StockAfterEngine, HumanHandAfterEngine, ComputerHandAfterEngine,
              SkipAfterEngine, 0, NewNextPlayer, true, RoundResult),
    continueTournament(RoundResult, HumanScore, ComputerScore, TGoal, Engine).


%**************************************************************
%Function Name: determineBoardFromFile
%Purpose: To parse the board from a given file
%Parameters: None
%Return Value: The parsed board
%Local Variables:
%   First      - first element of the board
%   Rest       - the rest of the board
%Algorithm:
%   Go through the board tile by tile and if the tile is either 'l' or 'r', then discard it
%Assistance Received: None 
%**************************************************************
determineBoardFromFile([], []).

determineBoardFromFile(Board, [First | Res]) :-
    [First | Rest] = Board,
    First \= l,
    First \= r,
    determineBoardFromFile(Rest, Res).

determineBoardFromFile(Board, ParsedBoard) :-
    [ _ | Rest] = Board,
    determineBoardFromFile(Rest, ParsedBoard).




%************************************************************************************************
%*********************************** Tournament Implementation **********************************
%************************************************************************************************


%**************************************************************
%Function Name: longana
%Purpose: Main Longana entry. Perform the whole game with this predicate
%Parameters: None
%Return Value: None
%Local Variables:
%   TGoal      - The goal of the tournament
%Algorithm: None
%Assistance Received: None 
%**************************************************************
longana() :-
    splashScreen(),
    promptToLoadFromFile(Ans),
    Ans = 1,
    write("Please enter file name: "),
    read(File),
    initiateGameFromFile(File).

longana() :-
    promptTournamentScore(TGoal),
    tournamentLoop(TGoal, 0, 0, 6).


%**************************************************************
%Function Name: promptTournamentScore
%Purpose: To ask the user for tournament goal
%Parameters: None
%Return Value: The inputted goal by the user
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
promptTournamentScore(TGoal) :-
    write("Please enter tournament goal for Longana: "),
    read(TGoal),
    validateTGoal(TGoal).

promptTournamentScore(TGoal) :-
    write("Tournament goal cannot be a negative number!"), nl,
    promptTournamentScore(TGoal).

validateTGoal(TGoal) :-
    TGoal > 0.



%**************************************************************
%Function Name: tournamentLoop
%Purpose: To keep the tournament alive until someone wins
%Parameters:
%   TournamentGoal
%   HumanScore
%   ComputerScore
%   Engine
%Return Value: None
%Local Variables:
%   NewHumanScore        - human score after a round win
%   NewComputerScore     - computer score after a round win
%   NewEngine            - updated engine for next round
%Algorithm: None
%Assistance Received: None 
%**************************************************************
tournamentLoop(TournamentGoal, HumanScore, ComputerScore, Engine) :-
    startNewRound(Engine, RoundResult),
    continueTournament(RoundResult, HumanScore, ComputerScore, TournamentGoal, Engine).



continueTournament(RoundResult, HumanScore, ComputerScore, TournamentGoal, _) :-
    [Winner | [Score | _ ]] = RoundResult,
    Winner = 0,
    NewHumanScore is HumanScore + Score,
    endTournamentGoalsMet(NewHumanScore, ComputerScore, TournamentGoal).

continueTournament(RoundResult, HumanScore, ComputerScore, TournamentGoal, _) :-
    [Winner | [Score | _ ]] = RoundResult,
    Winner = 1,
    NewComputerScore is ComputerScore + Score,
    endTournamentGoalsMet(HumanScore, NewComputerScore, TournamentGoal).

continueTournament(RoundResult, HumanScore, ComputerScore, TournamentGoal, Engine) :-
    [Winner | [Score | _ ]] = RoundResult,
    Winner = 0,
    NewHumanScore is HumanScore + Score,
    changeEngine(Engine, NewEngine),
    nl, write("Current score:"), nl,
    write("Human: "), write(NewHumanScore), nl,
    write("Computer: "), write(ComputerScore), nl, nl,
    tournamentLoop(TournamentGoal, NewHumanScore, ComputerScore, NewEngine).

continueTournament(RoundResult, HumanScore, ComputerScore, TournamentGoal, Engine) :-
    [Winner | [Score | _ ]] = RoundResult,
    Winner = 1,
    NewComputerScore is ComputerScore + Score,
    changeEngine(Engine, NewEngine),
    nl, write("Current score:"), nl,
    write("Human: "), write(HumanScore), nl,
    write("Computer: "), write(NewComputerScore), nl, nl,
    tournamentLoop(TournamentGoal, HumanScore, NewComputerScore, NewEngine).

continueTournament(RoundResult, HumanScore, ComputerScore, TournamentGoal, Engine) :-
    [Winner | _ ] = RoundResult,
    Winner = -1,
    write("Stalemate! No one wins this round! Better luck next time!"), nl,
    changeEngine(Engine, NewEngine),
    nl, write("Current score:"), nl,
    write("Human: "), write(HumanScore), nl,
    write("Computer: "), write(ComputerScore), nl, nl,
    tournamentLoop(TournamentGoal, HumanScore, ComputerScore, NewEngine).



%**************************************************************
%Function Name: endTournamentGoalsMet
%Purpose: To determine if the tournament is over and to announce the winner
%Parameters:
%   HumanScore
%   ComputerScore
%   TournamentGoal
%Return Value: None
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
endTournamentGoalsMet(HumanScore, ComputerScore, TournamentGoal) :-
    HumanScore >= TournamentGoal,
    write("Final score:"), nl,
    write("Human: "), write(HumanScore), nl,
    write("Computer: "), write(ComputerScore), nl,
    write("Human wins the tournament!"), nl.

endTournamentGoalsMet(HumanScore, ComputerScore, TournamentGoal) :-
    ComputerScore >= TournamentGoal,
    write("Final score:"), nl,
    write("Human: "), write(HumanScore), nl,
    write("Computer: "), write(ComputerScore), nl,
    write("Computer wins the tournament!"), nl.



%**************************************************************
%Function Name: chageEngine
%Purpose: To properly update the engine for the next round
%Parameters:
%   HumanScore
%   ComputerScore
%   TournamentGoal
%Return Value: None
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
changeEngine(0, 6).

changeEngine(Engine, NewEngine) :-
    NewEngine is Engine - 1.




%************************************************************************************************
%************************************ Round Implementation **************************************
%************************************************************************************************


%**************************************************************
%Function Name: startNewRound
%Purpose: To play a new round, until the round is finished
%Parameters:
%   Engine      - the engine for the round to be played
%Return Value: List of the winner, and the winner's score
%Local Variables:
%   Board           - Board after round initialization
%   Stock           - Stock after round initialization
%   HumanHand       - Human hand after round initialization
%   ComputerHand    - Computer hand after round initialization
%   SkipLastTurn    - Skip turn after round initialization
%   NextPlayer      - Next player after round initialization
%Algorithm: None
%Assistance Received: None 
%**************************************************************
startNewRound(Engine, Ret) :-
    initializeRound(Engine, InitializationResult),
    [Board | [Stock | [HumanHand | [ComputerHand | [SkipLastTurn | [NextPlayer | _]]]]]] = InitializationResult,
    roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, 0, NextPlayer, 1, Ret).



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
    createStock(Stock),
    dealTilesAtRoundBeginning(0, 8, Stock, [], [], State),
    [HumanHand | [ComputerHand | [StockAfterDeal | _ ]]] = State,
    printState(HumanHand, ComputerHand, StockAfterDeal),
    %ask for serialization here
    placeEngine([], StockAfterDeal, HumanHand, ComputerHand, Engine, Ret),
    [Board | [StockAfterEngine | [HumanHandAfterEngine | [ComputerHandAfterEngine | _ ]]]] = Ret,
    drawBoard(Board),
    printState(HumanHandAfterEngine, ComputerHandAfterEngine, StockAfterEngine).




%**************************************************************
%Function Name: placeEngine
%Purpose: To place the engine on the board
%Parameters:
%   Board         - current board
%   Stock         - current stock
%   HumanHand     - current human's hand
%   ComputerHand  - current computer's hand
%   EngStockAfterDealine        - the engine for the current round, passed as an integer
%Return Value: List containing NewBoard, NewStock, HumanHand, ComputerHand, lastTurnSkipped and nextPlayer
%              Note* when it comes to nextPlayer field - 0 means  human, 1 means computer.
%Local Variables:
%   EngineTile                 - the engine tile for the round
%   NewBoard                   - board after drawing tiles 
%   NewHumanHand               - human hand after drawing a tile
%   NewComputerHand            - computer hand after drawing a tile
%   NewStock/StockAfterDraw    - the stock after human/computer draw a tile respectively
%Algorithm: If one of the players has the engine, place it. Else, keep drawing a tile each
%           until someone is in posession of the engine tile.
%Assistance Received: None 
%**************************************************************
% Human has engine
placeEngine([], Stock, HumanHand, ComputerHand, Engine, Ret) :-
    EngineTile = [Engine, Engine],
    containsTile(EngineTile, HumanHand),
    NewBoard = [EngineTile],
    removeTile(EngineTile, HumanHand, NewHumanHand),
    write("Human placed engine on board!"), nl,
    Ret = [NewBoard, Stock, NewHumanHand, ComputerHand, false, 1].

% Computer has engine
placeEngine([], Stock, HumanHand, ComputerHand, Engine, Ret) :-
    EngineTile = [Engine, Engine],
    containsTile(EngineTile, ComputerHand),
    NewBoard = [EngineTile],
    removeTile(EngineTile, ComputerHand, NewComputerHand),
    write("Computer placed engine on board!"), nl,
    Ret = [NewBoard, Stock, HumanHand, NewComputerHand, false, 0].

% Draw one tile each
placeEngine(Board, Stock, HumanHand, ComputerHand, Engine, Ret) :-
    write("No one had the engine! Each player is drawing a tile from the stock"), nl,
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    [HumanDrawn | _ ] = NewHumanHand,
    write("Human got tile "), write(HumanDrawn), nl,
    dealTile(NewStock, ComputerHand, NewComputerHand),
    removeFirstTile(NewStock, StockAfterDeal),
    [ComputerDrawn | _ ] = NewComputerHand,
    write("Computer got tile "), write(ComputerDrawn), nl,
    placeEngine(Board, StockAfterDeal, NewHumanHand, NewComputerHand, Engine, Ret).



%**************************************************************
%Function Name: roundLoop
%Purpose: To perform a single round of Longana
%Parameters:
%   Board           - Longana's board
%   Stock           - Longana's stock
%   HumanHand       - Human's hand
%   ComputerHand    - Computer's hand
%   SkipLastTurn    - Whether last turn was skipped or not
%   AmountOfSkips   - how many previous turns in a roll were skipped
%   NextPlayer      - 0 - human's next, 1 - computer's next
%Return Value: A list containing the winner of the round and the score that they get awarded
%Local Variables:
%   HelpRet             - return value of the help mode
%   BoardAfterHelp      - the board after help
%   StockAfterHelp      - the stock after help
%   HumanHandAfterHelp  - human hand after help
%   SkipAfterHelp       - whether the help mode suggested skipping a turn
%   NewBoard            - board after a player's turn
%   NewStock            - stock after a player's turn
%   NewHumanHand        - human's hand after a human's turn
%   NewComputerHand     - computer's hand after a computer's turn
%Algorithm: None
%Assistance Received: None 
%**************************************************************

% help mode and can play tiles
roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, AmountOfSkips, NextPlayer, Help, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 0,
    SkipLastTurn = true,
    [TestDrawn | _ ] = Stock,
    TestHumanHand = [TestDrawn | HumanHand],
    anyAvailableTiles(TestHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L \= 0,
    Help = 1,
    computerPlay(Board, Stock, HumanHand, SkipLastTurn, true, HelpRet),
    [BoardAfterHelp | [StockAfterHelp | [HumanHandAfterHelp | [SkipAfterHelp | _ ]]]] = HelpRet,
    SkipAfterHelp \= true,
    selectTile(BoardAfterHelp, HumanHandAfterHelp, SkipLastTurn, SelectedTile, Direction),
    humanPlay(BoardAfterHelp, StockAfterHelp, HumanHandAfterHelp, SelectedTile, Direction, SkipLastTurn, true, Ret),
    [NewBoard | [NewStock | [NewHumanHand | [NewSkip | _ ]]]] = Ret,
    increaseAmountOfSkips(NewSkip, AmountOfSkips, NewAmountOfSkips),
    drawBoard(NewBoard),
    printState(NewHumanHand, ComputerHand, NewStock),
    roundLoop(NewBoard, NewStock, NewHumanHand, ComputerHand, NewSkip, NewAmountOfSkips, 1, _, RoundResult).

roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, AmountOfSkips, NextPlayer, Help, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 0,
    SkipLastTurn = false,
    [TestDrawn | _ ] = Stock,
    TestHumanHand = [TestDrawn | HumanHand],
    humanAvailableTiles(TestHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L \= 0,
    Help = 1,
    computerPlay(Board, Stock, HumanHand, SkipLastTurn, true, HelpRet),
    [BoardAfterHelp | [StockAfterHelp | [HumanHandAfterHelp | [SkipAfterHelp | _ ]]]] = HelpRet,
    SkipAfterHelp \= true,
    selectTile(BoardAfterHelp, HumanHandAfterHelp, SkipLastTurn, SelectedTile, Direction),
    humanPlay(BoardAfterHelp, StockAfterHelp, HumanHandAfterHelp, SelectedTile, Direction, SkipLastTurn, true, Ret),
    [NewBoard | [NewStock | [NewHumanHand | [NewSkip | _ ]]]] = Ret,
    increaseAmountOfSkips(NewSkip, AmountOfSkips, NewAmountOfSkips),
    drawBoard(NewBoard),
    printState(NewHumanHand, ComputerHand, NewStock),
    roundLoop(NewBoard, NewStock, NewHumanHand, ComputerHand, NewSkip, NewAmountOfSkips, 1, _, RoundResult).    

% no help mode but can play tiles
roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, AmountOfSkips, NextPlayer, Help, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 0,
    SkipLastTurn = true,
    [TestDrawn | _ ] = Stock,
    TestHumanHand = [TestDrawn | HumanHand],
    anyAvailableTiles(TestHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L \= 0,
    Help = 1,
    computerPlay(Board, Stock, HumanHand, SkipLastTurn, true, _),
    selectTile(Board, HumanHand, SkipLastTurn, SelectedTile, Direction),
    humanPlay(Board, Stock, HumanHand, SelectedTile, Direction, SkipLastTurn, false, Ret),
    [NewBoard | [NewStock | [NewHumanHand | [NewSkip | _ ]]]] = Ret,
    increaseAmountOfSkips(NewSkip, AmountOfSkips, NewAmountOfSkips),
    drawBoard(NewBoard),
    printState(NewHumanHand, ComputerHand, NewStock),
    roundLoop(NewBoard, NewStock, NewHumanHand, ComputerHand, NewSkip, NewAmountOfSkips, 1, _, RoundResult).

roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, AmountOfSkips, NextPlayer, Help, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 0,
    SkipLastTurn = false,
    [TestDrawn | _ ] = Stock,
    TestHumanHand = [TestDrawn | HumanHand],
    humanAvailableTiles(TestHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L \= 0,
    Help = 1,
    computerPlay(Board, Stock, HumanHand, SkipLastTurn, true, _),
    selectTile(Board, HumanHand, SkipLastTurn, SelectedTile, Direction),
    humanPlay(Board, Stock, HumanHand, SelectedTile, Direction, SkipLastTurn, false, Ret),
    [NewBoard | [NewStock | [NewHumanHand | [NewSkip | _ ]]]] = Ret,
    increaseAmountOfSkips(NewSkip, AmountOfSkips, NewAmountOfSkips),
    drawBoard(NewBoard),
    printState(NewHumanHand, ComputerHand, NewStock),
    roundLoop(NewBoard, NewStock, NewHumanHand, ComputerHand, NewSkip, NewAmountOfSkips, 1, _, RoundResult).

% last turn was skipped, therefore continue the game
roundLoop(Board, Stock, HumanHand, ComputerHand, _, AmountOfSkips, NextPlayer, _, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 0,
    Stock \= [],
    dealTile(Stock, HumanHand, NewHumanHand),
    removeFirstTile(Stock, NewStock),
    NewAmountOfSkips is AmountOfSkips + 1,
    [Drawn | _ ] = NewHumanHand,
    write("No moves available.. Drawing from stock"), nl,
    write("Drew tile "), write(Drawn), write(". Skipping a turn due to no moves available!"), nl, nl,
    drawBoard(Board),
    printState(NewHumanHand, ComputerHand, NewStock),
    roundLoop(Board, NewStock, NewHumanHand, ComputerHand, true, NewAmountOfSkips, 1, _, RoundResult).

% Human turn without help
roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, AmountOfSkips, NextPlayer, _, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 0,
    selectTile(Board, HumanHand, SkipLastTurn, SelectedTile, Direction),
    humanPlay(Board, Stock, HumanHand, SelectedTile, Direction, SkipLastTurn, false, Ret),
    [NewBoard | [NewStock | [NewHumanHand | [NewSkip | _ ]]]] = Ret,
    increaseAmountOfSkips(SkipLastTurn, AmountOfSkips, NewAmountOfSkips),
    drawBoard(NewBoard),
    printState(NewHumanHand, ComputerHand, NewStock),
    roundLoop(NewBoard, NewStock, NewHumanHand, ComputerHand, NewSkip, NewAmountOfSkips, 1, _, RoundResult).

% Computer turn
roundLoop(Board, Stock, HumanHand, ComputerHand, SkipLastTurn, AmountOfSkips, NextPlayer, _, RoundResult) :-
    not(endOfRoundConditionsMet(Stock, HumanHand, ComputerHand, AmountOfSkips)),
    NextPlayer = 1,
    computerPlay(Board, Stock, ComputerHand, SkipLastTurn, false, Ret),
    [NewBoard | [NewStock | [NewComputerHand | [NewSkip | _ ]]]] = Ret,
    increaseAmountOfSkips(NewSkip, AmountOfSkips, NewAmountOfSkips),
    drawBoard(NewBoard),
    printState(HumanHand, NewComputerHand, NewStock),
    askForHelp(HelpModeHuman),
    roundLoop(NewBoard, NewStock, HumanHand, NewComputerHand, NewSkip, NewAmountOfSkips, 0, HelpModeHuman, RoundResult).

% Announce winners and put the winner score and winner player in RoundResult
roundLoop(_, Stock, HumanHand, ComputerHand, _, AmountOfSkips, _, _, RoundResult) :-
    determineWinner(HumanHand, ComputerHand, Stock, AmountOfSkips, Winner, PointsWon),
    RoundResult = [Winner, PointsWon].


%**************************************************************
%Function Name: determineWinner
%Purpose: To determine who the winner of the round is
%Parameters:
%   HumanHand
%   ComputerHand
%   Stock
%   AmountOfSkips
%Return Value: It returns into the parameters Winner and PointsWon respectively the winner
%              of the round and the amount of points awarded. 0 = human wins; 1 = computer wins
%Local Variables:
%   HumanSum      - pip sum of human's hand
%   ComputerSum   - pip sum of computer's hand
%Algorithm: None
%Assistance Received: None 
%**************************************************************
% human wins, because emptied hand first
determineWinner(HumanHand, ComputerHand, _, _, Winner, PointsWon) :-
    HumanHand = [],
    handSum(ComputerHand, 0, PointsWon),
    Winner = 0,
    write("Human emptied hand first, therefore human wins!"), nl.

% computer wins, because emptied hand first
determineWinner(HumanHand, ComputerHand, _, _, Winner, PointsWon) :-
    ComputerHand = [],
    handSum(HumanHand, 0, PointsWon),
    Winner = 1,
    write("Computer emptied hand first, therefore computer wins!"), nl.

% stalemate in which human has more pips and therefore computer wins
determineWinner(HumanHand, ComputerHand, Stock, AmountOfSkips, Winner, PointsWon) :-
    AmountOfSkips >= 2,
    Stock = [],
    handSum(HumanHand, 0, HumanSum),
    handSum(ComputerHand, 0, ComputerSum),
    HumanSum > ComputerSum,
    PointsWon = HumanSum,
    Winner = 1,
    write("Amount of skips >= 2 and Computer has less pip count in hand, therefore Computer wins!"), nl.

% stalemate in which computer has more pips and therefore human wins
determineWinner(HumanHand, ComputerHand, Stock, AmountOfSkips, Winner, PointsWon) :-
    AmountOfSkips >= 2,
    Stock = [],
    handSum(HumanHand, 0, HumanSum),
    handSum(ComputerHand, 0, ComputerSum),
    HumanSum < ComputerSum,
    PointsWon = ComputerSum,
    Winner = 0,
    write("Amount of skips >= 2 and Human has less pip count in hand, therefore Human wins!"), nl.

% stalemate in which each player has the same amount of pip and therefore neither wins
determineWinner(HumanHand, ComputerHand, Stock, AmountOfSkips, Winner, PointsWon) :-
    AmountOfSkips >= 2,
    Stock = [],
    handSum(HumanHand, 0, HumanSum),
    handSum(ComputerHand, 0, ComputerSum),
    HumanSum = ComputerSum,
    PointsWon = 0,
    Winner = -1,
    write("Amount of skips >= 2 pip counts in each hand are equal, therefore stalemate! No one wins this round.."), nl.



%**************************************************************
%Function Name: endOfRoundConditionsMet
%Purpose: To determine whether the round has finished or not
%Parameters:
%   human hand, computer hand, and amount of previous turns skipped
%Return Value: true if round should end, false otherwise
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
endOfRoundConditionsMet(_, HumanHand, _, _) :-
    length(HumanHand, L),
    L = 0.

endOfRoundConditionsMet(_, _, ComputerHand, _) :-
    length(ComputerHand, L),
    L = 0.

endOfRoundConditionsMet(Stock, _, _, AmountOfSkips) :-
    AmountOfSkips >= 2,
    Stock = [].


%**************************************************************
%Function Name: increaseAmountOfSkips
%Purpose: To increase the amount of skips if last turn was skipped
%Parameters:
%   SkipLastTurn      - whether last turn was skipped or not
%   CurrentSkips      - the current amount of previous skipped rounds (in a roll)
%Return Value: if skipLastTurn is true, then return CurrentSkips + 1, else return CurrentSkips
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
increaseAmountOfSkips(false, _, NewAmountOfSkips) :-
    NewAmountOfSkips = 0.

increaseAmountOfSkips(SkipLastTurn, CurrentSkips, NewAmountOfSkips) :-
    SkipLastTurn = true,
    NewAmountOfSkips is CurrentSkips + 1.


%**************************************************************
%Function Name: askForHelp
%Purpose: To ask for help
%Parameters: None
%Return Value: 0 if no help mode wanted, 1 if help mode wanted
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
askForHelp(Help) :-
    write("Would you like help for your turn? (0 - no, 1 - yes): "),
    read(Help),
    validateHelpMode(Help).

askForHelp(Help) :-
    write("Invalid help input! Try again!"), nl,
    askForHelp(Help).


%**************************************************************
%Function Name: validateHelpMode
%Purpose: To make sure that help mode is within the expected bounds
%Parameters:
%   HelpMode     - the inputted value for the help mode
%Return Value: true if round should end, false otherwise
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
validateHelpMode(Help) :-
    Help = 1.

validateHelpMode(Help) :- 
    Help = 0.



%**************************************************************
%Function Name: printState
%Purpose: To print the current state of Longana, i.e. human hand, computer hand, stock
%Parameters:
%   human hand, computer hand, and stock
%Return Value: None
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
printState(HumanHand, ComputerHand, Stock) :-
    write("Current Longana State:"), nl,
    write("Human hand: "), write(HumanHand), nl,
    write("Computer hand: "), write(ComputerHand), nl,
    write("Stock: "), write(Stock), nl, nl.















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
%Return Value:
%   Either the selected tile, or if a tile was not available, then an empty list
%   This function also returns the desired direction to which the tile should be played
%Local Variables:
%   AvailableTiles - the available tiles to play for the human
%Algorithm: If a move can be done, keep asking the user until a valid tile is inputted.
%           Otherwise, return an empty list for SelectedTile and an empty string for Direction
%Assistance Received: None 
%**************************************************************
selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = true,
    not(hasOptionsWhenSkipped(Hand, Board)),
    SelectedTile = [],
    Direction = -1.

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = false,
    not(hasNormalOptions(Hand, Board)),
    SelectedTile = [],
    Direction = -1.

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = true,
    write("This is your current hand: "), write(Hand), nl,
    write("Please select a tile to play: "),
    read(SelectedTile),
    validTile(SelectedTile),
    containsTile(SelectedTile, Hand),
    anyAvailableTiles(Hand, Board, AvailableTiles),
    containsTile(SelectedTile, AvailableTiles),
    getDirection(Board, SelectedTile, SkipLastTurn, Direction).

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    SkipLastTurn = false,
    write("This is your current hand: "), write(Hand), nl,
    write("Please select a tile to play: "),
    read(SelectedTile),
    validTile(SelectedTile),
    containsTile(SelectedTile, Hand),
    humanAvailableTiles(Hand, Board, AvailableTiles),
    containsTile(SelectedTile, AvailableTiles),
    getDirection(Board, SelectedTile, SkipLastTurn, Direction).

selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction) :-
    nl, write("Wrong tile! Please, try again! "), nl,
    selectTile(Board, Hand, SkipLastTurn, SelectedTile, Direction).


%**************************************************************
%Function Name: getDirection
%Purpose: To get the desired deriction to play a double tile
%Parameters:
%   Board        - current longana board
%   Tile         - the tile to be played
%   Skip         - whether last turn was skipped or not
%Return Value: 0 for left and 1 for right direction
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
getDirection(_, Tile, Skip, Direction) :-
    Skip = false,
    not(isDoubleTile(Tile)),
    Direction = 0.

getDirection(Board, Tile, Skip, Direction) :-
    write("Please select a direction to play (0=Left, 1=Right): "),
    read(Dir),
    validateDirection(Board, Tile, Skip, Dir),
    Direction = Dir.

getDirection(Board, Tile, Skip, Direction) :-
    write("Wrong direction! Please try again!"), nl,
    getDirection(Board, Tile, Skip, Direction).


%**************************************************************
%Function Name: validateDirection
%Purpose: To validate that the user did not input garbage value for direction
%Parameters:
%   Direction    - 0 for left, 1 for right
%Return Value: true if Direction is valid, false otherwise
%Local Variables: None
%Algorithm: None
%Assistance Received: None 
%**************************************************************
validateDirection(Board, Tile, _, Dir) :-
    Dir = 0,
    canPlayLeft(Tile, Board, _).

validateDirection(Board, Tile, _, Dir) :-
    Dir = 1,
    canPlayRight(Tile, Board, _).



%**************************************************************
%Function Name: humanPlay
%Purpose: To validate the human's input and then play it
%Parameters:
%   Board           - The current board
%   Stock           - The current stock
%   HumanHand       - Human's hand
%   TileToPlay      - Tile selected by the human to be played
%   Direction       - The direction at which the tile should be played
%   SkipLastTurn    - Whether last turn was skipped or not
%Return Value:
%   A list of: new baord, new stock, new human hand, whether turn was skipped or not
%Local Variables:
%   AvailableTiles           - the available tiles during this turn
%   AvailableTilesAfterDraw  - the available tiles after drawing from the stock
%   L                        - length of the available tiles
%   NewStock                 - Stock after a tile has been drawn once
%   NewBoard                 - Board after a tile has been placed
%   Drawn                    - the drawn tile from the stock, if a tile was drawn
%Algorithm:
%   Sequentially check each human move (according to Longana rules) and execute the
%   first possible move!
%Assistance Received: None
%**************************************************************
humanPlay(Board, Stock, HumanHand, TileToPlay, Direction, SkipLastTurn, _, Ret) :-
    SkipLastTurn = true,
    Direction = 0,
    not(TileToPlay = []),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the left!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

humanPlay(Board, Stock, HumanHand, TileToPlay, Direction, SkipLastTurn, _, Ret) :-
    SkipLastTurn = true,
    Direction = 1,
    not(TileToPlay = []),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the right!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

humanPlay(Board, Stock, HumanHand, TileToPlay, _, SkipLastTurn, _, Ret) :-
    SkipLastTurn = false,
    not(TileToPlay = []),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the left!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

humanPlay(Board, Stock, HumanHand, TileToPlay, _, SkipLastTurn, _, Ret) :-
    SkipLastTurn = false,
    not(TileToPlay = []),
    isDoubleTile(TileToPlay),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("You played tile "), write(TileToPlay), write(" to the right!"), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    removeTile(TileToPlay, HumanHand, NewHumanHand),
    Ret = [NewBoard, NewStock, NewHumanHand, NewSkip].

% Last turn skipped -> try to play right
humanPlay(Board, Stock, HumanHand, [], -1, SkipLastTurn, false, Ret) :-
    SkipLastTurn = true,
    dealTile(Stock, HumanHand, NewHumanHand),
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewHumanHand, HumanHandAfterPlay),
    playRight(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("You drew and played tile "), write(TileToPlay), write(" to the right!"), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, HumanHandAfterPlay, NewSkip].

% Last turn skipped -> try to play left
humanPlay(Board, Stock, HumanHand, [], -1, SkipLastTurn, false, Ret) :-
    SkipLastTurn = true,
    dealTile(Stock, HumanHand, NewHumanHand),
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewHumanHand, HumanHandAfterPlay),
    playLeft(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("You drew and played tile "), write(TileToPlay), write(" to the left!"), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, HumanHandAfterPlay, NewSkip].

% Last turn NOT skipped -> try to play normally
humanPlay(Board, Stock, HumanHand, [], -1, SkipLastTurn, false, Ret) :-
    dealTile(Stock, HumanHand, NewHumanHand),
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewHumanHand, HumanHandAfterPlay),
    playLeft(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("You drew and played tile "), write(TileToPlay), write(" to the left!"), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, HumanHandAfterPlay, NewSkip].

% No move was available, therefore draw a tile and skip a turn
humanPlay(Board, Stock, HumanHand, [], -1, _, false, Ret) :-
    dealTile(Stock, HumanHand, NewHumanHand),
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    [Drawn | _ ] = NewHumanHand,
    not(Drawn = []),
    write("You have no moves available even after drawing "), write(Drawn), nl,
    write("Skipping a turn.."), nl,
    Ret = [Board, NewStock, NewHumanHand, true].

humanPlay(Board, Stock, HumanHand, [], -1, _, false, Ret) :-
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    Stock = [],
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
    canPlayLeft(RecommendedTile, Board, _),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    highestTile(AvailableTiles, RecommendedTile),
    canPlayRight(RecommendedTile, Board, _),
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
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayLeft(RecommendedTile, Board, _ ),
    write("No moves available! Drawing from stock.."), nl,
    write("You drew and can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, SkipLastTurn, Help, Ret) :-
    Help = true,
    SkipLastTurn = true,
    anyAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayRight(RecommendedTile, Board, _ ),
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
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewHumanHand,
    not(Drawn = []),
    write("No moves available! Drawing from stock.."), nl,
    write("You drew tile "), write(Drawn), write(". Skipping a turn due to inability to play!"), nl,
    Ret = [Board, NewStock, NewHumanHand, true].

computerPlay(Board, Stock, HumanHand, _, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L \= 0,
    highestTile(AvailableTiles, RecommendedTile),
    canPlayLeft(RecommendedTile, Board, _),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, _, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L \= 0,
    highestTile(AvailableTiles, RecommendedTile),
    canPlayRight(RecommendedTile, Board, _),
    isDoubleTile(RecommendedTile),
    not(RecommendedTile = []),
    write("You can play tile "), write(RecommendedTile), write(" to the right!"), nl,
    Ret = [Board, Stock, HumanHand, false].

computerPlay(Board, Stock, HumanHand, _, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    not(HumanHand = NewHumanHand),
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayLeft(RecommendedTile, Board, _),
    write("No moves available! Drawing from stock.."), nl,
    write("You drew and can play tile "), write(RecommendedTile), write(" to the left!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, _, Help, Ret) :-
    Help = true,
    humanAvailableTiles(HumanHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, HumanHand, NewHumanHand),
    HumanHand \= NewHumanHand,
    removeFirstTile(Stock, NewStock),
    humanAvailableTiles(NewHumanHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, RecommendedTile),
    not(RecommendedTile = []),
    canPlayRight(RecommendedTile, Board, _),
    isDoubleTile(RecommendedTile),
    write("No moves available! Drawing from stock.."), nl,
    write("You drew and can play tile "), write(RecommendedTile), write(" to the right!"), nl,
    Ret = [Board, NewStock, NewHumanHand, false].

computerPlay(Board, Stock, HumanHand, _, Help, Ret) :-
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
    write("No moves available! Drawing from stock.."), nl,
    write("You drew tile "), write(Drawn), write(". Skipping a turn due to inability to play!"), nl,
    Ret = [Board, NewStock, NewHumanHand, true].

% Normal case - computer play mode
computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    Help = false,
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, ComputerHand, NewComputerHand),
    playRight(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer played tile "), write(TileToPlay),
    write(" to the right, because it was its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, NewComputerHand, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    Help = false,
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    highestTile(AvailableTiles, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, ComputerHand, NewComputerHand),
    isDoubleTile(TileToPlay),
    playLeft(Board, Stock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer played tile "), write(TileToPlay),
    write(" to the left, because it was a double tile and its only available turn."), nl,
    [NewBoard | [NewStock | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, NewStock, NewComputerHand, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    Help = false,
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    not(ComputerHand = NewComputerHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    playRight(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the right, because it was its only available turn."), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    Help = false,
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    not(ComputerHand = NewComputerHand),
    removeFirstTile(Stock, NewStock),
    anyAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    isDoubleTile(TileToPlay),
    playLeft(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the left, because it was a double tile and its only available turn."), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    Help = false,
    SkipLastTurn = true,
    anyAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    not(ComputerHand = NewComputerHand),
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
    Help = false,
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
    Help = false,
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
    Help = false,
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    not(ComputerHand = NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    playRight(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the right, because it was its only available turn."), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, SkipLastTurn, Help, Ret) :-
    Help = false,
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    not(ComputerHand = NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    highestTile(AvailableTilesAfterDraw, TileToPlay),
    not(TileToPlay = []),
    removeTile(TileToPlay, NewComputerHand, ComputerHandAfterDraw),
    isDoubleTile(TileToPlay),
    playLeft(Board, NewStock, TileToPlay, SkipLastTurn, PlayResult),
    write("Computer drew and played tile "), write(TileToPlay),
    write(" to the left, because it was a double tile and its only available turn."), nl,
    [NewBoard | [StockAfterPlay | [NewSkip | _ ]]] = PlayResult,
    Ret = [NewBoard, StockAfterPlay, ComputerHandAfterDraw, NewSkip].

computerPlay(Board, Stock, ComputerHand, _, Help, Ret) :-
    Help = false,
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    dealTile(Stock, ComputerHand, NewComputerHand),
    not(ComputerHand = NewComputerHand),
    removeFirstTile(Stock, NewStock),
    computerAvailableTiles(NewComputerHand, Board, AvailableTilesAfterDraw),
    length(AvailableTilesAfterDraw, Len),
    Len = 0,
    [Drawn | _ ] = NewComputerHand,
    not(Drawn = []),
    write("Computer drew tile "), write(Drawn),
    write(" and skips a turn, because it was unable to play."), nl,
    Ret = [Board, NewStock, NewComputerHand, true].

computerPlay(Board, Stock, ComputerHand, _, Help, Ret) :-
    Help = false,
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
    write("No computer moves available!"), nl,
    write("No more tiles left in stock.. Skipping turn.."), nl,
    Ret = [Board, NewStock, NewComputerHand, true].

% Empty stock here
computerPlay(Board, Stock, ComputerHand, _, Help, Ret) :-
    Help = false,
    computerAvailableTiles(ComputerHand, Board, AvailableTiles),
    length(AvailableTiles, L),
    L = 0,
    Stock = [],
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
playRight(Board, Stock, [], _, [Board, Stock, true]).

playRight(Board, Stock, TileToPlay, _, Ret) :-
    length(Board, Len),
    canPlayRight(TileToPlay, Board, NeedsReversal),
    NeedsReversal = false,  % If reverseal is needed, then backtrack and call the other case
    insertAt(0, Len, TileToPlay, Board, NewBoard),
    Ret = [NewBoard, Stock, false].

playRight(Board, Stock, TileToPlay, _, Ret) :-
    length(Board, Len),
    reverseTile(TileToPlay, ReversedTile),
    canPlayRight(ReversedTile, Board, _),
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
playLeft(Board, Stock, [], _, [Board, Stock, true]).

playLeft(Board, Stock, TileToPlay, _, Ret) :-
    canPlayLeft(TileToPlay, Board, NeedsReversal),
    NeedsReversal = false,  % If reverseal is needed, then backtrack and call the other case
    NewBoard = [TileToPlay | Board],
    Ret = [NewBoard, Stock, false].

playLeft(Board, Stock, TileToPlay, _, Ret) :-
    reverseTile(TileToPlay, ReversedTile),
    canPlayLeft(ReversedTile, Board, _),
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
computerAvailableTiles([], _, []).

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
humanAvailableTiles([], _, []).

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
anyAvailableTiles([], _, []).

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
hasNormalOptions([], _) :-
    false.

hasNormalOptions(Hand, Board) :-
    [First | _ ] = Hand,
    canPlayLeft(First, Board, _ ).

hasNormalOptions(Hand, Board) :-
    [First | _ ] = Hand,
    isDoubleTile(First),
    canPlayRight(First, Board, _ ).

hasNormalOptions(Hand, Board) :-
    [ _ | Rest] = Hand,
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
hasOptionsWhenSkipped([], _) :-
    false.

hasOptionsWhenSkipped(Hand, Board) :-
    [First | _ ] = Hand,
    canPlayLeft(First, Board, _ ).

hasOptionsWhenSkipped(Hand, Board) :-
    [First | _ ] = Hand,
    canPlayRight(First, Board, _ ).

hasOptionsWhenSkipped(Hand, Board) :-
    [ _ | Rest] = Hand,
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
    [ _ | [Pip2 | _ ]] = Tile,
    [LeftTile | _ ] = Board,
    [BoardPip1 | _ ] = LeftTile,
    Pip2 = BoardPip1,
    NeedsReversal = false.

canPlayLeft(Tile, Board, NeedsReversal) :-
    reverseTile(Tile, ReversedTile),
    [ _ | [Pip2 | _ ]] = ReversedTile,
    [LeftTile | _ ] = Board,
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
    [Pip1 | _ ] = Tile,
    last(Board, RightTile),
    [ _ | [BoardPip2 | _ ]] = RightTile,
    Pip1 = BoardPip2,
    NeedsReversal = false.

canPlayRight(Tile, Board, NeedsReversal) :-
    reverseTile(Tile, ReversedTile),
    [Pip1 | _ ] = ReversedTile,
    last(Board, RightTile),
    [ _ | [BoardPip2 | _ ]] = RightTile,
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
    nl,
    write("***********************************************************************************************"), nl,
    write("***********************************************************************************************"), nl,
    write("  "), drawDoubleTiles(Board), nl,
    write("L "), drawSingleTiles(Board), write("R"), nl,
    write("  "), drawDoubleTiles(Board), nl,
    write("***********************************************************************************************"), nl,
    write("***********************************************************************************************"), nl, nl.
















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



handSum([], CurrentSum, CurrentSum).

handSum(Hand, CurrentSum, Ans) :-
    [First | Rest] = Hand,
    pipSum(First, FirstTileSum),
    NewSum is CurrentSum + FirstTileSum,
    handSum(Rest, NewSum, Ans).


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
containsTile(_, []) :-
    false.

containsTile(TileToPlay, Hand) :-
    [First | _ ] = Hand,
    First = TileToPlay.

containsTile(TileToPlay, Hand) :-
    [First | _ ] = Hand,
    reverseTile(First, ReversedTile),
    ReversedTile = TileToPlay.

containsTile(TileToPlay, Hand) :-
    [ _ | Rest] = Hand,
    containsTile(TileToPlay, Rest).