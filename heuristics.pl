%% --- Random IA ---
randomChoose([], []).
randomChoose(List, Elt) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, Elt).


%% --- MinMax heuristic ---
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
                                minimaxChoose(Moves,NewPlayer,Board,OriginalBoard,0,D1,MinMax,(nil,-1000),(Move,Value)).
%minimax(D,_,_,_,MaxMin,nil,Value) :- MaxMin =:= 1,Value is 1000*D,!.
%minimax(D,_,_,_,MaxMin,nil,Value) :- MaxMin =:= -1,Value is -1000*D,!.


%% ---AlphaBeta heuristic ---
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
                                                    
cutoff(Move,Value,_,_,_,_,_,Beta,_,_,(Move,Value)) :-
    Value >= Beta,!.

cutoff(Move,Value,Player,Board,OriginalBoard,D,Alpha,Beta,Moves,Record,Best) :-
    Alpha < Value,Value < Beta,!,
    alphaBetaChoose(Moves,Player,Board,OriginalBoard,D,Value,Beta,Move,Best).
    
cutoff(Move,Value,Player,Board,OriginalBoard,D,Alpha,Beta,Moves,Record,Best) :-
    Value =< Alpha,!,
    alphaBetaChoose(Moves,Player,Board,OriginalBoard,D,Alpha,Beta,Record,Best).


update(Move,Value,_,(Move,Value),_,0) :- !.
update(_,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =:= Value1.

update(_,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =< Value1.
update(Move,Value,(_,Value1),(Move,Value),1,_) :- Value > Value1.
update(Move,Value,(_,Value1),(Move,Value),-1,_) :- Value < Value1.
update(_,Value,(Move1,Value1),(Move1,Value1),-1,_) :- Value >= Value1.

value(Player,[X|L],[OX|OL],VStart,V) :- compare(Player,X,OX,0,N),NewStart is N+VStart,value(Player,L,OL,NewStart,V).
value(_,[],[],V,V).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= Player,OE =:= 1-Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= 1-Player,OE =:= Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= OE,compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- var(E),var(OE),compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= 1-Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(_,[],[],N,N) :- !.
