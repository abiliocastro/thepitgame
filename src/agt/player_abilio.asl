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
esperar_acoes(20).

/* Initial goals */

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
	<- .print("Eh nao ganhei essa ja que o ", Alguem, " ganhou com ", OutroTipo); // Reconhecendo a derrota
	   ?esperar_acoes(Espera);
       .wait(Espera).

+!ganhar: cartas(Tipo,9,Valor)
	<- .print("Ganhei essa parada com ", Tipo, " doidim!"). // Se vangloriando

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

/* ESTRATEGIA INICIAL */
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
	<- +parar.
 
-!estrategia_inicial : timeout_bid(TO) & TO < 11 & not parar 
	<- !incrementar_timeout;
	   !estrategia_inicial.

-!estrategia_inicial : not parar
	<- !incrementar_timeout;
	   .print("MUDANDO ESTRATEGIA PARA diminuir");
	   !estrategia_diminuir. 

-!estrategia_inicial : true
	<- +parar.	   	
                
/* ESTRATEGIA DE DIMINUIR A QUANTIDADE DA BID */
// Nenhum tipo zerado   
+!estrategia_diminuir : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0 & not parar 
               & bid(Tipo,Q,Valor,waiting) & Q > 1
    <- .print("VAMO DIMINUIR O TAMANHO DESSA BID NEH"); 
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
	<- +parar.
 
-!estrategia_diminuir : timeout_bid(TO) & TO > 10 & TO < 21 & not parar 
	<- !incrementar_timeout;
	   !estrategia_diminuir.

-!estrategia_diminuir : not parar
	<- !incrementar_timeout;
	   .print("MUDANDO ESTRATEGIA PARA aleatoria");
	   !estrategia_aleatoria.	   

-!estrategia_diminuir : true
	<- +parar.	   	

/* ESTRATEGIA SELECIONAR UMA QUANTIDA ALEATORIA */
// Nenhum tipo zerado
+!estrategia_aleatoria : cartas(milho,M,_) & cartas(feijao,F,_) & cartas(trigo,T,_) 
               & M > 0 & F > 0 & T > 0 & not parar 
    <- .print("TIMEOUT MAIOR QUE 10 VOU EH NO ALEATORIO AGORA");
	   -+esse_nao(null);
	   jia.random_int(I,3);
	   .nth(I,[milho,feijao,trigo],NovoTipo);
	   ?cartas(NovoTipo,NovaQTD,NovoValor);
	   .print("PREPARANDO NOVO BID DE QTD: ", NovaQTD);
	   !make_bid(NovoTipo,NovaQTD,NovoValor);
	   !incrementar_timeout;
	   ?cartas(Tipo,9,Valor).   
	  	   
// Um tipo zerado
+!estrategia_aleatoria : cartas(Tipo0,0,Valor0) & cartas(Tipo1,Q1,Valor1) & cartas(Tipo2,Q2,Valor2) 
               & Q1 > 0 & Q2 > 0 & not (Tipo1 = Tipo2) & not parar 
    <- .print("TIMEOUT MAIOR QUE 10 E HORA DE MUDAR");
	   -+esse_nao(null);
	   jia.random_int(I,2);
	   .nth(I,[Tipo1,Tipo2],NovoTipo);
	   ?cartas(NovoTipo,NovaQTD,NovoValor);
	   .print("PREPARANDO NOVO BID DE QTD: ", NovaQTD);
	   !make_bid(NovoTipo,NovaQTD,NovoValor);
	   !incrementar_timeout;
	   ?cartas(Tipo,9,Valor).

+!estrategia_aleatoria: cartas(Tipo,9,Valor)
	<- +parar.
	
-!estrategia_aleatoria : timeout_bid(TO) & TO < 31 & not parar 
	<- !incrementar_timeout;
	   !estrategia_aleatoria.

-!estrategia_aleatoria : not parar
	<- !resetar_timeout;
	   .print("MUDANDO ESTRATEGIA PARA inicial");	
	   !estrategia_inicial.

-!estrategia_aleatoria : true
	<- +parar.	   	

