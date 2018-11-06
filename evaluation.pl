run :-
    [main],
    assert(no_output(1)),
    runTournament(5).

runTournament(MaxH) :- runTournament(0,0,MaxH).
runTournament(H0,0,MaxH) :- H0 =:= MaxH+1.
runTournament(H0,H1,MaxH) :-
    runMatch(H0,H1),
    (H1 < MaxH -> NewH0 is H0, NewH1 is H1+1 ; NewH0 is H0 + 1, NewH1 is 0),
    runTournament(NewH0,NewH1,MaxH).
    
runMatch(H0,H1) :- runMatch(H0,H1,S0,S1),
                   write('Heuristique '),write(H0),write(' vs '),write(H1),
                   write(' : '),
                   write(S0),write(' / '),writeln(S1).
                         
runMatch(H0,H1,S0,S1) :- runMatch(H0,H1,10,0,0,S0,S1).

runMatch(_,_,0,Score0,Score1,Score0,Score1).
runMatch(H0,H1,Count,Temp0,Temp1,Score0,Score1) :-
    [main],
    init(8,0,H0,H1),
    play(0,R),
    (R =:= 0 -> NewScore0 is Temp0 + 1, NewScore1 is Temp1 ; NewScore0 is Temp0, NewScore1 is Temp1 + 1),
    NewCount is Count-1,
    runMatch(H0,H1,NewCount,NewScore0,NewScore1,Score0,Score1).
