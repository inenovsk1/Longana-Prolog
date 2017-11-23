%************************************************************
%* Name:               Ivaylo Nenovski                      *
%* Project:            Longana Prolog                       *
%* Class:              CMPS 366-01                          *
%* Date:               12/08/2017                           *
%************************************************************


%************************************************************************************************
%*********************************** Tile Implementation ****************************************
%************************************************************************************************

validTile(Pip1, Pip2) :-
    Pip1 =< 6,
    Pip1 >= 0,
    Pip2 =< 6,
    Pip2 >= 0.

isDoubleTile(Pip1, Pip2) :-
    Pip1 = Pip2.



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
shuffleStock(1000, Stock, Stock).

shuffleStock(Start, Stock, RetVal) :-
    NewStart is Start + 1,
    [First | Rest] = Stock,
    random_between(0, 27, RandIndex),
    insertAt(0, RandIndex, First, Rest, NewStock),
    shuffleStock(NewStart, NewStock, RetVal).


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


createStock(Stock) :-
    generateStock(0, 0, X, GeneratedStock),
    write(GeneratedStock), nl, nl,
    shuffleStock(0, GeneratedStock, Stock),
    write(Stock), nl, nl, length(Stock, X),
    write(X).