play(Board,Player,Result) :- gameOver(Board,Player,Result),!,announce(Result).

play(Board,Player,Result) :- chooseMove(Board,Player,Move),
                             applyMove(Move,Player,Board,Board1),
                             displayGame(Board1,Player),
                             nextPlayer(Player,Player1),
                             !,play(Board1,Player1,Result).
							 
chooseMove(Board,Player,Move) :- set_of(M,move(Board,Player,M),Moves),evaluate_and_choose(Moves,Board,(nil,-1000),Move).

evaluate_and_choose([X|_],_,_,X).

applyMove((X,Y),0,Board,Boardl) :- nth1(X,Board,L),
									nth1(Y,L,0),
									giveValue(L,LModif),
									nth1(X,Board,LModif),
									giveValue(Board,Boardl).
applyMove((X,Y),1,Board,Boardl) :- nth1(X,Board,L),
									nth1(Y,L,1),
									giveValue(L,LModif),
									nth1(X,Board,LModif),
									giveValue(Board,Boardl).


displayGame(L,Player) :- writeln('*----------------*'),!,affiche(L,Player).
affiche([X|L],Player) :- println(X),nl,affiche(L,Player).
affiche([],_) :- writeln('*----------------*'),!.

println([]).
println([X|L]) :- var(X),write('? '),!,println(L).
println([X|L]) :- write(X),write(' '),!,println(L).

gameOver(Board,Result) :- countMoves(Board,0,N1),countMoves(Board,1,N2),N1 =:= 0,N2 =:= 0,winner(Board,Result),!.
gameOver(Board,Result) :- isBoardFull(Board),winner(Board,Result),!.
											
isBoardFull([H|T]):- isListFull(H), isBoardFull(T).
isBoardFull([]).
isListFull([X|L]) :- nonvar(X),isListFull(L).
isListFull([]).

nextPlayer(Player,Player1) :- NextPlayer is 1-Player,giveValue(NextPlayer,Player1).

winner(Board,Result) :- countTotalDisk(Board,0,N1),countTotalDisk(Board,1,N2),juge(N1,N2,Result).

countTotalDisk(Board,Player,N) :- caculate(Board,Player,0,N).
caculate([L|Reste],Player,NbActuel,N) :- countTotalList(L,Player,0,NList),NbNew is NbActuel+NList,caculate(Reste,Player,NbNew,N).
caculate([],_,V,V).
countTotalList([X|L],Player,NbNow,NList) :- nonvar(X),X=:=Player,!,NewNb is NbNow+1,countTotalList(L,Player,NewNb,NList).
countTotalList([_|L],Player,NbNow,NList) :- countTotalList(L,Player,NbNow,NList).
countTotalList([],_,V,V).

juge(X,Y,0) :- X > Y,!.
juge(_,_,1).



init :- assert(maxL(8)),
		assert(maxC(8)),
		length(L1,8),
        length(L2,8),
        length(L3,8),
        length(L4,8),
        length(L5,8),
        length(L6,8),
        length(L7,8),
        length(L8,8),
        nth1(4,L4,1),
        nth1(5,L4,0),
        nth1(4,L5,0),
		nth1(5,L3,0),
		nth1(5,L2,0),
        nth1(5,L5,1),
		nth1(4,L6,0),
		nth1(4,L7,0),
        nth1(4,L8,1),
		nth1(6,L3,1),
        assert(dynamic board/1),
		[move],
        assert(board([L1,L2,L3,L4,L5,L6,L7,L8])),
		board(Board).