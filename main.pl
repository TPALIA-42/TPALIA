
start:- init,board(B),displayGame(B,1).
displayGame(L,Player) :- writeln('*----------------*'),!,affiche(L,Player).
affiche([X|L],Player) :- println(X),nl,affiche(L,Player).
affiche([],Player) :- writeln('*----------------*'),!.

println([]).
println([X|L]) :- var(X),write('? '),!,println(L).
println([X|L]) :- write(X),write(' '),!,println(L).

move(Board,0,Result) :- zero(Coord),vertical(Board,Coord,0,Result).
move(Board,0,Result) :- zero(Coord),horizontal(Board,Coord,0,Result).
move(Board,0,Result) :- zero(Coord),slash(Board,Coord,0,Result).
move(Board,0,Result) :- zero(Coord),antiSlash(Board,Coord,0,Result).
move(Board,1,Result) :- one(Coord),vertical(Board,Coord,1,Result).
move(Board,1,Result) :- one(Coord),horizontal(Board,Coord,1,Result).
move(Board,1,Result) :- one(Coord),slash(Board,Coord,1,Result).
move(Board,1,Result) :- one(Coord),antiSlash(Board,Coord,1,Result).


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

:- [defDirection].
											

init :- assert(maxL(8)),
		assert(maxC(8)),
		length(L1,8),
        length(L2,8),
        length(L3,8),
        length(L4,8),
        length(L5,8),
        length(L6,8),
        length(L7,8),
        length(L8,8),
        nth1(4,L4,1),
        nth1(5,L4,0),
        nth1(4,L5,0),
		nth1(5,L3,0),
		nth1(5,L2,0),
        nth1(5,L5,1),
		nth1(4,L6,0),
		nth1(4,L7,0),
        nth1(4,L8,1),
		nth1(6,L3,1),
        assert(dynamic board/1),
		[assertion],
		initassert,
        assert(board([L1,L2,L3,L4,L5,L6,L7,L8])).
