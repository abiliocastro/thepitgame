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

/* Initial goals */
!ganhar.

/* Plans */

/* DISTRIBUIÇÃO */

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

+!ganhar: not outro_ganhou(Alguem, OutroTipo) & not parar
	<-  !estrategia_inicial.
 
+!ganhar: outro_ganhou(Alguem, OutroTipo)
	<- .print("Eh nao ganhei essa ja que o ", Alguem, " ganhou com ", OutroTipo); 
	   .wait(10000).

+!ganhar: cartas(Tipo,9,Valor)
	<- .print("Ganhei essa parada com ", Tipo, " ").

-!ganhar: true 
	<- .print("Ainda nao ganhei oh").

+!iniciar: true
	<- !ganhar.

+!incrementar_timeout : not parar
	<- ?timeout_bid(X);
       .print("TIME OUT ATUAL Q VAI SER INCREMENTADO: ", X);
       -timeout_bid(X);
       +timeout_bid(X+1);
       ?cartas(milho,M,_);
       ?cartas(feijao,F,_);
       ?cartas(trigo,T,_);
       .print("TENHO: ", T, " trigo ", M, " milho ", F, " feijao");
       ?esperar_acoes(Espera);
       .wait(Espera).

-!incrementar_timeout : true
	<- .print("Acabou-se").
	
+!resetar_timeout : true
	<- ?timeout_bid(X);
	   -timeout_bid(X);
	   +timeout_bid(0).

-!resetar_timeout : true
	<- !resetar_timeout.

/* ESTRATEGIA */

// Nenhum tipo zerado
+!estrategia_inicial : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0 & not parar      
    <- .min([M, F, T], Min);
       ?cartas(TipoMin,Min,ValorMin);
       .print("Min atual ", Min);
       !make_bid(TipoMin,Min,ValorMin);
       .print("O que eu tenho menos agora ", TipoMin);
       !incrementar_timeout;
       ?cartas(Tipo,9,Valor).
  
// Um tipo zerado
+!estrategia_inicial : cartas(Tipo0,0,Valor0) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) 
               & Q1 > 0 & Q2 > 0 & not (Tipo1 = Tipo2) & not parar 
    <- .min([Q1,Q2], Min);
       ?cartas(TipoMin,Min,ValorMin);  
       .print("Min atual ", Min);
       !make_bid(TipoMin,Min,ValorMin);
       .print("Zerei o tipo ", Tipo0, " O que tenho menos agora eh ", TipoMin);  
       !incrementar_timeout;
       ?cartas(Tipo,9,Valor).
 
 +!estrategia_inicial: cartas(Tipo,9,Valor)
	<- +parar;
	   !ganhar.
 
-!estrategia_inicial : timeout_bid(TO) & TO < 11 & not parar 
	<- !incrementar_timeout;
	   !estrategia_inicial.

-!estrategia_inicial : not parar
	<- !incrementar_timeout;
	   .print("MUDANDO ESTRATEGIA PARA diminuir");
	   !estrategia_inicial. 

-!estrategia_inicial : true
	<- +parar;
	   !ganhar.	
	      	
/* ESTRATEGIA DE DIMINUIR A QUANTIDADE DA BID */
// Nenhum tipo zerado   
+!estrategia_diminuir : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0 & not parar 
               & bid(Tipo,Q,Valor,waiting) & Q > 1
    <- .print("DIMINUIR O TAMANHO DESSA BID"); 
	   -bid(Tipo,Q,Valor,waiting);
	   !make_bid(Tipo,Q-1,Valor);
	   !incrementar_timeout;
	   ?cartas(Tipo,9,Valor).
 
 // Um tipo zerado
+!estrategia_diminuir : cartas(Tipo0,0,Valor0) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) 
               & Q1 > 0 & Q2 > 0 & not (Tipo1 = Tipo2) & not parar 
               & bid(Tipo,Q,Valor,waiting) & Q > 1
    <- .print("VAMO DIMINUIR O TAMANHO DESSA BID NEH");
	   -bid(Tipo,Q,Valor,waiting);
	   !make_bid(Tipo,Q-1,Valor);
	   !incrementar_timeout;
	   ?cartas(Tipo,9,Valor).
 
 +!estrategia_diminuir: cartas(Tipo,9,Valor)
	<- +parar;
	   !ganhar.
 
 -!estrategia_diminuir : timeout_bid(TO) & TO > 10 & TO < 50 & not parar // diminui o bid  para agilizar
	<- !incrementar_timeout;
	   !!estrategia_diminuir.

-!estrategia_diminuir : not parar
	<- !incrementar_timeout;
	   .print("MUDANDO ESTRATEGIA PARA aleatoria");
	   !!estrategia_aleatoria.	   

