%% --- PLAY ---
%% -- Easy launching --
%% > play/0
play() :- board(Board), play(Board,0,_).

%% -- Play for evaluation: board not yet available -- 
%% > play/2 : +Player, -Result
play(Player,Result) :- board(Board), play(Board,Player,Result).

%% -- Real play procedure : check if enable, display board and advance to next opponent turn --
%% > play/3 : +Board, +Player, -Result
play(Board,Player,Result) :- 
    canPlay(Board,Player),
    displayGame(Board,Player),
    chooseMove(Board,Player,Move),
    applyMove(Move,Player,Board,NewBoard),
    nextPlayer(Player,NextPlayer),
    !,play(NewBoard,NextPlayer,Result).

%% -- End cases: error during game or game ended --
play(Board,Player,_) :- canPlay(Board,Player),writeln("Bug durant le déroulement d'un tour"),!,fail.
play(Board,_,Result) :- displayFinalGame(Board),winner(Board,Result),!,announce(Result),!.

%% -- Check if player can move --
%% > canPlay/2 : +Board, +Player
canPlay(Board,Player) :- move(Board,Player,_),!.

%% -- Choose move: decide wheter it is a human or an AI move --
%% > chooseMove/3 : +Board, +Player, -Move
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