%% --- INIT ---

%% -- Naïve initialization : ask for game parameters to the user
%% > init/0
init :-
    askForGameHeight(GameHeight),
    askForNumberOfPlayers(HumanPlayersNumber),
    (HumanPlayersNumber < 2 -> askForHeuristic(1,Heuristic1) ; Heuristic1 is 0),
    (HumanPlayersNumber =:= 0 -> askForHeuristic(0,Heuristic0) ; Heuristic0 is 0),
    init(GameHeight,HumanPlayersNumber,Heuristic0,Heuristic1).

%% -- Presetted init for a one-AI-game
%% > init/3 : +GameHeight, 1, Heuristic
init(GameHeight,1,Heuristic1) :- init(GameHeight,1,0,Heuristic1).

%% -- Presetted init for a-two-AI-game
%% > init/2 : +GameHeight, 2
init(GameHeight,2) :- init(GameHeight,2,0,0).

%% -- Real initialization of game: import files, prepare board and launch game
%% > init/4 : +GameHeight, +HumanPlayersNumber, +Heuristic0, +Heuristic1
init(GameHeight,HumanPlayersNumber,Heuristic0,Heuristic1) :- 
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
    (HumanPlayersNumber >= 1 -> assert(isHuman(0)) ; true),
    (HumanPlayersNumber =:= 2 -> assert(isHuman(1)) ; true),
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

%% - Set initial game board with the regular 4 disks -
%% > putInitialsDisks/2 : +GameHeight, -Mat
putInitialsDisks(GameHeight,Mat):-
    Index1 is GameHeight / 2,
    Index2 is 1 + GameHeight / 2,
    diskAt(Mat,Index1,Index1,0),
    diskAt(Mat,Index1,Index2,1),
    diskAt(Mat,Index2,Index1,1),
    diskAt(Mat,Index2,Index2,0).


%% -- Naïve initialization need parameters managament --

