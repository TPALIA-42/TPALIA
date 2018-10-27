%% --- Init ---
init :- askForGameHeight(GameHeight),
        init(GameHeight).

askForGameHeight(GameHeight):- write('Saisir la taille du jeu : '), read(Input),nl,
                        (Input mod 2 =:= 0 -> GameHeight is Input,!;var(GameHeight),
                        write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

init(GameHeight) :- GameHeight mod 2 =:= 0,
                    [board],
                    [move],
                    [transformBoard],
                    
                    retractall(maxL(_)),
                    retractall(maxC(_)),
                    retractall(board(_)),
                    
                    assert(maxL(GameHeight)),
                    assert(maxC(GameHeight)),
                    makeMatrix(GameHeight,Mat),
                    Index1 is GameHeight / 2,
                    Index2 is 1 + GameHeight / 2,
                    diskAt(Mat,Index1,Index1,0),
                    diskAt(Mat,Index1,Index2,1),
                    diskAt(Mat,Index2,Index1,1),
                    diskAt(Mat,Index2,Index2,0),
                    assert(board(Mat)).

                    
%% --- Play ---
play() :- board(Board), play(Board,0,_).

play(Player) :- board(Board), play(Board,Player,_).

play(Board,Player,Result) :- displayGame(Board,Player),
                             chooseMove(Board,Player,Move),
                             applyMove(Move,Player,Board,NewBoard),
                             nextPlayer(NewBoard,Player,NextPlayer),
                             !,play(NewBoard,NextPlayer,Result).

play(Board,_,Result) :- winner(Board,Result),!,announce(Result),!.


%% --- Display Game
displayGame(L,Player) :- write('*--- Tour de '),write(Player),writeln(' ---*'),!,displayBoard(L,Player).
displayBoard([X|L],Player) :- displayLine(X),nl,displayBoard(L,Player).
displayBoard([],_) :- writeln('*-----------------*'),nl,!.

displayLine([]).
displayLine([X|L]) :- var(X),write('. '),!,displayLine(L).
displayLine([X|L]) :- write(X),write(' '),!,displayLine(L).


%% --- Choose Move ---
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


%% --- Apply Move---
applyMove((X,Y),Player,Board,NewBoard) :- nth1(X,Board,L),
                                          nth1(Y,L,Player),
                                          transformBoard((X,Y),Player,Board,NewBoard).

%% --- Next Player
nextPlayer(Board,Actual,Next) :- Next is 1-Actual,move(Board,Next,_),!.
nextPlayer(Board,Actual,Actual) :- move(Board,Actual,_),!.


%% --- Winner and Annouce
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

announce(Result):- write("Et le gagnant est ... le joueur des "),write(Result),write(" !"),nl.
