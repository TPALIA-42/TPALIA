% tests unitaires des predicats simples

run :-
        runJ,
        runMIL,
        runCTD,
        runCP,
        runNP.
        
runJ :- 
        [main],
        init(8,0,0,0),
        board(Board),
        
        nl,write("Test judge"),nl,
        
        write("J0 a 10 pieces et J1 3, J0 gagne : "),(judge(10,3,0) -> write("Succ") ; write("Fail")), nl,
        write("J0 a 3 pieces et J1 10, J1 gagne : "),(judge(3,10,1) -> write("Succ") ; write("Fail")), nl,
        write("J0 a 10 pieces et J1 10, egalite : "),(judge(10,10,2) -> write("Succ") ; write("Fail")), nl.

runMIL :-
        [main],
        init(8,0,0,0),
        board(Board),
        
        nl,write("Test moveIsLegal"),nl,

        allMoves(Board,0,MovesP0),
        allMoves(Board,1,MovesP1),
        write("Dans la configuration de base : "),nl,
        write("J0 peut placer un pion en (5,3) : "),(moveIsLegal((5,3),MovesP0) -> write("Succ") ; write("Fail")), nl,
        write("J0 peut placer un pion en (6,4 : )"),(moveIsLegal((6,4),MovesP0) -> write("Succ") ; write("Fail")), nl,
        write("J0 ne peut pas placer un pion en (3,4) : "),(moveIsLegal((3,4),MovesP0) -> write("Fail") ; write("Succ")), nl,
        write("J0 ne peut pas placer un pion en (4,3) : "),(moveIsLegal((4,3),MovesP0) -> write("Fail") ; write("Succ")), nl,
        
        write("J0 ne peut pas placer un pion en (2,2) : "),(moveIsLegal((2,2),MovesP0) -> write("Fail") ; write("Succ")), nl,
        write("J0 ne peut pas placer un pion en (7,1) : "),(moveIsLegal((7,1),MovesP0) -> write("Fail") ; write("Succ")), nl,
        write("J0 ne peut pas placer un pion en (5,7) : "),(moveIsLegal((5,7),MovesP0) -> write("Fail") ; write("Succ")), nl,
        write("J0 ne peut pas placer un pion en (3,3) : "),(moveIsLegal((3,3),MovesP0) -> write("Fail") ; write("Succ")), nl,nl,
        
        write("J1 peut placer un pion en (3,4) : "),(moveIsLegal((3,4),MovesP1) -> write("Succ") ; write("Fail")), nl,
        write("J1 peut placer un pion en (4,3) : "),(moveIsLegal((4,3),MovesP1) -> write("Succ") ; write("Fail")), nl,
        write("J1 ne peut pas placer un pion en (3,5) : "),(moveIsLegal((3,5),MovesP1) -> write("Fail") ; write("Succ")), nl,
        write("J1 ne peut pas placer un pion en (4,6) : "),(moveIsLegal((4,6),MovesP1) -> write("Fail") ; write("Succ")), nl.
        
runCTD :-
        [main],
        init(8,0,0,0),
        board(Board),

        nl,write("Test countTotalDisk"),nl,
        
        write("J0 possede 2 pions dans la configuration de base : "),(countTotalDisk(Board,0,2) -> write("Succ") ; write("Fail")), nl,
        write("J1 possede 2 pions dans la configuration de base : "),(countTotalDisk(Board,1,2) -> write("Succ") ; write("Fail")), nl,
        
        applyMove((5,3),0,Board,Board1),
        applyMove((3,4),1,Board1,Board2),
        applyMove((4,6),0,Board2,Board3),
        
        write("Après que J0 ait joué le move (5,3), J1 le move (3,4) et J0 le move (4,6) : "),nl,
        write("J0 possede 6 pions : "),(countTotalDisk(Board3,0,6) -> write("Succ") ; write("Fail")), nl,
        write("J1 possede 1 pions : "),(countTotalDisk(Board3,1,1) -> write("Succ") ; write("Fail")), nl.
        
runCP :- 
        [main],
        init(8,0,0,0),
        board(Board),
        
        nl,write("Test canPlay"),nl,
        
        write("J0 peut jouer dans la configuration de base : "),(canPlay(Board,0) -> write("Succ") ; write("Fail")), nl,
         write("J1 peut jouer dans la configuration de base : "),(canPlay(Board,1) -> write("Succ") ; write("Fail")), nl,
        
        % Board4 est un plateau ne contenant plus de 1
        applyMove((5,3),0,Board,Board1),
        applyMove((3,4),1,Board1,Board2),
        applyMove((4,6),0,Board2,Board3),
        applyMove((2,4),0,Board3,Board4),
        
        write("Dans un plateau rempli uniquement de pieces 0 (mais pas rempli) : "),nl,
        write("J0 ne peut pas jouer : "),(canPlay(Board4,0) -> write("Fail") ; write("Succ")), nl,
        write("J1 ne peut pas jouer : "),(canPlay(Board4,1) -> write("Fail") ; write("Succ")), nl.
        
runNP :-
        [main],
        init(8,0,0,0),
        board(Board),
        
        nl,write("Test nextPlayer"),nl,
        
        write("Le joueur jouant après J0 est J1 : "),(nextPlayer(0,1) -> write("Succ") ; write("Fail")), nl,
        write("Le joueur jouant après J1 est J0 : "),(nextPlayer(1,0) -> write("Succ") ; write("Fail")), nl.

        
