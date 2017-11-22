%************************************************************
%* Name:               Ivaylo Nenovski                      *
%* Project:            Longana Prolog                       *
%* Class:              CMPS 366-01                          *
%* Date:               12/08/2017                           *
%************************************************************

%KNOWLEDGE BASE

%RULES

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
%   
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

