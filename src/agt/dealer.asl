// Agent dealer in project the_pit_game

/* Initial beliefs and rules */
cartas(milho,9,20).
cartas(feijao,9,30).
cartas(trigo,9,40).

tipos([milho,feijao,trigo]).

/* Initial goals */
distribuir([player1,player2,player3]).

/* Plans */
// Distribuir cartas para os players 
+distribuir([H|T]) : true
	<-  ?tipos(L); 
		.length(L, Size); 
		jia.random_int(I,Size);
		.nth(I,L,Tipo);
		.send(H, achieve, receber_cartas(Tipo,1));
		?cartas(Tipo,Tanto,Valor);
		-cartas(Tipo,Tanto,Valor);
		+cartas(Tipo,Tanto-1,Valor);
		.print("Tenho ", Tanto, " cartas do tipo ", Tipo);
		-+distribuir(T).

+distribuir([]) : cartas(_,Qtd,_) & Qtd > 1
	<- -+distribuir([player1,player2,player3]).
	
+distribuir([]) : cartas(milho,0,_) & cartas(feijao,0,_) & cartas(trigo,0,_)
    <- .print("DISTRIBUIÇÃO FINALIZADA");
       .broadcast(achieve, iniciar).	
	
// Pra fazer iteracão
//+distribuir([]) : cartas(milho, 0) & cartas(feijao,0) & cartas(trigo,0)
//     <- .print("INICIANDO UMA NOVA RODADA");
//       -cartas(milho,0);
//       +cartas(milho,9);
//       -cartas(feijao,0);
//       +cartas(feijao,9);
//       -cartas(trigo,0);
//       +cartas(trigo,9);
//       -tipos([]);
//       +tipos([milho,feijao,trigo]);
//       .broadcast(achieve, reiniciar);
//       .wait(5000);
//       
//       -+distribuir([player1,player2,player3]).


// Quando todas as cartas de um tipo são distribuidas
+cartas(Tipo,0,_) : tipos(L)
    <- .delete(Tipo, L, NL);
       -tipos(L);
       +tipos(NL).       		

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
