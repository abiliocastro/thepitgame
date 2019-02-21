package the_pit_game;

import java.awt.Font;
import JGamePlay.GameImage;
import JGamePlay.Text;

public class Dealer {
	private GameImage profile = new GameImage("gui/dealer-profile.png");
	private double x;
	private double y;
	private Carta[] deck;
	private Ponto[] posicoes;
	private Font fontNome = new Font("FreeSans", Font.TRUETYPE_FONT, 34);
	private Text txtNome;
	
	public Dealer(double x, double y) {
		this.x = x;
		this.y = y;
		this.profile.x = this.x+536;
		this.profile.y = this.y+9;
		this.profile.setDimension(60, 76);
		this.setDeck();
		this.setText();	
	}	
	
	public void desenhar() {
		this.profile.draw();
		this.txtNome.draw();
		for (Carta carta : deck) {
			carta.desenhar();
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
		this.txtNome = new Text("Dealer", (profx + this.profile.width + 9), ty);
		this.txtNome.setFont(fontNome);
	}
	
	private void setDeck() {
		this.deck = new Carta[27];
		for (int i = 0; i < deck.length; i++) {
			this.deck[i] = null;
		}
		this.posicoes = new Ponto[27];
		this.posicoes[0] = new Ponto(this.x + 28, (this.profile.y + this.profile.height + 9));
		for (int i = 1; i < posicoes.length; i++) {
			this.posicoes[i] = new Ponto(this.posicoes[i-1].x + 45, this.posicoes[0].y);
		}
	}
}

