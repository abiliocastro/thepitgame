package the_pit_game;

import JGamePlay.Animation;

public class CartaMilho extends Carta {
	
	public CartaMilho(int pontuacao) {
		super();
		this.img_path = "gui/milho.png";
		this.img_ac_path = "gui/milho-ac.png";
		this.img = new Animation(img_path);
	}
}
