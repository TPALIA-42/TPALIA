makeMatrix(N, Mat) :- makeMatrix(N,N,Mat).
makeMatrix(N, M, Mat) :- length(Mat,N),
                         makeLine(Mat,M).
                     
makeLine([],_):- !.
makeLine([H|T],M):- length(H,M),
                    makeLine(T,M).

%%% --- Evaluate if a disk is here at the given index L and index C ---
diskAt(Board,IndexL,IndexC,Disk) :- nth1(IndexL,Board,BoardLine),nth1(IndexC,BoardLine,Disk).

%%% --- Evaluate if a disk placement is inside the frontiers decided at the beginning ---
insideBoard(IndexL, IndexC) :- insideBoardL(IndexL), insideBoardC(IndexC).
insideBoardL(IndexL) :- IndexL > 0, maxL(MaxL), IndexL =< MaxL.
insideBoardC(IndexC) :- IndexC > 0, maxC(MaxC), IndexC =< MaxC.

%%% --- Verify that the board is full: end of game ---
boardFull([H|T]):- listFull(H), boardFull(T).
boardFull([]).
listFull([X|L]) :- nonvar(X),listFull(L).
listFull([]).

%% -- Display game board --
displayGame(_,_) :- no_output(1), !.
displayGame(L,Player) :-  maxL(GameHeight),write('*----------- Tour de '),write(Player),writeln(' ----------*'),nl,displayIndex(1,GameHeight),nl,!,displayBoard(L,Player,1).
displayBoard([X|L],Player,IndexL) :- write(IndexL),write(' | '),displayLine(X),nl,NewIndexL is IndexL + 1,displayBoard(L,Player,NewIndexL).
displayBoard([],_,_) :- writeln('*-------------------------------*'),nl,!.

displayFinalGame(_) :- no_output(1), !.
displayFinalGame(L) :- maxL(GameHeight),writeln('*--------- Plateau final --------*'),nl,displayIndex(1,GameHeight),nl,!,displayBoard(L,-1,1).

displayLine([]).
displayLine([X|L]) :- var(X),write('_   '),!,displayLine(L).
displayLine([X|L]) :- write(X),write('   '),!,displayLine(L).

displayIndex(GameHeight,GameHeight) :- write('  '),write(GameHeight),nl,write('----------------------------------'), !.
displayIndex(1,GameHeight) :- write('  | 1 '),displayIndex(2,GameHeight).
displayIndex(N,GameHeight) :- write('  '),write(N),write(' '),N1 is N+1,displayIndex(N1,GameHeight).

