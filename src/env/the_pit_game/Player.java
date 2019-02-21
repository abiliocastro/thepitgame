package the_pit_game;

import java.awt.Font;
import JGamePlay.GameImage;
import JGamePlay.Text;

public class Player {
	private GameImage profile = new GameImage("gui/player-profile.png");
	private double x;
	private double y;
	private Carta[] deck;
	private Ponto[] posicoes;
	private Font fontNome = new Font("FreeSans", Font.TRUETYPE_FONT, 34);
	private Text txtNome;
	private String nome;
	private Text txtPontuacao;
	private Font fontPontuacao = new Font("FreeSans", Font.TRUETYPE_FONT, 26);
	private int pontuacao;
	
	public Player(double x, double y, String nome) {
		this.x = x;
		this.y = y;
		this.nome = nome;
		this.profile.x = this.x+9;
		this.profile.y = this.y+9;
		this.profile.setDimension(60, 76);
		this.setDeck();
		this.setText();	
	}	
	
	public void desenhar() {
		this.profile.draw();
		this.txtNome.draw();
		this.txtPontuacao.draw();
		for (Carta carta : deck) {
			if(carta != null) {
				carta.desenhar();
			}
		}
	}
	
	public void addCarta(Carta carta) {
		for (int i = 0; i < deck.length; i++) {
			if(this.deck[i] == null) {
				carta.setPosition(this.posicoes[i]);
				this.deck[i] = carta;
				return;
			}
		}
	}
	
	private void setText() {
		int ty = (int) (this.y + 43);
		int profx = (int) (this.profile.x);
		this.txtNome = new Text(this.nome, (profx + this.profile.width + 9), ty);
		this.txtNome.setFont(fontNome);
		int tpy = (int) (this.y + 68);
		this.txtPontuacao = new Text((this.pontuacao + " pontos"), (profx + this.profile.width + 9), tpy);
		this.txtPontuacao.setFont(fontPontuacao);
	}
	
	private void setDeck() {
		this.deck = new Carta[9];
		for (int i = 0; i < deck.length; i++) {
			this.deck[i] = null;
		}
		this.posicoes = new Ponto[9];
		this.posicoes[0] = new Ponto(this.x + 9, (this.profile.y + this.profile.height + 9));
		for (int i = 1; i < posicoes.length; i++) {
			this.posicoes[i] = new Ponto(this.posicoes[i-1].x + 45, this.posicoes[0].y);
		}
	}
}
