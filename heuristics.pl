%% --- Random IA ---
choose([], []).
choose(List, Elt) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, Elt).


%% --- MinMax heuristic ---
evaluateAndChoose([Move|Moves],Player,Board,OriginalBoard,Counter,Depth,MaxMin,Record,Best) :-
                                applyMove(Move,Player,Board,NewBoard),
                                minimax(Depth,Player,NewBoard,OriginalBoard,MaxMin,MoveX,Value),
                                update(Move,Value,Record,NewRecord,MaxMin,Counter),
                                NewCounter is Counter+1,
                                evaluateAndChoose(Moves,Player,Board,OriginalBoard,NewCounter,Depth,MaxMin,NewRecord,Best).
evaluateAndChoose([],_,_,_,_,_,_,Record,Record) :- !.

minimax(D,Player,Board,OriginalBoard,MaxMin,Move,Value) :- D > 0,
                                NewPlayer is 1-Player,
                                D1 is D-1,
                                MinMax is -1*MaxMin,
                                setof(M,move(Board,Player,M),Moves),
                                !,
                                evaluateAndChoose(Moves,NewPlayer,Board,OriginalBoard,0,D1,MinMax,(nil,-1000),(Move,Value)).

minimax(_,Player,Board,OriginalBoard,MaxMin,nil,Value) :- value(Player,Board,OriginalBoard,0,V),Value is V*MaxMin,!.


%% ---AlphaBeta heuristic ---
evaluateAndChoose([Move|Moves], Player, Board, OriginalBoard, Counter, Depth, Alpha, Beta, Move1, BestMove) :-
    applyMove(Move, Player, Board, NewBoard),
    NewPlayer is 1 - Player,
    alphaBeta(Depth, NewPlayer, NewBoard, OriginalBoard, Alpha, Beta, MoveX, Value),
    NewValue is -Value,
    NewCounter is Counter + 1,
    cutoff(Move, NewValue, NewCounter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, BestMove).

evaluateAndChoose([],_,_,_,_,_,Alpha,_,Move,(Move,Alpha)).

alphaBeta(Depth, Player, Board, OriginalBoard, Alpha, Beta, Move, Value):-
    Depth > 0,
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    NewDepth is Depth-1,
    setof(M,move(Board,Player,M),Moves),
    !,
    evaluateAndChoose(Moves, Player, Board, OriginalBoard, 0, NewDepth, Alpha1, Beta1, nil, (Move, Value)).

alphaBeta(_, Player, Board, OriginalBoard, Alpha, Beta, Move, Value):-
    value(Player, Board, OriginalBoard, 0, Value), !.

cutoff(Move, Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, (Move, Value)):-
    Value >= Beta.

cutoff(Move, Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, BestMove):-
    Alpha < Value, Value < Beta,
    evaluateAndChoose(Moves, Player, NewBoard, OriginalBoard, Counter, Depth, Value, Beta, Move, BestMove).

cutoff((MoveL,MoveC), Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, (Move1L,Move1C), BestMove):-
    Value =:= Alpha, nonvar(Move1L), nonvar(Move1C), (MoveL > Move1L;(MoveL =:= Move1L, MoveC > Move1C)),
    evaluateAndChoose(Moves, Player, NewBoard, OriginalBoard, Counter, Depth, Alpha, Beta, (MoveL, MoveC), BestMove).
    
cutoff(Move, Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, BestMove):-
    Value =< Alpha,
    evaluateAndChoose(Moves, Player, NewBoard, OriginalBoard, Counter, Depth, Alpha, Beta, Move1, BestMove).




update(Move,Value,_,(Move,Value),_,0) :- !.

update((MoveL,MoveC),Value,((Move1L,Move1C),Value1),((MoveL,MoveC),Value),1,_) :- Value =:= Value1, (MoveL > Move1L;(MoveL =:= Move1L, MoveC > Move1C)).
update(Move,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =:= Value1.

update(Move,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =< Value1.
update(Move,Value,(Move1,Value1),(Move,Value),1,_) :- Value > Value1.
update(Move,Value,(Move1,Value1),(Move,Value),-1,_) :- Value < Value1.
update(Move,Value,(Move1,Value1),(Move1,Value1),-1,_) :- Value >= Value1.

value(Player,[X|L],[OX|OL],VStart,V) :- compare(Player,X,OX,0,N),NewStart is N+VStart,value(Player,L,OL,NewStart,V).
value(_,[],[],V,V).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= Player,OE =:= 1-Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= 1-Player,OE =:= Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= OE,compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- var(E),var(OE),compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= 1-Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(_,[],[],N,N) :- !.