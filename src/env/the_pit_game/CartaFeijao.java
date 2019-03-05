package the_pit_game;

import JGamePlay.Animation;

public class CartaFeijao extends Carta {

	public CartaFeijao(int pontuacao) {
		super();
		this.img_path = "gui/feijao.png";
		this.img_ac_path = "gui/feijao-ac.png";
		this.img = new Animation(img_path);
	}
}
