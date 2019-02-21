// Agent dealer in project the_pit_game

/* Initial beliefs and rules */
cartas(milho,9,60).
cartas(feijao,9,80).
cartas(trigo,9,100).
espera(500).

tipos([milho,feijao,trigo]).

players([abilio,leandro,romario]).

// Scores inicial dos players
score(abilio,0).
score(leandro,0).
score(romario,0).

/* Initial goals */
distribuir([abilio,leandro,romario]).

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

+distribuir([]) : cartas(_,Qtd,_) & Qtd > 0
	<- -+distribuir([abilio,leandro,romario]).
	
+distribuir([]) : cartas(milho,0,_) & cartas(feijao,0,_) & cartas(trigo,0,_)
    <- .print("DISTRIBUIÇÃO FINALIZADA");
       ?espera(Tempo);
       .wait(Tempo);
       .broadcast(achieve, iniciar).	

// Quando todas as cartas de um tipo são distribuidas
+cartas(Tipo,0,_) : tipos(L)
    <- .delete(Tipo, L, NL);
       -tipos(L);
       +tipos(NL). 

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
	   .send(Player,         achieve, recompor_mao(TipoAcc,TipoBid,Qtd));
	   .print(PlayerAccepted, " e ", Player, " já devem ter recomposto as mãos");
	   -changing.

-!aceitar_bid(Player,Qtd)[source(PlayerAccepted)] :  not bid(TipoBid,Qtd,Player,ValorBid,waiting) 
	<- .print(Player, " ja teve sua bid aceita").
	
-!aceitar_bid(Player,Qtd)[source(PlayerAccepted)] :  true 
	<- .print(PlayerAccepted, " não é mais possível aceitar a bid de ", Player).

// Receber um pedido de corner
+!corner(Tipo)[source(PlayerCorner)] : true
	<- .broadcast(achieve, corner(PlayerCorner, Tipo));
		.wait(1000);
		?cartas(Tipo,_,Valor);
		?score(PlayerCorner,X);
		-score(PlayerCorner,X);
		+score(PlayerCorner,X+Valor);
		!pontuacao;
		?espera(Tempo);
		.wait(Tempo);
		!nova_rodada. 

+!pontuacao : true 
	<- ?players(P);
		!itera_players(P).

+!itera_players([H|T]) : true
	<- ?score(H,P);
	   .print(H, " PONTUAÇÃO: ", P);
	   !itera_players(T).

+!itera_players([]): true
	<- true.	    

// Pra fazer iteracão
+!nova_rodada : cartas(milho,0,VM) & cartas(feijao,0,VF) & cartas(trigo,0,VT) & not vencedor
     <- .print("INICIANDO UMA NOVA RODADA");
       -cartas(milho,0,VM);
       +cartas(milho,9,VM);
       -cartas(feijao,0,VF);
       +cartas(feijao,9,VF);
       -cartas(trigo,0,VT);
       +cartas(trigo,9,VT);
       -tipos([]);
       +tipos([milho,feijao,trigo]);
       .broadcast(achieve, zerar_crencas);
       .wait(1000);
       .broadcast(achieve, reiniciar);
       ?espera(Tempo);
       .wait(Tempo);
       -+distribuir([abilio,leandro,romario]).

-!nova_rodada : true
	<- .wait(20).     		

+score(Player,S) : S >= 500
	<- 	+vencedor;
		.print(Player, " É O CAMPEÃO").

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
