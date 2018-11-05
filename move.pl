direction(-1,0).
direction(1,0).
direction(0,-1).
direction(0,1).
direction(-1,-1).
direction(1,1).
direction(-1,1).
direction(1,-1).

move(Board,Player,Move) :- diskAt(Board,IndexL,IndexC,Disk),nonvar(Disk),Disk=:=Player,direction(DL,DC),move(Board,(IndexL,IndexC),Player,(DL,DC),0,Move).

move(Board,(IndexL,IndexC),_,(DirectionL,DirectionC),Counter,(MoveL,MoveC)) :- Counter > 0,
                                                                               MoveL is (IndexL+DirectionL),
                                                                               MoveC is (IndexC+DirectionC),
                                                                               insideBoard(MoveL,MoveC),
                                                                               diskAt(Board,MoveL,MoveC,Disk),
                                                                               var(Disk).
move(Board,(IndexL,IndexC),Player,(DirectionL,DirectionC),Counter,Move) :- NewIndexL is (IndexL+DirectionL),
                                                                           NewIndexC is (IndexC+DirectionC),
                                                                           insideBoard(NewIndexL,NewIndexC),
                                                                           diskAt(Board,NewIndexL,NewIndexC,Disk),
                                                                           nonvar(Disk),
                                                                           Disk=:=1-Player,
                                                                           move(Board,(NewIndexL,NewIndexC),Player,(DirectionL,DirectionC),Counter+1,Move).

allMoves(Board,Player,Moves) :- setof(M,move(Board,Player,M),Moves).
allMoves(Board,Player,[]).
