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
    
    @OPERATION void mensagemDealer(String msg) throws Exception {     
    	jogo.mensagemDealer(msg);
    	jogo.atualizar();
    }

}

