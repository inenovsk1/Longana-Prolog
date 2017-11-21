man(ivo).
man(ivan).
man(kumar).
woman(margarita).
loves(ivo, women).
playsGuitar(ivo) :- man(ivo).

isMasculine(ivo) :-
    man(ivo),
    loves(ivo, women).