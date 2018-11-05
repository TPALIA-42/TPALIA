%% --- Init ---
init :- askForGameHeight(GameHeight),
        askForNumberOfPlayers(NbOfPlayers),
        init(GameHeight,NbOfPlayers).

askForGameHeight(GameHeight) :- write('Saisir la taille du jeu : '),
                                read(Input),
                                nl,
                                (Input mod 2 =:= 0 -> GameHeight is Input,!;
                                var(GameHeight),write("Taille invalide, veuillez saisir un nombre pair."),nl,askForGameHeight(GameHeight)).

askForNumberOfPlayers(NbOfPlayers) :- write('Saisir le nombre de joueurs humains (0, 1 ou 2) : '),
                                      read(Input),
                                      nl,
                                      ((Input =< 2, Input >= 0) ->  NbOfPlayers is Input;
                                      write('Nombre invalide, veuillez le resaisir.'),askForNumberOfPlayers(NbOfPlayers)).

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

%% https://stackoverflow.com/questions/2261238/random-items-in-prolog
%% choose(List, Elt) - chooses a random element
%% in List and unifies it with Elt.
choose([], []).
choose(List, Elt) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, Elt).

%% --- MinMax heuristic ---
evaluateAndChoose([Move|Moves],Player,Board,OriginalBoard,Counter,Depth,MaxMin,Record,Best) :-
                                applyMove(Move,Player,Board,NewBoard),
                                minimax(Depth,Player,NewBoard,OriginalBoard,MaxMin,MoveX,Value),
                                update(Move,Value,Record,NewRecord,MaxMin,Counter),
                                NewCounter is Counter+1,
                                evaluateAndChoose(Moves,Player,Board,OriginalBoard,NewCounter,Depth,MaxMin,NewRecord,Best).
evaluateAndChoose([],_,_,_,_,_,_,Record,Record) :- !.

minimax(D,Player,Board,OriginalBoard,MaxMin,Move,Value) :- D > 0,
                                NewPlayer is 1-Player,
                                D1 is D-1,
                                MinMax is -1*MaxMin,
                                setof(M,move(Board,Player,M),Moves),
                                !,
                                evaluateAndChoose(Moves,NewPlayer,Board,OriginalBoard,0,D1,MinMax,(nil,-1000),(Move,Value)).

minimax(_,Player,Board,OriginalBoard,MaxMin,nil,Value) :- value(Player,Board,OriginalBoard,0,V),Value is V*MaxMin,!.

%% ---AlphaBeta heuristic ---
evaluateAndChoose([Move|Moves], Player, Board, OriginalBoard, Counter, Depth, Alpha, Beta, Move1, BestMove) :-
    applyMove(Move, Player, Board, NewBoard),
    NewPlayer is 1 - Player,
    alphaBeta(Depth, NewPlayer, NewBoard, OriginalBoard, Alpha, Beta, MoveX, Value),
    NewValue is -Value,
    NewCounter is Counter + 1,
    cutoff(Move, NewValue, NewCounter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, BestMove).

evaluateAndChoose([],_,_,_,_,_,Alpha,_,Move,(Move,Alpha)).

alphaBeta(Depth, Player, Board, OriginalBoard, Alpha, Beta, Move, Value):-
    Depth > 0,
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    NewDepth is Depth-1,
    setof(M,move(Board,Player,M),Moves),
    !,
    evaluateAndChoose(Moves, Player, Board, OriginalBoard, 0, NewDepth, Alpha1, Beta1, nil, (Move, Value)).

alphaBeta(_, Player, Board, OriginalBoard, Alpha, Beta, Move, Value):-
    value(Player, Board, OriginalBoard, 0, Value), !.

cutoff(Move, Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, (Move, Value)):-
    Value >= Beta.

cutoff(Move, Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, BestMove):-
    Alpha < Value, Value < Beta,
    evaluateAndChoose(Moves, Player, NewBoard, OriginalBoard, Counter, Depth, Value, Beta, Move, BestMove).

cutoff((MoveL,MoveC), Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, (Move1L,Move1C), BestMove):-
    Value =:= Alpha, nonvar(Move1L), nonvar(Move1C), (MoveL > Move1L;(MoveL =:= Move1L, MoveC > Move1C)),
    evaluateAndChoose(Moves, Player, NewBoard, OriginalBoard, Counter, Depth, Alpha, Beta, (MoveL, MoveC), BestMove).
    
cutoff(Move, Value, Counter, Depth, Alpha, Beta, Moves, Player, NewBoard, OriginalBoard, Move1, BestMove):-
    Value =< Alpha,
    evaluateAndChoose(Moves, Player, NewBoard, OriginalBoard, Counter, Depth, Alpha, Beta, Move1, BestMove).




update(Move,Value,_,(Move,Value),_,0) :- !.

update((MoveL,MoveC),Value,((Move1L,Move1C),Value1),((MoveL,MoveC),Value),1,_) :- Value =:= Value1, (MoveL > Move1L;(MoveL =:= Move1L, MoveC > Move1C)).
update(Move,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =:= Value1.

update(Move,Value,(Move1,Value1),(Move1,Value1),1,_) :- Value =< Value1.
update(Move,Value,(Move1,Value1),(Move,Value),1,_) :- Value > Value1.
update(Move,Value,(Move1,Value1),(Move,Value),-1,_) :- Value < Value1.
update(Move,Value,(Move1,Value1),(Move1,Value1),-1,_) :- Value >= Value1.

value(Player,[X|L],[OX|OL],VStart,V) :- compare(Player,X,OX,0,N),NewStart is N+VStart,value(Player,L,OL,NewStart,V).
value(_,[],[],V,V).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= Player,OE =:= 1-Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= 1-Player,OE =:= Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),nonvar(OE),E =:= OE,compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- var(E),var(OE),compare(Player,L,OL,TempN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= Player,NewN is TempN+1,compare(Player,L,OL,NewN,N).
compare(Player,[E|L],[OE|OL],TempN,N) :- nonvar(E),var(OE),E =:= 1-Player,NewN is TempN-1,compare(Player,L,OL,NewN,N).
compare(_,[],[],N,N) :- !.


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
