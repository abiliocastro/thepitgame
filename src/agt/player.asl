// Agent sample_agent in project the_pit_game

/* Initial beliefs and rules */
total_cartas(0).
cartas(milho,0,60).
cartas(feijao,0,80).
cartas(trigo,0,100).
score(0).
aceitando_bids.
timeout_bid(0).
ultimo_tipo(null).
ultimo_aceitei(null).
esse_nao(null).
esperar_acoes(500).
tipomin(qualquer,100,vqlq).

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
    
+!iniciar : not parar 
    <- .print("DELIBERANDO");
    	?esperar_acoes(Espera);
    	.wait(Espera);
        !estrategia;
        //!avaliar;
        !iniciar.

-!iniciar : not parar
    <- !iniciar.

// NENHUM TIPO ZERADO
// Estrategia inicial
+!estrategia : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0
               & timeout_bid(TO) & TO < 6 
       		   & tipomin(TMAtual,MinAtual,VMAtual)       
    <- .min([M, F, T], MinCartas);
       .min([MinCartas, MinAtual], Min);
       ?cartas(TipoMin,Min,ValorMin);
       .print("Min atual ", Min);
       !make_bid(TipoMin,Min,ValorMin);
       -+tipomin(TipoMin,Min,ValorMin); 
       .print("O que eu tenho menos agora ", TipoMin);
       ?timeout_bid(X);
       .print("TIME OUT ATUAL Q VAI SER INCREMENTADO: ", X);
       -timeout_bid(X);
       +timeout_bid(X+1). 
                
// Estrategia de diminuição de bids   
+!estrategia : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0
               & timeout_bid(TO) & TO > 5 & TO < 11
               & bid(Tipo,Q,Valor,waiting) & Q > 1
    <- .print("TIMEOUT SE FOI ESTRATEGIA INICIAL JA ERA"); 
	   -bid(Tipo,Q,Valor,waiting);
	   !make_bid(Tipo,Q-1,Valor);
	   -+tipomin(Tipo,Q-1,Valor);
	   ?timeout_bid(X);
       .print("TIME OUT ATUAL Q VAI SER INCREMENTADO: ", X);
       -timeout_bid(X);
       +timeout_bid(X+1).

// Estrategia para selecionar um tipo aleatoria apos um time out alto
+!estrategia : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0
			   & timeout_bid(TO) & TO > 10
    <- .print("TIMEOUT MAIOR QUE 10 EH HORA DE MUDAR");
	   ?bid(Tipo,Q,Valor,waiting);
	   -bid(Tipo,Q,Valor,waiting);
	   ?esse_nao(Caba);
	   -esse_nao(Caba);
	   jia.random_int(I,3);
	   .nth(I,[milho,feijao,trigo],NovoTipo);
	   ?cartas(NovoTipo,NovaQTD,NovoValor);
	   .print("PREPARANDO NOVO BID DE QTD: ", NovaQTD);
	   !make_bid(NovoTipo,NovaQTD,NovoValor);
	   -+tipomin(NovoTipo,NovaQTD,NovoValor);
	   ?timeout_bid(X);
       -timeout_bid(X);
       +timeout_bid(0).   

// UM TIPO ZERADO
// Estrategia inicial
+!estrategia : cartas(Tipo0,0,Valor0) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) 
               & Q1 > 0 & Q2 > 0 & not (Tipo1 = Tipo2)
               & timeout_bid(TO) & TO < 6
               & tipomin(TMAtual,MinAtual,VMAtual)
    <- .min([Q1,Q2], MinCartas);
       .min([MinCartas,MinAtual], Min);
       ?cartas(TipoMin,Min,ValorMin);
       .print("Min atual ", Min);
       !make_bid(TipoMin,Min,ValorMin);
       -+tipomin(TipoMin,Min,ValorMin);
       .print("Zerei o tipo ", Tipo0, " O que tenho menos agora eh ", TipoMin);  
       ?timeout_bid(X);
       .print("TIME OUT ATUAL Q VAI SER INCREMENTADO: ", X);
       -timeout_bid(X);
       +timeout_bid(X+1).

// Estrategia de diminuição de bids
+!estrategia : cartas(Tipo0,0,Valor0) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) 
               & Q1 > 0 & Q2 > 0 & not (Tipo1 = Tipo2)
               & timeout_bid(TO) & TO > 5 & TO < 11
               & bid(Tipo,Q,Valor,waiting) & Q > 1
    <- .print("TIMEOUT DA BID ESTOURADA");
	   -bid(Tipo,Q,Valor,waiting);
	   !make_bid(Tipo,Q-1,Valor);
	   -+tipomin(Tipo,Q-1,Valor);
	   ?timeout_bid(X);
       .print("TIME OUT ATUAL Q VAI SER INCREMENTADO: ", X);
       -timeout_bid(X);
       +timeout_bid(X+1).
	  	   
// Estrategia para selecionar um tipo aleatoria apos um time out alto
+!estrategia : cartas(Tipo0,0,Valor0) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) 
               & Q1 > 0 & Q2 > 0 & not (Tipo1 = Tipo2)
               & timeout_bid(TO) & TO > 10 & bid(Tipo,Q,Valor,waiting)
    <- .print("TIMEOUT MAIOR QUE 10 E HORA DE MUDAR");
	   -bid(Tipo,Q,Valor,waiting);
	   ?esse_nao(Caba);
	   -esse_nao(Caba);
	   jia.random_int(I,2);
	   .nth(I,[Tipo1,Tipo2],NovoTipo);
	   ?cartas(NovoTipo,NovaQTD,NovoValor);
	   .print("PREPARANDO NOVO BID DE QTD: ", NovaQTD);
	   !make_bid(NovoTipo,NovaQTD,NovoValor);
	   -+tipomin(NovoTipo,NovaQTD,NovoValor);
	   ?timeout_bid(X);
       -timeout_bid(X);
       +timeout_bid(0).
	
