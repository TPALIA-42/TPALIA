%% --- INIT ---
init :- askForGameHeight(GameHeight),
        askForNumberOfPlayers(NbOfPlayers),
        (NbOfPlayers < 2 -> askForHeuristic(1,Heuristic1) ; Heuristic1 is 0),
        (NbOfPlayers =:= 0 -> askForHeuristic(0,Heuristic0) ; Heuristic0 is 0),
        init(GameHeight,NbOfPlayers,Heuristic0,Heuristic1).

%% -- Ask size of game board: must be even --
askForGameHeight(GameHeight) :- write('Saisir la taille du jeu : '),
                                read(Input),nl,
                                (Input mod 2 =:= 0 -> GameHeight is Input,!;
                                var(GameHeight),write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

%% -- Ask number of human players --
askForNumberOfPlayers(NbOfPlayers) :- write('Saisir le nombre de joueurs humains (0, 1 ou 2) : '),
                                      read(Input),nl,
                                      ((Input =< 2, Input >= 0) ->  NbOfPlayers is Input;
                                      write('Nombre invalide, veuillez le resaisir.'),askForNumberOfPlayers(NbOfPlayers)).

%% -- Ask for the heuristic for the AI Player --
askForHeuristic(Player,Heuristic) :- writeln('Liste des heuristiques :'),
                                     writeln('- 0. Coup en haut à gauche'),
                                     writeln('- 1. Aléatoire'),
                                     writeln('- 2. Basique'),
                                     writeln('- 3. Minimax'),
                                     writeln('- 4. Minimax avec élagage alpha-beta'),
                                     write('Quelle heuristique voulez-vous choisir pour le joueur '),write(Player),writeln(' :'),
                                     read(Input),nl,
                                     ((Input =< 4, Input >= 0) ->  Heuristic is Input;
                                     write('Nombre invalide, veuillez le resaisir.'),askForHeuristic(Heuristic)).

%% -- Set initial game --
init(GameHeight,1,Heuristic1) :- init(GameHeight,1,0,Heuristic1).
init(GameHeight,2) :- init(GameHeight,2,0,0).

init(GameHeight,NbOfPlayers,Heuristic0,Heuristic1) :- 
                                                      GameHeight mod 2 =:= 0,
                                                      [board],
                                                      [move],
                                                      [transformBoard],
                                                      [heuristics],
                                                    
                                                      %% - Cancel previous settings
                                                      retractall(isHuman(_)),
                                                      retractall(maxL(_)),
                                                      retractall(maxC(_)),
                                                      retractall(board(_)),
                                                      retractall(heuristic(_,_)),

                                                      %% - Set parameters for the game
                                                      (NbOfPlayers >= 1 -> assert(isHuman(0)) ; true),
                                                      (NbOfPlayers =:= 2 -> assert(isHuman(1)) ; true),
                                                      assert(maxL(GameHeight)),
                                                      assert(maxC(GameHeight)),
                                                      makeMatrix(GameHeight,Mat),
                                                      assert(heuristic(0,Heuristic0)),
                                                      assert(heuristic(1,Heuristic1)),
                                                      assert(depth(3)),
                                                      assert(no_output(0)),
                                                    
                                                      putInitialsDisks(GameHeight, Mat),
                                                      assert(board(Mat)),
                                                      
                                                      displayPlayersInfo().

%% -- Set initial game board with the regular 4 disks --
putInitialsDisks(GameHeight, Mat):-
                                Index1 is GameHeight / 2,
                                Index2 is 1 + GameHeight / 2,
                                diskAt(Mat,Index1,Index1,0),
                                diskAt(Mat,Index1,Index2,1),
                                diskAt(Mat,Index2,Index1,1),
                                diskAt(Mat,Index2,Index2,0).


%% --- PLAY ---

displayPlayerInfo() :- no_output(1), !.

displayPlayersInfo() :-
    (isHuman(0) -> write('Le joueur 0 est humain.'), nl, assert(isHuman(0)) ; heuristic(0,Heuristic0), displayIAInfo(0, Heuristic0)),
    (isHuman(1) -> write('Le joueur 1 est humain.'), nl, assert(isHuman(1)) ; heuristic(1,Heuristic1), displayIAInfo(1, Heuristic1)).

displayIAInfo(PlayerNumber,HeuristicNumber) :-
    write('Le joueur '), write(PlayerNumber), write(' est une IA avec l\'heuristique '),
    (HeuristicNumber is 0) -> write('naïve'), write('.'),nl;
    (HeuristicNumber is 1) -> write('aléatoire'), write('.'),nl;
    (HeuristicNumber is 2) -> write('basique'), write('.'),nl;
    (HeuristicNumber is 3) -> write('minimax'), write('.'),nl;
    (HeuristicNumber is 4) -> write('minimax avec élaguage alpha-béta'), write('.'),nl.

%% -- Play the game : stop when a human must play --
play() :- board(Board), play(Board,0,_).

play(Player) :- board(Board), play(Board,Player,_).

play(Player,Result) :- board(Board), play(Board,Player,Result).

play(Board,Player,Result) :- canPlay(Board,Player),
                             displayGame(Board,Player),
                             chooseMove(Board,Player,Move),
                             applyMove(Move,Player,Board,NewBoard),
                             nextPlayer(NewBoard,Player,NextPlayer),
                             !,play(NewBoard,NextPlayer,Result).

play(Board,Player,_) :- canPlay(Board,Player),writeln("Bug durant le déroulement d'un tour"),!,fail.
play(Board,_,Result) :- displayFinalGame(Board),winner(Board,Result),!,announce(Result),!.


%% -- Display game board
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

%% -- Choose move --
chooseMove(Board,Player,Move) :- (isHuman(Player) -> chooseMoveHuman(Board,Player,Move); chooseMoveAI(Board,Player,Move)).

%% - Human move: must check if enable
chooseMoveHuman(Board,Player,Move) :- allMoves(Board,Player,Moves),
                                      write('Liste des coups disponibles : '),write(Moves),nl,
                                      write('Choisissez un coup : '),nl,
                                      askForMove(Move,Moves),
                                      write('Vous avez choisi le coup ['),write(Move),write(']'),nl.

askForMove((MoveL,MoveC),Moves) :- write('L : '),read(InputL),nl,
                                   write('C : '),read(InputC),nl,
                                   (moveIsLegal((InputL,InputC),Moves) -> MoveL is InputL, MoveC is InputC;
                                   write('Coup non valide, veuillez réiterer la saisie.'),nl,askForMove((MoveL,MoveC),Moves)).

moveIsLegal(Move,[Move|_]).
moveIsLegal(Move,[_|RestOfMoves]):- moveIsLegal(Move,RestOfMoves).

% - AI move: play according to heuristics -
chooseMoveAI(Board,Player,Move) :- heuristic(Player,Heuristic), chooseMoveAI(Board,Player,Move,Heuristic), !.
chooseMoveAI(Board,Player,Move,0) :- allMoves(Board,Player,Moves),nth1(1,Moves,Move).
chooseMoveAI(Board,Player,Move,1) :- allMoves(Board,Player,Moves),randomChoose(Moves,Move).
chooseMoveAI(Board,Player,Move,2) :- allMoves(Board,Player,Moves),simpleChoose(Moves,Player,Board,Move).
chooseMoveAI(Board,Player,Move,3) :- allMoves(Board,Player,Moves),depth(Depth),minimaxChoose(Moves,Player,Board,Depth,Move).
chooseMoveAI(Board,Player,Move,4) :- allMoves(Board,Player,Moves),depth(Depth),alphaBetaChoose(Moves,Player,Board,Depth,Move).

%% -- Apply move --
applyMove((X,Y),Player,Board,NewBoard) :- replace(Board,ModifBoard,1,X,Y,Player),
                                          transformBoard((X,Y),Player,ModifBoard,NewBoard).

%% -- Next player -- 
canPlay(Board,Player) :- move(Board,Player,_),!.
nextPlayer(_,Actual,Next) :- Next is 1-Actual.


%% -- Get winner of the game --
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

%% -- Announce results --
announce(_) :- no_output(1), !.
announce(Result):- write("Et le gagnant est ... le joueur "),write(Result),write(" !"),nl.
