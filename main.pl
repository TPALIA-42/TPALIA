%% --- Init ---
init :- askForGameHeight(GameHeight),
        askForNumberOfPlayers(NbOfPlayers),
        init(GameHeight,NbOfPlayers).

askForGameHeight(GameHeight):- write('Saisir la taille du jeu : '), read(Input),nl,
                        (Input mod 2 =:= 0 -> GameHeight is Input,! 
                                            ; var(GameHeight), write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

askForNumberOfPlayers(NbOfPlayers):-    write('Saisir le nombre de joueurs humains (0, 1 ou 2) : '),read(Input),nl,
                                        ( (Input =< 2, Input >= 0) ->  NbOfPlayers is Input
                                                    ; write('Nombre invalide, veuillez le resaisir.'),askForNumberOfPlayers(NbOfPlayers)).
						

init(GameHeight,NbOfPlayers) :- GameHeight mod 2 =:= 0,
                                [board],
                                [move],
                                [transformBoard],
                                
                                retractall(isHuman(_)),
                                (NbOfPlayers >= 1 -> write('Le joueur 0 est humain.'), nl, assert(isHuman(0)) ; write('Le joueur 0 est une IA.'),nl),
                                (NbOfPlayers =:= 2 -> write('Le joueur 1 est humain.'), nl, assert(isHuman(1)) ; write('Le joueur 1 est une IA.'),nl),
                                nl,
                                
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
chooseMove(Board,Player,Move) :- (isHuman(Player) -> chooseMoveHuman(Board,Player,Move); chooseMoveIA(Board,Player,Move)).

chooseMoveIA(Board,Player,Move) :- allMoves(Board,Player,Moves),evaluateAndChoose(Moves,Board,(nil,-1000),Move).

chooseMoveHuman(Board,Player,Move) :-   allMoves(Board,Player,Moves),
                                        write('Liste des coups disponibles : '),write(Moves),nl,
                                        write('Choisissez un coup : '),nl,
                                        askForMove(Move,Moves),
                                        write('Vous avez choisi le coup ['),write(Move),write(']'),nl.

askForMove(Move,Moves):- 
                write('X : '),read(InputX),
                write('Y : '),read(InputY),
                (moveIsLegal((InputX,InputY),Moves) -> assignMove(Move,(InputX,InputY))
                    ; write('Coup non valide, veuillez réiterer la saisie.'),nl,askForMove(Move,Moves)).                            
                            
moveIsLegal(Move,[Move|_]).
moveIsLegal(Move,[_|RestOfMoves]):- moveIsLegal(Move,RestOfMoves).
               
assignMove(Move,Move).

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

announce(Result):- write("Et le gagnant est ... le joueur "),write(Result),write("!"),nl.
