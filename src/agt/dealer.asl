// Agent dealer in project the_pit_game

/* Initial beliefs and rules */
cartas(milho,9,60).
cartas(feijao,9,80).
cartas(trigo,9,100).

tipos([milho,feijao,trigo]).

/* Initial goals */
distribuir([player_abilio,player_romario,player_leandro]).

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
	<- -+distribuir([player_abilio,player_romario,player_leandro]).
	
+distribuir([]) : cartas(milho,0,_) & cartas(feijao,0,_) & cartas(trigo,0,_)
    <- .print("DISTRIBUIÇÃO FINALIZADA");
       .wait(500);
       .broadcast(achieve, iniciar).	

// Transimitir bids para todos os players
+!bid(Tipo,Qtd,Valor)[source(Player)] : true
	<- +bid(Tipo,Qtd,Player,Valor,waiting);
	   .broadcast(achieve, receber_bid(Qtd,Player,Valor)).

-!bid(Tipo,Qtd,Valor)[source(Player)] : true
    <- !!bid(Tipo,Qtd)[source(Player)].
	
// Recebe a informacao quando um player aceita uma bid
+!aceitar_bid(Player,Qtd)[source(PlayerAccepted)] : bid(TipoBid,Qtd,Player,ValorBid,waiting)
											  & bid(TipoAcc,Qtd,PlayerAccepted,ValorAcc,waiting) 
											  & not changing
	<- +changing;
	   .print(PlayerAccepted, " aceitou a bid de ", Player);
	   -bid(TipoBid,Qtd,Player,ValorBid,waiting);
	   +bid(TipoBid,Qtd,Player,ValorBid,accepted);
	   -bid(TipoAcc,Qtd,PlayerAccepted,ValorAcc,waiting);
	   +bid(TipoAcc,Qtd,PlayerAccepted,ValorAcc,accepted);
	   .send(PlayerAccepted, achieve, recompor_mao(TipoBid,TipoAcc,Qtd));
	   .send(Player, achieve, recompor_mao(TipoAcc,TipoBid,Qtd));
	   -changing.

-!aceitar_bid(Player,Qtd)[source(PlayerAccepted)] : true
	<- !!aceitar_bid(Player,Qtd)[source(PlayerAccepted)].

// Receber um pedido de corner
+!corner(Tipo)[source(PlayerCorner)] : true
	<- .broadcast(achieve, corner(PlayerCorner, Tipo));
		.wait(10000). 

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
