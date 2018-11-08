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
    [play],

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
    assert(depth2(4)),
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
    writeln('- 5. Minimax avec élagage alpha-beta profondeur accrue'),
    write('Quelle heuristique voulez-vous choisir pour le joueur '),write(Player),writeln(' :'),
    read(Input),nl,
    ((Input =< 5, Input >= 0) ->  HeuristicNumber is Input;
    write('Nombre invalide, veuillez le resaisir.'),askForHeuristic(HeuristicNumber)).


%% -- Display information at the game launching: nature of players and their heuristics.
displayPlayersInfo() :- no_output(1), !.

displayPlayersInfo() :-
    (isHuman(0) -> write('Le joueur 0 est humain.'), nl, assert(isHuman(0)) ; heuristic(0,Heuristic0), displayIAInfo(0, Heuristic0)),
    (isHuman(1) -> write('Le joueur 1 est humain.'), nl, assert(isHuman(1)) ; heuristic(1,Heuristic1), displayIAInfo(1, Heuristic1)).

displayIAInfo(PlayerNumber,HeuristicNumber) :-
    write('Le joueur '), write(PlayerNumber), write(' est une IA avec l\'heuristique '),
    (HeuristicNumber is 0) -> write('naïve.'), nl;
    (HeuristicNumber is 1) -> write('aléatoire.'), nl;
    (HeuristicNumber is 2) -> write('basique.'), nl;
    (HeuristicNumber is 3) -> write('minimax.'), nl;
    (HeuristicNumber is 4) -> write('minimax avec élaguage alpha-béta'),nl;
    (HeuristicNumber is 5) -> write('minimax avec élaguage alpha-béta profondeur accrue'),nl.
