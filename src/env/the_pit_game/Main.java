package the_pit_game;

public class Main {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Jogo jogo = new Jogo();
		jogo.iniciar();
		jogo.distribuir("abilio", "trigo");
		jogo.distribuir("leandro", "feijao");
		jogo.distribuir("romario", "milho");
		jogo.atualizar();
		
	}

}
