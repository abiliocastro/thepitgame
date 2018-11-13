// Agent sample_agent in project the_pit_game

/* Initial beliefs and rules */
total_cartas(0).
cartas(milho,0,60).
cartas(feijao,0,80).
cartas(trigo,0,100).
score(0).
aceitando_bids.

/* Initial goals */

/* Plans */
// Recebendo cartas
+!receber_cartas(Tipo, Q)[source(dealer)] : true 
	<- ?total_cartas(N);
	   -+total_cartas(N+Q);
	   .print("Recebi ", Q, " carta do tipo ", Tipo);
	   !add_cartas(Tipo, Q).
 
// Adicionando cartas 
+!add_cartas(Essa, Destanto) : total_cartas(Total) & Total < 10
    <- ?cartas(Essa, X, Valor);
       -cartas(Essa, X, Valor);	
       +cartas(Essa, X+Destanto, Valor);
       .print("Adicionei ", X+Destanto, " do tipo ", Essa).
       
-!add_cartas(Isso, Ruma) : true
    <- !!add_cartas(Isso, Ruma).
    
+!iniciar : true 
    <- .print("DELIBERANDO");
    	.wait(500);
        !estrategia;
        !avaliar;
        !iniciar.

-!iniciar : true
    <- !iniciar.
    
+!estrategia : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) & not cartas(_,0,_)
    <- .min([M, F, T], Min);
       .max([M, F, T], Max);
       ?cartas(TipoMin,Min,ValorMin);
       ?cartas(TipoMax,Max,ValorMax);
       +tipomax(TipoMax,Max,ValorMax);
       +tipomin(TipoMin,Min,ValorMin);
       !make_bid(TipoMin,Min,ValorMin);
       +bid(TipoMin,Min,ValorMin,waiting);  
       .print("O que eu tenho menos agora ", TipoMin).    

+!estrategia : cartas(_,0,_) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) & Q1 > 0 & Q2 > 0
    <- .min([Q1,Q2], Min);
       ?cartas(TipoMin,Min,ValorMin);
       +tipomin(TipoMin,Min,ValorMin);
       !make_bid(TipoMin,Min,ValorMin);
       +bid(TipoMin,Min,ValorMin,waiting);  
       .print("O que eu tenho menos agora ", TipoMin).

-!estrategia : true
	<- !!estrategia.

+!avaliar : bid(Tipo,Qtd,Valor,waiting)
	<- 
	   .print("").

-!avaliar : true
	<- !avaliar.

+!make_bid(Tipo,Qtd,Valor) : Qtd > 0 & Qtd < 5
    <- .print(Qtd,"! ",Qtd,"! ",Qtd,"! ");
       .wait(500);
       .send(dealer, achieve, bid(Tipo,Qtd,Valor)).
       
-!make_bid(Tipo,Qtd) : true
    <- !!make_bid(Tipo,Qtd).

// Recebe as bids dos outros players e aceita se a quantidade é a desejada
+!receber_bid(Qtd,Player,Valor)[source(dealer)] : aceitando_bids & tipomin(TipoMin,Qmin,ValorMin) & Qtd = Qmin & .my_name(Me) & not (Me = Player)
    <- -aceitando_bids;
       .print("Aceitei a bid do ", Player);
       .wait(500);
       .send(dealer, achieve, aceitar_bid(TipoMin,Qtd,Player,ValorMin)).

+!receber_bid(Qtd,Player,Valor): true
    <- .wait(500);
       .print("Bid recebido").

-!receber_bid(Qtd,Player,Valor) : true
	<- !!receber_bid(Qtd,Player,Valor).

// Atualiza o status da bid
+!bid_aceita(TipoBid,Qtd,ValorBid)[source(dealer)] : bid(TipoBid,Qtd,ValorBid,waiting)
    <- -bid(TipoBid,Qtd,ValorBid,waiting);
       +bid(TipoBid,Qtd,ValorBid,accepted);
       .wait(500);
       .print("Crenças atualizadas após minha bid aceita").

-!bid_aceita(TipoBid,Qtd,ValorBid) : true
    <- !!bid_aceita(TipoBid,Qtd,ValorBid).

// Recompoe a mao apos aceitar e ter uma bid aceita
+!recompor_mao(TipoEnv,ValorEnv,TipoBid,ValorBid,Qtd) : true
    <- ?cartas(TipoEnv,Q1,ValorEnv);
       -cartas(TipoEnv,Q1,ValorEnv);
       +cartas(TipoEnv,Q1-Qtd,ValorEnv);
       ?cartas(TipoBid,Q2,ValorBid);
       -cartas(TipoBid,Q2,ValorBid);
       +cartas(TipoBid,Q2+Qtd,ValorBid);
       .wait(500);
       .print("Mao recomposta após aceitar uma bid");
       +aceitando_bids.
       
-!recompor_mao(TipoRec,Qtd,Valor) : true
    <- !!recompor_mao(TipoRec,Qtd,Valor).
       
// Verificando se recebeu as 9 cartas
+total_cartas(9) : true
    <- .print("Recebi minhas 9 cartas").
	
// Checando se ganhou	
+cartas(Tipo, Q, _) : cartas(Tipo, 9, _)
	<- .print("Tenho 9 cartas do tipo ", Tipo).
	
// Para usar no modo iterado
+!reiniciar[source(dealer)] : true
    <- -+total_cartas(0);
       -+cartas(milho,0,_);
	   -+cartas(trigo,0,_);
       -+cartas(feijao,0,_);
       .print("PRONTO PARA UMA NOVA RODADA");
       .wait(2000).

-!reiniciar : true
    <- !reiniciar.       
      

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }