play(Board,Player,Result) :- displayGame(Board,Player),
                             chooseMove(Board,Player,Move),
                             applyMove(Move,Player,Board,NewBoard),
                             nextPlayer(NewBoard,Player,NextPlayer),
                             !,play(NewBoard,NextPlayer,Result).

play(Board,_,Result) :- winner(Board,Result),!,announce(Result),!.

diskAt(Board,IndexL,IndexC,Disk) :- nth1(IndexL,Board,BoardLine),nth1(IndexC,BoardLine,Disk).

insideBoard(IndexL, IndexC) :- insideBoardL(IndexL), insideBoardC(IndexC).
insideBoardL(IndexL) :- IndexL > 0, maxL(MaxL), IndexL =< MaxL.
insideBoardC(IndexC) :- IndexC > 0, maxC(MaxC), IndexC =< MaxC.

allMoves(Board,Player,Moves) :- setof(M,move(Board,Player,M),Moves).
chooseMove(Board,Player,Move) :- allMoves(Board,Player,Moves),evaluateAndChoose(Moves,Board,(nil,-1000),Move).

%% https://stackoverflow.com/questions/2261238/random-items-in-prolog
%% choose(List, Elt) - chooses a random element
%% in List and unifies it with Elt.
choose([], []).
choose(List, Elt) :-
        length(List, Length),
        random(0, Length, Index),
        nth0(Index, List, Elt).

evaluateAndChoose(X,_,_,E) :- choose(X,E).

applyMove((X,Y),Player,Board,NewBoard) :- nth1(X,Board,L),
                                          nth1(Y,L,Player),
                                          transformBoard((X,Y),Player,Board,NewBoard).


displayGame(L,Player) :- write('*--- Tour de '),write(Player),writeln(' --*'),!,affiche(L,Player).
affiche([X|L],Player) :- println(X),nl,affiche(L,Player).
affiche([],_) :- writeln('*----------------*'),!.

println([]).
println([X|L]) :- var(X),write('. '),!,println(L).
println([X|L]) :- write(X),write(' '),!,println(L).

announce(Result):- write("Et le gagnant est ... le joueur des "),write(Result),write(" !"),nl.

isBoardFull([H|T]):- isListFull(H), isBoardFull(T).
isBoardFull([]).
isListFull([X|L]) :- nonvar(X),isListFull(L).
isListFull([]).

nextPlayer(Board,Actual,Next) :- Next is 1-Actual,move(Board,Next,_),!.
nextPlayer(Board,Actual,Actual) :- move(Board,Actual,_),!.

winner(Board,Result) :- countTotalDisk(Board,0,N1),countTotalDisk(Board,1,N2),judge(N1,N2,Result).

countTotalDisk(Board,Player,N) :- caculate(Board,Player,0,N).
caculate([L|Remaining],Player,NbActuel,N) :- countTotalList(L,Player,0,NList),NbNew is NbActuel+NList,caculate(Remaining,Player,NbNew,N).
caculate([],_,V,V).
countTotalList([X|L],Player,NbNow,NList) :- nonvar(X),X=:=Player,!,NewNb is NbNow+1,countTotalList(L,Player,NewNb,NList).
countTotalList([_|L],Player,NbNow,NList) :- countTotalList(L,Player,NbNow,NList).
countTotalList([],_,V,V).

judge(X,Y,0) :- X > Y.
judge(X,Y,1) :- X < Y.
judge(_,_,2).

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
        [move],
        [transformBoard],
        assert(board([L1,L2,L3,L4,L5,L6,L7,L8])).

% generer un board à dimensions variables
init2 :- askForGameHeight(GameHeight),
         assert(maxL(GameHeight)),
         assert(maxC(GameHeight)),
         makeMatrix(GameHeight,Mat),
         Index1 is GameHeight / 2,
         Index2 is 1 + GameHeight / 2,
         diskAt(Mat,Index1,Index1,0),
         diskAt(Mat,Index1,Index2,1),
         diskAt(Mat,Index2,Index1,1),
         diskAt(Mat,Index2,Index2,0),
         [move],
         [transformBoard],
         assert(board(Mat)).

askForGameHeight(GameHeight):- write('Saisir la taille du jeu : '), read(Input),nl,
                               (Input mod 2 =:= 0 -> GameHeight is Input,!;var(GameHeight),
                               write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

makeMatrix(N, Mat) :- makeMatrix(N,N,Mat).
makeMatrix(N, M, Mat) :- length(Mat,N),
                         makeLine(Mat,M).
                     
makeLine([],_):- !.
makeLine([H|T],M):- length(H,M),
                    makeLine(T,M).
