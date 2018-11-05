

%countList([X|L],NbNow,NList) :- nonvar(X),!,NewNb is NbNow+1,countList(L,NewNb,NList).
%countList([_|L],NbNow,NList) :- countList(L,NbNow,NList).
%countList([],V,V).




transformBoard((IndexL,IndexC),Player,Board,NewBoard) :- bagof((DL,DC),direction(DL,DC),Directions), transformBoard((IndexL,IndexC),Directions,Player,Board,NewBoard).

transformBoard(_,[],_,Board,Board) :- !.
transformBoard((IndexL,IndexC),[D|Remaining],Player,Board,NewBoard) :- transform((IndexL,IndexC),D,Player,[],Board,BoardInter),
                                                                       transformBoard((IndexL,IndexC),Remaining,Player,BoardInter,NewBoard).

changeList(B,B,[],_).
changeList(Board,NewBoard,[(IndexL,IndexC)|L],Player) :- replace(Board,ModifBoard,1,IndexL,IndexC,Player),changeList(ModifBoard,NewBoard,L,Player).

replace([X|L1],[X|L2],Pos,IndexL,IndexC,Player) :- Pos =\= IndexL,!,NewPos is Pos+1,replace(L1,L2,NewPos,IndexL,IndexC,Player).
replace([X|L1],[Y|L2],Pos,IndexL,IndexC,Player) :- replaceDisk(X,Y,1,IndexC,Player),
NewPos is Pos+1,replace(L1,L2,NewPos,IndexL,IndexC,Player).
replace([],[],_,_,_,_).

replaceDisk([D|L1],[D|L2],Pos,IndexC,Player) :- Pos =\= IndexC,!,NewPos is Pos+1,replaceDisk(L1,L2,NewPos,IndexC,Player).
replaceDisk([_|L1],[Player|L2],Pos,IndexC,Player) :- NewPos is Pos+1,replaceDisk(L1,L2,NewPos,IndexC,Player).
replaceDisk([],[],_,_,_).

transform((IndexL,IndexC),(DirectionL,DirectionC),_,_,Board,Board) :- NewIndexL is (IndexL+DirectionL),
                                    NewIndexC is (IndexC+DirectionC),
                                    (not(insideBoard(NewIndexL,NewIndexC));
                                    diskAt(Board,NewIndexL,NewIndexC,Disk),
                                    var(Disk)),!.
transform((IndexL,IndexC),(DirectionL,DirectionC),Player,L,Board,NewBoard) :- NewIndexL is (IndexL+DirectionL),
                                    NewIndexC is (IndexC+DirectionC),
                                    insideBoard(NewIndexL,NewIndexC),
                                    diskAt(Board,NewIndexL,NewIndexC,Disk),
                                    nonvar(Disk),
                                    Disk=:=Player,
                                    changeList(Board,NewBoard,L,Player),
                                    !.
transform((IndexL,IndexC),(DirectionL,DirectionC),Player,L,Board,NewBoard) :- NewIndexL is (IndexL+DirectionL),
                                    NewIndexC is (IndexC+DirectionC),
                                    insideBoard(NewIndexL,NewIndexC),
                                    diskAt(Board,NewIndexL,NewIndexC,Disk),
                                    nonvar(Disk),
                                    Disk=:=1-Player,
                                    transform((NewIndexL,NewIndexC),(DirectionL,DirectionC),Player,[(NewIndexL,NewIndexC)|L],Board,NewBoard).
