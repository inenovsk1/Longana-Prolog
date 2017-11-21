%************************************************************
%* Name:               Ivaylo Nenovski                      *
%* Project:            Longana Prolog                       *
%* Class:              CMPS 366-01                          *
%* Date:               12/08/2017                           *
%************************************************************

%KNOWLEDGE BASE

%RULES

%Tile
validTile(Pip1, Pip2) :-
    Pip1 =< 6,
    Pip1 >= 0,
    Pip2 =< 6,
    Pip2 >= 0.

isDoubleTile(Pip1, Pip2) :-
    Pip1 = Pip2.

%Stock

%Generate stock base case
generateStock(Pip1, Pip2, ListOutput) :-
    Pip1 = 6,
    Pip2 = 6,
    append([Pip1, Pip2], ListOutput, ListOutput).

%Generate stock recursive case
generateStock(Pip1, Pip2, ListOutput) :-
    NewTile = [Pip1, Pip2],
    append(NewTile, ListOutput, ListOutput),
    Pip2 = 6,
    NewPip1 is Pip1 + 1,
    NewPip2 = 0,
    generateStock(NewPip1, NewPip2, ListOutput).

generateStock(Pip1, Pip2, ListOutput) :-
    NewTile = [Pip1, Pip2],
    append(NewTile, ListOutput, ListOutput),
    NewPip2 is Pip2 + 1,
    generateStock(Pip1, NewPip2, ListOutput).

