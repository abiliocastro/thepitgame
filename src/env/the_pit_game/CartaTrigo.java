package the_pit_game;

import JGamePlay.Animation;

public class CartaTrigo extends Carta {

	public CartaTrigo(int pontuacao) {
		super();
		this.img_path = "gui/trigo.png";
		this.img_ac_path = "gui/trigo-ac.png";
		this.img = new Animation(img_path);
	}

}