%% - Ask size of game board: must be even -
%% > askForGameHeight/1 : -GameHeight
askForGameHeight(GameHeight) :- 
    write('Saisir la taille du jeu : '),
    read(Input),nl,
    (Input mod 2 =:= 0 -> GameHeight is Input,!;
    var(GameHeight),write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

%% - Ask number of human players -
%% > askForHumanPlayersNumber/1 : -HumanPlayersNumber
askForNumberOfPlayers(HumanPlayersNumber) :- 
    write('Saisir le nombre de joueurs humains (0, 1 ou 2) : '),
    read(Input),nl,
    ((Input =< 2, Input >= 0) ->  HumanPlayersNumber is Input;
    write('Nombre invalide, veuillez le resaisir.'),askForNumberOfPlayers(HumanPlayersNumber)).

%% - Ask for the heuristic for the AI Player -
%% > askForHeuristic/2 : +Player, -HeuristicNumber
askForHeuristic(Player,HeuristicNumber) :- 
    writeln('Liste des heuristiques :'),
    writeln('- 0. Coup en haut à gauche'),
    writeln('- 1. Aléatoire'),
    writeln('- 2. Basique'),
    writeln('- 3. Minimax'),
    writeln('- 4. Minimax avec élagage alpha-beta'),
    write('Quelle heuristique voulez-vous choisir pour le joueur '),write(Player),writeln(' :'),
    read(Input),nl,
    ((Input =< 4, Input >= 0) ->  HeuristicNumber is Input;
    write('Nombre invalide, veuillez le resaisir.'),askForHeuristic(HeuristicNumber)).


%% --- PLAY ---

%% -- Display information at the game launching: nature of players and their heuristics.
displayPlayerInfo() :- no_output(1), !.

displayPlayersInfo() :-
    (isHuman(0) -> write('Le joueur 0 est humain.'), nl, assert(isHuman(0)) ; heuristic(0,Heuristic0), displayIAInfo(0, Heuristic0)),
    (isHuman(1) -> write('Le joueur 1 est humain.'), nl, assert(isHuman(1)) ; heuristic(1,Heuristic1), displayIAInfo(1, Heuristic1)).

displayIAInfo(PlayerNumber,HeuristicNumber) :-
    write('Le joueur '), write(PlayerNumber), write(' est une IA avec l\'heuristique '),
    (HeuristicNumber is 0) -> write('naïve.'), nl;
    (HeuristicNumber is 1) -> write('aléatoire.'), nl;
    (HeuristicNumber is 2) -> write('basique.'), nl;
    (HeuristicNumber is 3) -> write('minimax.'), nl;
    (HeuristicNumber is 4) -> write('minimax avec élaguage alpha-béta'),nl.

%% -- Play the game : stop when a human must play --

%% - Easy launching -
%% > play/0
play() :- board(Board), play(Board,0,_).

%% - Play for evaluation: board not available - 
%% > play/2 : +Player, -Result
play(Player,Result) :- board(Board), play(Board,Player,Result).

%% - Real play procedure : check if enable, display board and advance to next opponent turn
%% play/3 : +Board, +Player, -Result
play(Board,Player,Result) :- 
    canPlay(Board,Player),
    displayGame(Board,Player),
    chooseMove(Board,Player,Move),
    applyMove(Move,Player,Board,NewBoard),
    nextPlayer(Player,NextPlayer),
    !,play(NewBoard,NextPlayer,Result).

%% - End cases: error during game or game ended -
play(Board,Player,_) :- canPlay(Board,Player),writeln("Bug durant le déroulement d'un tour"),!,fail.
play(Board,_,Result) :- displayFinalGame(Board),winner(Board,Result),!,announce(Result),!.

%% -- Check if player can move --
%% canPlay/2 : +Board, +Player
canPlay(Board,Player) :- move(Board,Player,_),!.

%% -- Choose move: decide wheter it is a human or an AI move --
%% > chooseMove/2 : +Board, +Player, -Move
chooseMove(Board,Player,Move) :- (isHuman(Player) -> chooseMoveHuman(Board,Player,Move); chooseMoveAI(Board,Player,Move)).

%% - Human move: must check if enable
%% > chooseMoveHuman/3 :  +Board, +Player, -Move
chooseMoveHuman(Board,Player,Move) :- 
    allMoves(Board,Player,Moves),
    write('Liste des coups disponibles : '),write(Moves),nl,
    write('Choisissez un coup : '),nl,
    askForMove(Move,Moves),
    write('Vous avez choisi le coup ['),write(Move),write(']'),nl.

%% > askForMove/2 : +Move, +Moves
askForMove((MoveL,MoveC),Moves) :-
    write('L : '),read(InputL),nl,
    write('C : '),read(InputC),nl,
    (moveIsLegal((InputL,InputC),Moves) -> MoveL is InputL, MoveC is InputC;
    write('Coup non valide, veuillez réiterer la saisie.'),nl,askForMove((MoveL,MoveC),Moves)).

%% > moveIsLegal/2 : +Move, -Moves
moveIsLegal(Move,[Move|_]).
moveIsLegal(Move,[_|RestOfMoves]):- moveIsLegal(Move,RestOfMoves).

%% - AI move: play according to heuristics -
%% > chooseMoveAI/3 : +Board, +Player, -Move
%% > chooseMoveAI/4 : +Board, +Player, -Move, 0-4
chooseMoveAI(Board,Player,Move) :- heuristic(Player,Heuristic), chooseMoveAI(Board,Player,Move,Heuristic), !.
chooseMoveAI(Board,Player,Move,0) :- allMoves(Board,Player,Moves),naiveAI(Moves,Move).
chooseMoveAI(Board,Player,Move,1) :- allMoves(Board,Player,Moves),randomChoose(Moves,Move).
chooseMoveAI(Board,Player,Move,2) :- allMoves(Board,Player,Moves),simpleChoose(Moves,Player,Board,Move).
chooseMoveAI(Board,Player,Move,3) :- allMoves(Board,Player,Moves),depth(Depth),minimaxChoose(Moves,Player,Board,Depth,Move).
chooseMoveAI(Board,Player,Move,4) :- allMoves(Board,Player,Moves),depth(Depth),alphaBetaChoose(Moves,Player,Board,Depth,Move).

%% -- Apply move --
%% > applyMove/4 : +Move, +Player, +Board, -NewBoard
applyMove((X,Y),Player,Board,NewBoard) :- 
    replace(Board,ModifBoard,1,X,Y,Player),
    transformBoard((X,Y),Player,ModifBoard,NewBoard).

%% -- Next player --
%% > nextPlayer/2: +Actual, -Next
nextPlayer(Actual,Next) :- Next is 1-Actual.


%% -- Get winner of the game --
%% > winner/2 : +Board, -Result
winner(Board,Result) :- 
    countTotalDisk(Board,0,N1),
    countTotalDisk(Board,1,N2),
    judge(N1,N2,Result).

%% -- Disks counting for players --
countTotalDisk(Board,Player,N) :- caculate(Board,Player,0,N).
caculate([L|Remaining],Player,NbActuel,N) :- countTotalList(L,Player,0,NList),NbNew is NbActuel+NList,caculate(Remaining,Player,NbNew,N).
caculate([],_,V,V).
countTotalList([X|L],Player,NbNow,NList) :- nonvar(X),X=:=Player,!,NewNb is NbNow+1,countTotalList(L,Player,NewNb,NList).
countTotalList([_|L],Player,NbNow,NList) :- countTotalList(L,Player,NbNow,NList).
countTotalList([],_,V,V).

%% -- Decide who has won --
judge(X,Y,0) :- X > Y.
judge(X,Y,1) :- X < Y.
judge(_,_,2).

%% -- Announce results --
announce(_) :- no_output(1), !.
announce(Result):- write("Et le gagnant est ... le joueur "),write(Result),write(" !"),nl.
