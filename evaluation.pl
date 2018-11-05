%% --- HEURISTICS EVALUATION ---
initEvaluation:-
    [board],
    [move],
    [transformBoard],
    [heuristics].

%% Heuristic1 Versus Heuristic2
playRangeOfGame(NbOfGame, Counter, GameHeight, Winner):-
    GameHeight mod 2 =:= 0,
    playGame(Heuristic1, Heuristic2, GameHeight).
    Counter is Counter + 1,
    ((Counter =<= NbOfGame) ->playRangeOfGame(NbOfGame, Heuristic1, Heuristic2, GameHeight, Counter,_)).


playGame(Heuristic1, Heuristic2, GameHeight):-

