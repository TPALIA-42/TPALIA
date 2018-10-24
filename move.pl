countMoves(Board,Player,Number) :- setof(M,move(Board,Player,M),Moves),count(Moves,0,Number).
count([X|L],N,Number) :- NewN is N+1, count(L,NewN,Number).
count([],N,N).


move(Board,Player,Result) :- accesElement(Board,IndexL,IndexC,Elem),nonvar(Elem),Elem=:=Player,vertical(Board,(IndexL,IndexC),Player,Result).
move(Board,Player,Result) :- accesElement(Board,IndexL,IndexC,Elem),nonvar(Elem),Elem=:=Player,horizontal(Board,(IndexL,IndexC),Player,Result).
move(Board,Player,Result) :- accesElement(Board,IndexL,IndexC,Elem),nonvar(Elem),Elem=:=Player,slash(Board,(IndexL,IndexC),Player,Result).
move(Board,Player,Result) :- accesElement(Board,IndexL,IndexC,Elem),nonvar(Elem),Elem=:=Player,antiSlash(Board,(IndexL,IndexC),Player,Result).


accesElement(Board,IndexL,IndexC,E) :- nth1(IndexL,Board,L),
                             nth1(IndexC,L,E).
							 							 
giveValue(V,V).

vertical(Board,(IndexL,IndexC),Player,R) :- verticalUp(Board,(IndexL,IndexC),Player,0,R).
vertical(Board,(IndexL,IndexC),Player,R) :- verticalDown(Board,(IndexL,IndexC),Player,0,R).
horizontal(Board,(IndexL,IndexC),Player,R) :- horizontalLeft(Board,(IndexL,IndexC),Player,0,R).
horizontal(Board,(IndexL,IndexC),Player,R) :- horizontalRight(Board,(IndexL,IndexC),Player,0,R).
slash(Board,(IndexL,IndexC),Player,R) :- slashUp(Board,(IndexL,IndexC),Player,0,R).
slash(Board,(IndexL,IndexC),Player,R) :- slashDown(Board,(IndexL,IndexC),Player,0,R).
antiSlash(Board,(IndexL,IndexC),Player,R) :- antiSlashUp(Board,(IndexL,IndexC),Player,0,R).
antiSlash(Board,(IndexL,IndexC),Player,R) :- antiSlashDown(Board,(IndexL,IndexC),Player,0,R).

verticalUp(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexL is IndexL-1,
                                    NewIndexL > 0,
                                    accesElement(Board,NewIndexL,IndexC,E),
                                    var(E),
									giveValue((NewIndexL,IndexC),R),!.
verticalUp(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexL is IndexL-1,
                                    NewIndexL > 0,
                                    accesElement(Board,NewIndexL,IndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    verticalUp(Board,(NewIndexL,IndexC),Player,NewCounter,R).
								
verticalDown(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexL is IndexL+1,
                                    NewIndexL < 9,
                                    accesElement(Board,NewIndexL,IndexC,E),
                                    var(E),
									giveValue((NewIndexL,IndexC),R),!.
verticalDown(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexL is IndexL+1,
                                    NewIndexL < 9,
                                    accesElement(Board,NewIndexL,IndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    verticalDown(Board,(NewIndexL,IndexC),Player,NewCounter,R).

horizontalLeft(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexC is IndexC-1,
                                    NewIndexC > 0,
                                    accesElement(Board,IndexL,NewIndexC,E),
                                    var(E),
									giveValue((IndexL,NewIndexC),R),!.
horizontalLeft(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexC is IndexC-1,
                                    NewIndexC > 0,
                                    accesElement(Board,IndexL,NewIndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    horizontalLeft(Board,(IndexL,NewIndexC),Player,NewCounter,R).
											
horizontalRight(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexC is IndexC+1,
                                    NewIndexC < 9,
                                    accesElement(Board,IndexL,NewIndexC,E),
                                    var(E),
									giveValue((IndexL,NewIndexC),R),!.
horizontalRight(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexC is IndexC+1,
                                    NewIndexC < 9,
                                    accesElement(Board,IndexL,NewIndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    horizontalRight(Board,(IndexL,NewIndexC),Player,NewCounter,R).
											
slashUp(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexC is IndexC-1,
									NewIndexL is IndexL-1,
									NewIndexC > 0,
									NewIndexL > 0,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
                                    var(E),
									giveValue((NewIndexL,NewIndexC),R),!.
slashUp(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexC is IndexC-1,
									NewIndexL is IndexL-1,
									NewIndexC > 0,
									NewIndexL > 0,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    slashUp(Board,(NewIndexL,NewIndexC),Player,NewCounter,R).
											
slashDown(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexC is IndexC+1,
									NewIndexL is IndexL+1,
									NewIndexC < 9,
									NewIndexL < 9,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
                                    var(E),
									giveValue((NewIndexL,NewIndexC),R),!.
slashDown(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexC is IndexC+1,
									NewIndexL is IndexL+1,
									NewIndexC < 9,
									NewIndexL < 9,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    slashDown(Board,(NewIndexL,NewIndexC),Player,NewCounter,R).
											
antiSlashUp(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexC is IndexC+1,
									NewIndexL is IndexL-1,
									NewIndexC < 9,
									NewIndexL > 0,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
                                    var(E),
									giveValue((NewIndexL,NewIndexC),R),!.
antiSlashUp(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexC is IndexC+1,
									NewIndexL is IndexL-1,
									NewIndexC < 9,
									NewIndexL > 0,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    antiSlashUp(Board,(NewIndexL,NewIndexC),Player,NewCounter,R).
											
antiSlashDown(Board,(IndexL,IndexC),Player,Counter,R) :- Counter > 0,
                                    NewIndexC is IndexC-1,
									NewIndexL is IndexL+1,
									NewIndexC > 0,
									NewIndexL < 9,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
                                    var(E),
									giveValue((NewIndexL,NewIndexC),R),!.
antiSlashDown(Board,(IndexL,IndexC),Player,Counter,R) :- NewIndexC is IndexC-1,
									NewIndexL is IndexL+1,
									NewIndexC > 0,
									NewIndexL < 9,
                                    accesElement(Board,NewIndexL,NewIndexC,E),
									nonvar(E),
                                    E=:=1-Player,
                                    NewCounter is Counter+1,
                                    antiSlashDown(Board,(NewIndexL,NewIndexC),Player,NewCounter,R).