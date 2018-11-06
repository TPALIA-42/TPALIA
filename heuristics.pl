%% --- Random AI ---
randomChoose([], []).
randomChoose(List, Elt) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, Elt).

%% --- Simple AI ---
simpleChoose(Moves,Player,Board,Move) :- simpleChoose(Moves,Player,Board,nil,-10000,Move).

simpleChoose([],Player,Board,Best,Value,Best).
simpleChoose([Move|Moves],Player,Board,Actual,Value,Best) :-
                                applyMove(Move,Player,Board,NewBoard),
                                countTotalDisk(NewBoard,Player,N),
                                (N > Value -> simpleChoose(Moves,Player,Board,Move,N,Best) ; simpleChoose(Moves,Player,Board,Actual,Value,Best)).

%% --- MinMax heuristic ---
minimaxChoose(Moves,Player,Board,Depth,Move) :-
                                Counter is 0,
                                MaxMin is 1,
                                minimaxChoose(Moves,Player,Board,Board,Counter,Depth,MaxMin,(nil,-10000),(Move,_)).
minimaxChoose([Move|Moves],Player,Board,OriginalBoard,Counter,Depth,MaxMin,Record,Best) :-
                                applyMove(Move,Player,Board,NewBoard),
                                minimax(Depth,Player,NewBoard,OriginalBoard,MaxMin,_,Value),
                                update(Move,Value,Record,NewRecord,MaxMin,Counter),
                                NewCounter is Counter+1,
                                minimaxChoose(Moves,Player,Board,OriginalBoard,NewCounter,Depth,MaxMin,NewRecord,Best).
minimaxChoose([],_,_,_,_,_,_,Record,Record) :- !.

minimax(0,Player,Board,OriginalBoard,MaxMin,_,Value) :- value(Player,Board,OriginalBoard,0,V),Value is V*MaxMin,!.

minimax(D,Player,Board,OriginalBoard,MaxMin,Move,Value) :- D > 0,
                                NewPlayer is 1-Player,
                                D1 is D-1,
                                MinMax is -1*MaxMin,
                                setof(M,move(Board,NewPlayer,M),Moves),
                                !,
                                minimaxChoose(Moves,NewPlayer,Board,OriginalBoard,0,D1,MinMax,(nil,-10000),(Move,Value)).
minimax(D,Player,Board,_,MaxMin,nil,Value) :-
    countTotalDisk(Board,Player,N),
    Opponent is 1-Player,
    countTotalDisk(Board,Opponent,NO),
    (N > NO -> Value is MaxMin*1000 ; Value is -MaxMin*1000),!.

update(Move,Value,_,(Move,Value),_,0) :- !.
update(_,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =< Value1.
update(Move,Value,(_,Value1),(Move,Value),1,_) :- Value > Value1.
update(Move,Value,(_,Value1),(Move,Value),-1,_) :- Value < Value1.
update(_,Value,(Move1,Value1),(Move1,Value1),-1,_) :- Value >= Value1.

%% ---AlphaBeta heuristic ---
alphaBetaChoose(Moves,Player,Board,Depth,Move) :-
                                Counter is 0,
                                Alpha is -10000,
                                Beta is 10000,
                                nth1(1,Moves,FirstMove),
                                alphaBetaChoose(Moves,Player,Board,Board,Depth,Alpha,Beta,FirstMove,(Move,_)).

alphaBetaChoose([Move|Moves],Player,Board,OriginalBoard,Depth,Alpha,Beta,Record,Best) :-
                                                                    applyMove(Move,Player,Board,NewBoard),
                                                                    alphaBeta(Depth,Player,NewBoard,OriginalBoard,Alpha,Beta,MoveX,Value),
                                                                    cutoff(Move,Value,Player,Board,OriginalBoard,Depth,Alpha,Beta,Moves,Record,Best).
alphaBetaChoose([],_,_,_,_,Alpha,_,Record,(Record,Alpha)) :- !.

alphaBeta(0,Player,Board,OriginalBoard,_,_,_,Value) :- value(Player,Board,OriginalBoard,0,Value),!.

alphaBeta(D,Player,Board,OriginalBoard,Alpha,Beta,Move,Value) :- D > 0,
                                                    NewPlayer is 1-Player,
                                                    D1 is D-1,
                                                    Alpha1 is -1*Beta,
                                                    Beta1 is -1*Alpha,
                                                    setof(M,move(Board,NewPlayer,M),Moves),
                                                    !,
                                                    alphaBetaChoose(Moves,NewPlayer,Board,OriginalBoard,D1,Alpha1,Beta1,nil,(Move,Value1)),
                                                    Value is -1*Value1.

alphaBeta(_,Player,Board,_,Alpha,Beta,_,Value) :-
    countTotalDisk(Board,Player,N),
    Opponent is 1-Player,
    countTotalDisk(Board,Opponent,NO),
    (N > NO -> Value is Beta ; Value is Alpha),!.
                                                    
cutoff(Move,Value,_,_,_,_,_,Beta,_,_,(Move,Value)) :-
    Value >= Beta,!.

cutoff(Move,Value,Player,Board,OriginalBoard,D,Alpha,Beta,Moves,_,Best) :-
    Alpha < Value,Value < Beta,!,
    alphaBetaChoose(Moves,Player,Board,OriginalBoard,D,Value,Beta,Move,Best).
    
cutoff(_,Value,Player,Board,OriginalBoard,D,Alpha,Beta,Moves,Record,Best) :-
    Value =< Alpha,!,
    alphaBetaChoose(Moves,Player,Board,OriginalBoard,D,Alpha,Beta,Record,Best).

value(Player,[X|L],[OX|OL],VStart,V) :- compare(Player,X,OX,0,N),NewStart is N+VStart,value(Player,L,OL,NewStart,V).
value(_,[],[],V,V).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= Player,OE =:= 1-Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= 1-Player,OE =:= Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= OE,compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- var(E),var(OE),compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= 1-Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(_,[],[],N,N) :- !.

%% --- Corner heuristic ---
