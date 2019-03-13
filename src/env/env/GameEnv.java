package env;

// import java.util.logging.Logger;

import cartago.Artifact;
import cartago.OPERATION;
import the_pit_game.Jogo;

public class GameEnv extends Artifact {
	
	//private static Logger logger = Logger.getLogger(MiningPlanet.class.getName());
	static Jogo jogo;

    @OPERATION
    public void init() {
        jogo = new Jogo();
        jogo.iniciar();
    }

    @OPERATION void distribuir(String agent, String tipo) throws Exception {     
    	jogo.distribuir(agent, tipo);
    	jogo.atualizar();
    }
    
    @OPERATION void makeBid(String agent, String tipo, int qtd) throws Exception {     
    	jogo.makeBid(agent, tipo, qtd);
    	jogo.mensagemDealer("BID DE " + agent + " TIPO: " + tipo + " QTD: " + qtd);
    	jogo.atualizar();
    }
    
    @OPERATION void limparBids(String agent) throws Exception {     
    	jogo.limparBids(agent);
    	jogo.atualizar();
    }
    
    @OPERATION void recomporMao(String player, String tipoReceber, String tipoEntregar,  int qtd) {
		jogo.recomporMao(player, tipoReceber, tipoEntregar, qtd);
		jogo.atualizar();
	}
    
    @OPERATION void novaRodada() {
    	jogo.novaRodada();
    	jogo.atualizar();
    }
    
    @OPERATION void mensagemDealer(String msg) throws Exception {     
    	jogo.mensagemDealer(msg);
    	jogo.atualizar();
    }
    
    @OPERATION void mensagemPlayer(String player, String msg) throws Exception {
    	jogo.mensagemPlayer(player, msg);
    	jogo.atualizar();
    }
    
    @OPERATION void atualizarPontuacao(String player, int pontuacao) throws Exception {
    	jogo.atualizarPontuacao(player, pontuacao);
    	jogo.atualizar();
    }

}