/* PLANOS CHAMADOS PELAS ESTRATÉGIAS */
// Realiza a bid se está dentro da quatinda minima e maxima aceita
+!make_bid(Tipo,Qtd,Valor) : Qtd > 0 & Qtd < 5 & not parar
    <- .print(Qtd,"! ",Qtd,"! ",Qtd,"! ");
       +bid(Tipo,Qtd,Valor,waiting);
       ?esperar_acoes(Espera);
       .wait(Espera);
       .send(dealer, achieve, bid(Tipo,Qtd,Valor)).
       
-!make_bid(Tipo,Qtd,Valor) : Qtd > 4
	<- !incrementar_timeout.
       
-!make_bid(Tipo,Qtd,Valor) : true
    <- !!make_bid(Tipo,Qtd,Valor).

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
       .send(dealer, achieve, aceitar_bid(Player,Q));
       +aceitando_bids.

+!receber_bid(Qtd,Player,Valor): not parar
    <- ?esperar_acoes(Espera);
       .wait(Espera);
       .print("Bid recebido").

-!receber_bid(Qtd,Player,Valor) : true
	<- !incrementar_timeout.

// Recompoe a mao apos aceitar e ter uma bid aceita
+!recompor_mao(TipoAdd,TipoRet,Qtd)[source(dealer)] :  not parar & not recompondo 
														& cartas(TipoRet,Q1,ValorRet) & Q1 > 0
    <- +recompondo;
       .print("RECOMPONDO MAO");
       ?bid(TipoRet,Q,Val,waiting);
       -bid(TipoRet,Q,Val,waiting);
       +bid(TipoRet,Q,Val,accepted);
       -cartas(TipoRet,Q1,ValorRet);
       +cartas(TipoRet,Q1-Qtd,ValorRet);
       ?cartas(TipoAdd,Q2,ValorAdd);
       -cartas(TipoAdd,Q2,ValorAdd);
       +cartas(TipoAdd,Q2+Qtd,ValorAdd);
       !atualizar_ultimo_tipo(TipoAdd);
       .print("MAO RECOMPOSTA");
       ?esperar_acoes(Espera);
       .wait(Espera);
       -recompondo.
       
-!recompor_mao(TipoAdd,TipoRet,Qtd)[source(dealer)] : bid(TipoRet,Q,Val,waiting)
    <- .print("Eu tenho a bid de ", TipoRet, " na quantidade ", Q, " mas nao posso recompor").
    
-!recompor_mao(TipoAdd,TipoRet,Qtd)[source(dealer)] : true 
	<- -recompondo;
	   .print("Não tenho a bid de ", TipoRet, " na quantidade ", Qtd, " por isso nao posso recompor").

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
+!corner(Player, Tipo)[source(dealer)] : .my_name(Me) & not (Me = Player) & not parar
	<-  +outro_ganhou(Player, Tipo);
		+parar;
		!ganhar.

-!corner(Player, Tipo) : true // Ele ganhou
	<- +parar;
	   !ganhar.

+!corner: cartas(Tipo, 9, Valor)
	<-  .send(dealer, achieve, corner(Tipo));
		?cartas(Tipo,_,Valor);
		?score(X);
		-score(X);
		+score(X+Valor).

-!corner : true
	<- !corner.

+!zerar_crencas[source(dealer)] : true
	<- 	+parar;
	   	-total_cartas(TC);
    	+total_cartas(0);
	   	-cartas(milho,QM,VM);
	   	+cartas(milho,0,60);
	   	-cartas(feijao,QF,VF);
	   	+cartas(feijao,0,80);
	   	-cartas(trigo,QT,VT);
	   	+cartas(trigo,0,100);
		+aceitando_bids;
		-+timeout_bid(0);
		-+ultimo_tipo(null);
		-+ultimo_aceitei(null);
		-+esse_nao(null);
		-outro_ganhou(Alguem, OutroTipo);
		-bid(milho,QBM,VBM,StM);
		-bid(feijao,QBF,VBF,StF);
		-bid(trigo,QBT,VBT,StT);
		.print("CRENÇAS ZERADAS").

// Para usar no modo iterado
+!reiniciar[source(dealer)] : true
    <- 	-parar;
       	.print("PRONTO PARA UMA NOVA RODADA"). 	
       	.wait(500).

-!reiniciar : true
    <- !reiniciar.          

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }