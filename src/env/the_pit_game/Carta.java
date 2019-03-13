package the_pit_game;

import JGamePlay.Animation;

public abstract class Carta {
	protected Animation img;
	protected String img_path;
	protected String img_ac_path;
	protected Ponto posicao;
	protected int pontuacao;
	
	public Carta() {
		
	}
	
	public void desenhar() {
		this.img.x = this.posicao.x;
		this.img.y = this.posicao.y;
		this.img.draw();
	}

	public void setPosition(Ponto posicao) {
		this.posicao = posicao;
	}
	
	public void select() {
		this.img.loadImage(this.img_ac_path);
	}
	
	public void deselect() {
		this.img.loadImage(this.img_path);
	}
	
	
}
