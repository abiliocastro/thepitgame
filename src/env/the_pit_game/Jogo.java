package the_pit_game;

import java.util.ArrayList;
import java.util.Arrays;

import JGamePlay.Window;

public class Jogo extends Thread {

	private Window janela = new Window(1272, 720);
	private Player abilio = new Player(0,0, "abilio");
	private Player leandro = new Player(424,0, "leandro");
	private Player romario = new Player(848,0, "romario");
	private Dealer dealer = new Dealer(0, 167);
	private ArrayList<Player> players;
	
	public void iniciar() {
		this.start();
		this.players = new ArrayList<Player>(Arrays.asList(abilio,leandro,romario));
		dealer.receberPlayers(players);
		this.iniciarDeckDealer();
		this.atualizar();

	}
	
	private void iniciarDeckDealer() {
		for (int i = 0; i < 9; i++) {
			dealer.addCarta(new CartaMilho(60));
		}
		for (int i = 0; i < 9; i++) {
			dealer.addCarta(new CartaFeijao(80));
		}
		for (int i = 0; i < 9; i++) {
			dealer.addCarta(new CartaTrigo(100));
		}
	}
	
	public void novaRodada() {
		dealer.reiniciar();
		for (Player player : players) {
			player.reiniciar();
		}
		this.iniciarDeckDealer();
	}
	
	public void distribuir(String agent, String tipo) {
		dealer.distribuir(agent, tipo);
	}
	
	public void makeBid(String agent, String tipo, int qtd) {
		for (Player jogador : players) {
			if(jogador.getNome().equals(agent)) {
				jogador.makeBid(tipo, qtd);
				break;
			}
		}
	}
	
	public void limparBids(String agent) {
		for (Player jogador : players) {
			if(jogador.getNome().equals(agent)) {
				jogador.limparSelecionadas();
				break;
			}
		}
	}
	
	public void recomporMao(String player, String tipoReceber, String tipoEntregar,  int qtd) {
		for (Player jogador : players) {
			if(jogador.getNome().equals(player)) {
				jogador.recomporMao(tipoReceber, tipoEntregar, qtd);
				break;
			}
		}
	}
	
	public void atualizar() {
		dealer.desenhar();
		abilio.desenhar();
		leandro.desenhar();
		romario.desenhar();
		janela.display();
	}
	
	public void mensagemDealer(String text) {
		dealer.atualizarTexto(text);
	}
	
	public void mensagemPlayer(String player, String msg) {
		for (Player jogador : players) {
			if(jogador.getNome().equals(player)) {
				jogador.atualizarMensagem(msg);
				break;
			}
		}
	}
	
	public void atualizarPontuacao(String player, int pontuacao) {
		//String[] splited = msg.split(" ");
		for (Player jogador : players) {
			if(jogador.getNome().equals(player)) {
				jogador.setPontuacao(pontuacao);
				break;
			}
		}
	}

}
