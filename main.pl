%% --- INIT ---
init :- askForGameHeight(GameHeight),
        askForNumberOfPlayers(NbOfPlayers),
        init(GameHeight,NbOfPlayers).


%% -- Demande la taille du plateau au joueur --
askForGameHeight(GameHeight) :- write('Saisir la taille du jeu : '),
                                read(Input),nl,
                                (Input mod 2 =:= 0 -> GameHeight is Input,!;
                                var(GameHeight),write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

%% -- Demande le nombre de joueurs humains : si NbOfPlayers = 0, on a alors 2 IA etc. --
askForNumberOfPlayers(NbOfPlayers) :- write('Saisir le nombre de joueurs humains (0, 1 ou 2) : '),
                                      read(Input),nl,
                                      ((Input =< 2, Input >= 0) ->  NbOfPlayers is Input;
                                      write('Nombre invalide, veuillez le resaisir.'),askForNumberOfPlayers(NbOfPlayers)).

%% -- Met en place le jeu --
init(GameHeight,NbOfPlayers) :- GameHeight mod 2 =:= 0,
                                [board],
                                [move],
                                [transformBoard],
                                [heuristics],
                                
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
                                
                                putInitialsDisks(GameHeight, Mat),
                                assert(board(Mat)).

%% -- Met en place le plateau de jeu du début de partie --
putInitialsDisks(GameHeight, Mat):-
                                Index1 is GameHeight / 2,
                                Index2 is 1 + GameHeight / 2,
                                diskAt(Mat,Index1,Index1,0),
                                diskAt(Mat,Index1,Index2,1),
                                diskAt(Mat,Index2,Index1,1),
                                diskAt(Mat,Index2,Index2,0).


%% --- PLAY ---
play() :- board(Board), play(Board,0,_).

play(Player) :- board(Board), play(Board,Player,_).

play(Board,Player,Result) :- canPlay(Board,Player),
                             displayGame(Board,Player),
                             chooseMove(Board,Player,Move),
                             applyMove(Move,Player,Board,NewBoard),
                             nextPlayer(NewBoard,Player,NextPlayer),
                             !,play(NewBoard,NextPlayer,Result).

play(Board,_,Result) :- displayFinalGame(Board),winner(Board,Result),!,announce(Result),!.


%% --- Display Game
displayGame(L,Player) :-  maxL(GameHeight),write('*--- Tour de '),write(Player),writeln(' ---*'),nl,displayIndex(1,GameHeight),nl,!,displayBoard(L,Player,1).
displayBoard([X|L],Player,IndexL) :- write(IndexL),write(' '),displayLine(X),nl,NewIndexL is IndexL + 1,displayBoard(L,Player,NewIndexL).
displayBoard([],_,_) :- writeln('*-----------------*'),nl,!.

displayFinalGame(L) :- write('*--- Final Board'),writeln(' ---*'),!,displayBoard(L,-1,1).

displayLine([]).
displayLine([X|L]) :- var(X),write('_   '),!,displayLine(L).
displayLine([X|L]) :- write(X),write('   '),!,displayLine(L).

displayIndex(N,GameHeight) :- write('  '),!,(N == GameHeight ->write(N),true; write(N),write(' '),N1 is N+1,displayIndex(N1,GameHeight) ).

%% --- Choose Move ---
chooseMove(Board,Player,Move) :- (isHuman(Player) -> chooseMoveHuman(Board,Player,Move); chooseMoveIA(Board,Player,Move)).

chooseMoveIA(Board,Player,Move) :- allMoves(Board,Player,Moves),
                                   Counter is 0,
                                   Depth is 3,
                                   MaxMin is 1,
                                   Alpha is -10000,
                                   Beta is 10000,
                                   evaluateAndChoose(Moves,Player,Board,Board,Counter,Depth,Alpha,Beta,nil,(Move,_)).
                                   %evaluateAndChoose(Moves,Player,Board,Board,Counter,Depth,MaxMin,(nil,-1000),(Move,_)).
                                   
chooseMoveHuman(Board,Player,Move) :- allMoves(Board,Player,Moves),
                                      write('Liste des coups disponibles : '),write(Moves),nl,
                                      write('Choisissez un coup : '),nl,
                                      askForMove(Move,Moves),
                                      write('Vous avez choisi le coup ['),write(Move),write(']'),nl.

askForMove((MoveL,MoveC),Moves) :- write('L : '),read(InputL),
                                   write('C : '),read(InputC),
                                   (moveIsLegal((InputL,InputC),Moves) -> MoveL is InputL, MoveC is InputC;
                                   write('Coup non valide, veuillez réiterer la saisie.'),nl,askForMove((MoveL,MoveC),Moves)).

moveIsLegal(Move,[Move|_]).
moveIsLegal(Move,[_|RestOfMoves]):- moveIsLegal(Move,RestOfMoves).

%% --- Apply Move---
applyMove((X,Y),Player,Board,NewBoard) :- replace(Board,ModifBoard,1,X,Y,Player),
                                          transformBoard((X,Y),Player,ModifBoard,NewBoard).

%% --- Next Player
canPlay(Board,Player) :- move(Board,Player,_),!.
nextPlayer(Board,Actual,Next) :- Next is 1-Actual. %,canPlay(Board,Next),!.
%nextPlayer(Board,Actual,Actual).


%% --- Winner and Announce
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

announce(Result):- write("Et le gagnant est ... le joueur "),write(Result),write(" !"),nl.