+!estrategia : true
	<- .print("NENHUM CONTEXTO APLICAVEL RESETANDO TIME OUT");
	   ?timeout_bid(X);
       -timeout_bid(X);
       +timeout_bid(0).
	   
-!estrategia : true
	<- !!estrategia.

+!avaliar : bid(Tipo,Qtd,Valor,waiting)
	<- .print("Avaliando proxima rodada").

-!avaliar : true
	<- !avaliar.

// Realiza a bid se está dentro da quatinda minima e maxima aceita
+!make_bid(Tipo,Qtd,Valor) : Qtd > 0 & Qtd < 5
    <- .print(Qtd,"! ",Qtd,"! ",Qtd,"! ");
       +bid(Tipo,Qtd,Valor,waiting);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .send(dealer, achieve, bid(Tipo,Qtd,Valor)).
       
       
-!make_bid(Tipo,Qtd) : true
    <- !!make_bid(Tipo,Qtd).

// Recebe as bids dos outros players e aceita se a quantidade é a desejada
+!receber_bid(Qtd,Player,Valor)[source(dealer)] : aceitando_bids 
					& tipomin(TipoMin,Qmin,ValorMin) & Qtd = Qmin 
					& .my_name(Me) & not (Me = Player)
					& esse_nao(Ele) & not (Player = Ele)
    <- -aceitando_bids;
       .print("Aceitei a bid do ", Player);
       -+ultimo_aceitei(Player);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .send(dealer, achieve, aceitar_bid(TipoMin,Qtd,Player,ValorMin)).

+!receber_bid(Qtd,Player,Valor): true
    <- ?esperar_acoes(Espera);
       .wait(Espera);
       .print("Bid recebido").

-!receber_bid(Qtd,Player,Valor) : true
	<- !!receber_bid(Qtd,Player,Valor).

// Atualiza o status da bid
+!bid_aceita(TipoBid,Qtd,ValorBid)[source(dealer)] : bid(TipoBid,Qtd,ValorBid,waiting)
    <- .print("Começando a atualizar bid");
       -bid(TipoBid,Qtd,ValorBid,waiting);
       +bid(TipoBid,Qtd,ValorBid,accepted);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .print("Crenças atualizadas após minha bid aceita").

-!bid_aceita(TipoBid,Qtd,ValorBid) : true
    <- !!bid_aceita(TipoBid,Qtd,ValorBid).

// Recompoe a mao apos aceitar e ter uma bid aceita
+!recompor_mao(TipoEnv,ValorEnv,TipoBid,ValorBid,Qtd)[source(dealer)] : cartas(TipoEnv, Q, VQ) & not (Q = 0)
    <- ?cartas(TipoEnv,Q1,ValorEnv);
       -cartas(TipoEnv,Q1,ValorEnv);
       +cartas(TipoEnv,Q1-Qtd,ValorEnv);
       ?cartas(TipoBid,Q2,ValorBid);
       -cartas(TipoBid,Q2,ValorBid);
       +cartas(TipoBid,Q2+Qtd,ValorBid);
       !atualizar_ultimo_tipo(TipoBid);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .print("Mao recomposta após aceitar uma bid");
       +aceitando_bids.
       
-!recompor_mao(TipoEnv,ValorEnv,TipoBid,ValorBid,Qtd)[source(dealer)] : true
    <- !!recompor_mao(TipoEnv,ValorEnv,TipoBid,ValorBid,Qtd).

+!atualizar_ultimo_tipo(Tipo) : ultimo_tipo(TipoAnterior) & (TipoAnterior = Tipo) 
	<- ?ultimo_aceitei(Cara);
	   -+esse_nao(Cara).

+!atualizar_ultimo_tipo(Tipo) : ultimo_tipo(TipoAnterior) & not (TipoAnterior = Tipo) 
	<- -ultimo_tipo(TipoAnterior);
	   +ultimo_tipo(Tipo).

-!atualizar_ultimo_tipo(Tipo) : true
	<- !atualizar_ultimo_tipo(Tipo).

// Verificando se recebeu as 9 cartas
+total_cartas(9) : true
    <- .print("Recebi minhas 9 cartas").
	
// Checando se ganhou	
+cartas(Tipo, Q, _) : cartas(Tipo, 9, _)
	<- +corner;
	   !corner.

// Receber noticia de corner
+!corner(Player, Tipo)[source(dealer)] : .my_name(Me) & not (Me = Player)
	<-  +parar;
	    .print("Esperando nova rodada ja que o ", Player, " ganhou com ", Tipo).

-!corner(Player, Tipo) : true
	<- !!corner(Player, Tipo).

// Se vangloriando
+!corner : cartas(Tipo, 9, Valor)
	<-  +parar;
	    .print("CORNER EM ", Tipo);
		.send(dealer, achieve, corner(Tipo));
		.print("Esperando nova rodada ja que EU, EU MESMO, O CAMPEAO AQUI ganhou").
		
-!corner : true
	<- !corner.
	
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