-!estrategia_diminuir : true
	<- +parar;
	   !ganhar.	   	

/* PLANOS CHAMADOS PELAS ESTRATÉGIAS */ 

// Realiza a bid se está dentro da quatindade minima e maxima aceita
+!make_bid(Tipo,Qtd,Valor) : Qtd > 0 & Qtd < 5 & not parar
    <- .print(Qtd,"! ",Qtd,"! ",Qtd,"! ");
       +bid(Tipo,Qtd,Valor,waiting);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .send(dealer, achieve, bid(Tipo,Qtd,Valor)).
 
 -!make_bid(Tipo,Qtd,Valor) : Qtd > 4
	<- !incrementar_timeout.      
       
-!make_bid(Tipo,Qtd) : true
    <- !!make_bid(Tipo,Qtd).

// Recebe as bids dos outros players e aceita se a quantidade é a desejada
+!receber_bid(Qtd,Player,Valor)[source(dealer)] : aceitando_bids 
					& bid(Tipo,Q,Val,waiting) & Q = Qtd 
					& .my_name(Me) & not (Me = Player)
					& esse_nao(Ele) & not (Player = Ele)
					& not parar
    <- -aceitando_bids;
       .print("Aceitei a bid do ", Player);
       -+ultimo_aceitei(Player);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .send(dealer, achieve, aceitar_bid(Player,Q)).

+!receber_bid(Qtd,Player,Valor): true
    <- ?esperar_acoes(Espera);
       .wait(Espera);
       .print("Bid recebido").

-!receber_bid(Qtd,Player,Valor) : true
	<- !!receber_bid(Qtd,Player,Valor).

// Atualiza o status da bid
+!bid_aceita(TipoBid,Qtd,ValorBid)[source(dealer)] : true
    <- -aceitando_bids;
       .print("Começando a atualizar bid");
       ?bid(TipoBid,Qtd,ValorBid,waiting);
       -bid(TipoBid,Qtd,ValorBid,waiting);
       +bid(TipoBid,Qtd,ValorBid,accepted);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .print("Crenças atualizadas após minha bid aceita").

-!bid_aceita(TipoBid,Qtd,ValorBid) : true
    <- .print("Ja aceitei de outro cara").

// Recompoe a mao apos aceitar e ter uma bid aceita
+!recompor_mao(TipoAdd,TipoRet,Qtd)[source(dealer)] : cartas(TipoEnv, Q, VQ) & not (Q = 0)
    <- -aceitando_bids;
       ?cartas(TipoRet,Q1,ValorEnv);
       -cartas(TipoRet,Q1,ValorEnv);
       +cartas(TipoRet,Q1-Qtd,ValorEnv);
       ?cartas(TipoAdd,Q2,ValorBid);
       -cartas(TipoAdd,Q2,ValorBid);
       +cartas(TipoAdd,Q2+Qtd,ValorBid);
       !atualizar_ultimo_tipo(TipoAdd);
       //?esperar_acoes(Espera);
       .wait(2000);
       .print("Mao recomposta após aceitar uma bid");
       +aceitando_bids.
       
-!recompor_mao(TipoEnv,ValorEnv,TipoBid,ValorBid,Qtd)[source(dealer)] : true
    <- .print("DESCARTEI UMA BID Q FOI ACEITA").

+!atualizar_ultimo_tipo(Tipo) : ultimo_tipo(TipoAnterior) & (TipoAnterior = Tipo) 
	<- ?ultimo_aceitei(Cara);
	   -+esse_nao(Cara).

+!atualizar_ultimo_tipo(Tipo) : ultimo_tipo(TipoAnterior) & not (TipoAnterior = Tipo) 
	<- -+esse_nao(null);
	   -ultimo_tipo(TipoAnterior);
	   +ultimo_tipo(Tipo).

-!atualizar_ultimo_tipo(Tipo) : true
	<- !atualizar_ultimo_tipo(Tipo).

// Verificando se recebeu as 9 cartas
+total_cartas(9) : true
    <- .print("Recebi minhas 9 cartas").
	
// Checando se ganhou	
+cartas(Tipo, Q, Valor) : cartas(Tipo, 9, Valor)
	<- !corner.

// Receber noticia de corner
+!corner(Player, Tipo)[source(dealer)] : .my_name(Me) & not (Me = Player)
	<-  +outro_ganhou(Player, Tipo);
		+parar;
	    !ganhar.

-!corner(Player, Tipo) : true
	<- .print("PARECE Q EU GANHEI");
	   !ganhar.

+!corner: cartas(Tipo, 9, Valor)
	<-  .send(dealer, achieve, corner(Tipo)).

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
