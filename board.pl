makeMatrix(N, Mat) :- makeMatrix(N,N,Mat).
makeMatrix(N, M, Mat) :- length(Mat,N),
                         makeLine(Mat,M).
                     
makeLine([],_):- !.
makeLine([H|T],M):- length(H,M),
                    makeLine(T,M).

diskAt(Board,IndexL,IndexC,Disk) :- nth1(IndexL,Board,BoardLine),nth1(IndexC,BoardLine,Disk).

insideBoard(IndexL, IndexC) :- insideBoardL(IndexL), insideBoardC(IndexC).
insideBoardL(IndexL) :- IndexL > 0, maxL(MaxL), IndexL =< MaxL.
insideBoardC(IndexC) :- IndexC > 0, maxC(MaxC), IndexC =< MaxC.

boardFull([H|T]):- listFull(H), boardFull(T).
boardFull([]).
listFull([X|L]) :- nonvar(X),listFull(L).
listFull([]).

