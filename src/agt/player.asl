// Agent sample_agent in project the_pit_game

/* Initial beliefs and rules */
total_cartas(0).
cartas(milho,0,20).
cartas(feijao,0,30).
cartas(trigo,0,40).

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
    <- .print("Deliberando");
        !estrategia;
        !timeout_bids. // Decrementa o timeout das bids   

-!iniciar : true
    <- !iniciar.
    
+!estrategia : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_)
    <- .min([M, F, T], Min);
       .max([M, F, T], Max);
       ?cartas(TipoMin,Min,_);
       ?cartas(TipoMax,Max,_);
       +priorizar(TipoMax);
       !make_bid(TipoMin,Min);
       +bid(TipoMin,Min,1000,waiting);  
       .print("O que eu tenho menos ", Tipo).    

+!make_bid(Tipo,Qtd) : true
    <- .send(dealer, achieve, bid(Tipo,Qtd)).

+!timeout_bids : bid(Tipo,Qtd,Time,Status) & Time >= 1
    <- -bid(Tipo,Qtd,Time,Status);
       +bid(Tipo,Qtd,Time-1,Status).
       
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