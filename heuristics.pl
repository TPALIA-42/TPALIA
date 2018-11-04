%% Minimax heuristic

giveValue(V,V).

minimax(0,Player,Board,OriginalBoard,MaxMin,_,Value) :- value(Player,Board,OriginalBoard,0,V),Val is V*MaxMin,giveValue(Value,Val),!.

minimax(D,Player,Board,OriginalBoard,MaxMin,Move,Value) :- D > 0,
                                NewPlayer is 1-Player,
                                D1 is D-1,
                                MinMax is -1*MaxMin,
                                setof(M,move(Board,NewPlayer,M),Moves),
                                !,
                                evaluateAndChoose(Moves,NewPlayer,Board,OriginalBoard,0,D1,MinMax,(nil,-1000),(Move,Value)).
minimax(_,_,_,_,MaxMin,nil,1000) :- MaxMin =:= 1,!.
minimax(_,_,_,_,MaxMin,nil,-1000) :- MaxMin =:= -1,!.

update(Move,Value,_,(Move,Value),_,0) :- !.
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