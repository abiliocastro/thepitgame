package the_pit_game;

import JGamePlay.Window;

public class Jogo extends Thread {

	private Window janela = new Window(1272, 720);
	private Player player1 = new Player(0,0, "Abilio");
	private Player player2 = new Player(424,0, "Leandro");
	private Player player3 = new Player(848,0, "Romario");
	private Dealer dealer = new Dealer(0, 167);
	
	public void iniciar() {
		this.start();
		for (int i = 0; i < 27; i++) {
			dealer.addCarta(new CartaTrigo(100));
		}
		dealer.desenhar();

		for (int i = 0; i < 9; i++) {
			player1.addCarta(new CartaTrigo(100));
		}
		player1.desenhar();
		for (int i = 0; i < 9; i++) {
			player2.addCarta(new CartaTrigo(100));
		}
		player2.desenhar();
		for (int i = 0; i < 9; i++) {
			player3.addCarta(new CartaTrigo(100));
		}
		player3.desenhar();
		for (int i = 0; i < 9; i++) {
			player3.addCarta(new CartaTrigo(100));
		}
		player3.desenhar();
		janela.display();

	}

}
