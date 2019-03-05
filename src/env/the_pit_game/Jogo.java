package the_pit_game;

import java.util.ArrayList;
import java.util.Arrays;

import JGamePlay.Window;

public class Jogo extends Thread {

	private Window janela = new Window(1272, 720);
	private Player player1 = new Player(0,0, "abilio");
	private Player player2 = new Player(424,0, "leandro");
	private Player player3 = new Player(848,0, "romario");
	private Dealer dealer = new Dealer(0, 167);
	
	public void iniciar() {
		this.start();
		for (int i = 0; i < 9; i++) {
			dealer.addCarta(new CartaMilho(60));
		}
		for (int i = 0; i < 9; i++) {
			dealer.addCarta(new CartaFeijao(80));
		}
		for (int i = 0; i < 9; i++) {
			dealer.addCarta(new CartaTrigo(100));
		}
		dealer.desenhar();

//		for (int i = 0; i < 9; i++) {
//			player1.addCarta(new CartaTrigo(100));
//		}
		player1.desenhar();
//		for (int i = 0; i < 9; i++) {
//			player2.addCarta(new CartaTrigo(100));
//		}
		player2.desenhar();
//		for (int i = 0; i < 9; i++) {
//			player3.addCarta(new CartaTrigo(100));
//		}
		player3.desenhar();
		
		dealer.receberPlayers(new ArrayList<Player>(Arrays.asList(player1,player2,player3)));
		
		janela.display();

	}
	
	public void distribuir(String agent, String tipo) {
		dealer.distribuir(agent, tipo);
	}
	
	public void atualizar() {
		dealer.desenhar();
		player1.desenhar();
		player2.desenhar();
		player3.desenhar();
		janela.display();
	}
	
	public void mensagemDealer(String text) {
		dealer.atualizarTexto(text);
	}

}
