#pragma strict

function Start () {

}

function Update () {

}

function filtre_color(colorObj : GameObject, obj : String)
{	
	//Reserve info = couleur car h-bomb attaque reserve.

	if ((obj.IndexOf("soldier") != -1)
		|| (obj.IndexOf("raider") != -1)
		|| (obj.IndexOf("cruiser") != -1)
		|| (obj.IndexOf("hunter") != -1)
		|| (obj.IndexOf("commando") != -1)
		|| (obj.IndexOf("bomber") != -1)
		|| (obj.IndexOf("fighter") != -1)
		|| (obj.IndexOf("destroyer") != -1)
		|| (obj.IndexOf("h_bomb") != -1)
		|| (obj.IndexOf("power") != -1))
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_red").GetComponent(SpriteRenderer).color;
	else if ((obj.IndexOf("reserve")) != -1) {
		if ((obj.IndexOf("blue")) != -1)
			colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_purple").GetComponent(SpriteRenderer).color;
		else if ((obj.IndexOf("red")) != -1)
			colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_green").GetComponent(SpriteRenderer).color;
		else if ((obj.IndexOf("yellow")) != -1)
			colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_yellow").GetComponent(SpriteRenderer).color;
		else
			colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_red").GetComponent(SpriteRenderer).color;
	}
	else if ((obj.IndexOf("Plains") != -1) || (obj.IndexOf("Green") != -1))
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_red").GetComponent(SpriteRenderer).color;
	else if ((obj.IndexOf("Ice") != -1) || (obj.IndexOf("Blue") != -1))
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_purple").GetComponent(SpriteRenderer).color;
	else if ((obj.IndexOf("Jungle") != -1) || (obj.IndexOf("Red") != -1))
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_green").GetComponent(SpriteRenderer).color;
	else if ((obj.IndexOf("Desert") != -1) || (obj.IndexOf("Yellow") != -1))
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_yellow").GetComponent(SpriteRenderer).color;
	else if (obj.IndexOf("Space") != -1)
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_grey").GetComponent(SpriteRenderer).color;
	else if ((obj.IndexOf("Moon") != -1) || (obj.IndexOf("Sun") != -1))
		colorObj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_white").GetComponent(SpriteRenderer).color;
}

function filtre_sprite(sprite : GameObject, obj : String)
{
	if ((obj.IndexOf("power")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/F").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("reserve")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/Res").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("HQ")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/HQ").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_NW")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/NW").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_NE")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/NE").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_N")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/N").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_W")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/W").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_C")) != -1 || (obj.IndexOf("Sun")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/CE").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_E")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/E").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_SW")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/SW").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_SE")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/SE").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("_S")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/S").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("Space")) != -1)
	{
		var i = 1;

		while (i != 13)
		{
			if ((obj.IndexOf("_" + i)) != -1)
				sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/Sp" + i).GetComponent(SpriteRenderer).sprite;
			i++;
		}
	}
	else if ((obj.IndexOf("soldier")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Soldier_Box/Reserve_Soldier").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("raider")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Raider_Box/Reserve_Raider").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("cruiser")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Cruiser_Box/Reserve_Cruiser").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("hunter")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Hunter_Box/Reserve_Hunter").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("commando")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Commando_Box/Reserve_Commando").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("bomber")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Bomber_Box/Reserve_Bomber").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("fighter")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Fighter_Box/Reserve_Fighter").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("destroyer")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/Destroyer_Box/Reserve_Destroyer").GetComponent(SpriteRenderer).sprite;
	else if ((obj.IndexOf("h_bomb")) != -1)
		sprite.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/H-Bomb_Box/Reserve_H-Bomb").GetComponent(SpriteRenderer).sprite;
}

function filtre_img(orders : GameObject[], pions : String, place : String)
{
	for (var order : GameObject in orders)
	{
		if (order.name == place)
		{
			filtre_sprite(order, pions);
			filtre_color(order, pions);
		}
	}
}

function filtre_pad(recup : String, number_order : int)
{
	var orders : GameObject[];

	orders = GameObject.FindGameObjectsWithTag("Order" + number_order);

	recup = PlayerPrefs.GetString("Orde" + number_order + "depart");
	if (recup != "change" && recup != "changedec" && recup != "power")
	{
		filtre_img(orders, recup, "Start");
		recup = PlayerPrefs.GetString("Orde" + number_order + "arriver");
		filtre_img(orders, recup, "End");
		recup = PlayerPrefs.GetString("Orde" + number_order + "piece");
		filtre_img(orders, recup, "Pieces");
	}
	else
	{
		var recup1 : String = PlayerPrefs.GetString("Orde" + number_order + "piece");
		if (recup == "power")
			filtre_img(orders, recup, "Pieces");
		else if (recup1 == "soldier" || recup1 == "commando")
			filtre_img(orders, "soldier", "Pieces");
		else if (recup1 == "raider" || recup1 == "bomber")
			filtre_img(orders, "raider", "Pieces");
		else if (recup1 == "hunter" || recup1 == "fighter")
			filtre_img(orders, "hunter", "Pieces");
		else if (recup1 == "cruiser" || recup1 == "destroyer")
			filtre_img(orders, "cruiser", "Pieces");
		else if (recup1.IndexOf("h_bomb") != -1)
			filtre_img(orders, "power", "Pieces");
		recup = PlayerPrefs.GetString("Orde" + number_order + "arriver");
		filtre_img(orders, recup, "Start");
		recup = PlayerPrefs.GetString("Orde" + number_order + "depart");
		if (recup == "power")
			filtre_img(orders, recup1, "End");
		else if (recup1 == "soldier" || recup1 == "commando")
			filtre_img(orders, "commando", "End");
		else if (recup1 == "raider" || recup1 == "bomber")
			filtre_img(orders, "bomber", "End");
		else if (recup1 == "hunter" || recup1 == "fighter")
			filtre_img(orders, "fighter", "End");
		else if (recup1 == "cruiser" || recup1 == "destroyer")
			filtre_img(orders, "destroyer", "End");
		else if (recup1.IndexOf("h_bomb") != -1)
			filtre_img(orders, "h_bomb", "End");
	}
}

function filtre_info_pion(nb : int, obj : GameObject[], on : int)
{
	if (nb == 1) {
		for (var colorobj : GameObject in obj) {
			if ((colorobj.name.IndexOf("Button")) != -1) {
				if ((colorobj.name.IndexOf("Soldier") != -1 && on == 1) || (colorobj.name.IndexOf("Raider") != -1 && on == 2)
					|| (colorobj.name.IndexOf("Hunter") != -1 && on == 4) || (colorobj.name.IndexOf("Cruiser") != -1 && on == 3)
					|| (colorobj.name.IndexOf("Commando") != -1 && on == 5) || (colorobj.name.IndexOf("Bomber") != -1 && on == 6)
					|| (colorobj.name.IndexOf("Fighter") != -1 && on == 8) || (colorobj.name.IndexOf("Destroyer") != -1 && on == 7)
					|| (colorobj.name.IndexOf("H-Bomb") != -1 && on == 9))
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_white").GetComponent(SpriteRenderer).color;
				else
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_red").GetComponent(SpriteRenderer).color;
			}
		}
	}
	else if (nb == 2) {
		for (var colorobj : GameObject in obj) {
			if ((colorobj.name.IndexOf("Button")) != -1) {
				if ((colorobj.name.IndexOf("Soldier") != -1 && on == 1) || (colorobj.name.IndexOf("Raider") != -1 && on == 2)
					|| (colorobj.name.IndexOf("Hunter") != -1 && on == 4) || (colorobj.name.IndexOf("Cruiser") != -1 && on == 3)
					|| (colorobj.name.IndexOf("Commando") != -1 && on == 5) || (colorobj.name.IndexOf("Bomber") != -1 && on == 6)
					|| (colorobj.name.IndexOf("Fighter") != -1 && on == 8) || (colorobj.name.IndexOf("Destroyer") != -1 && on == 7)
					|| (colorobj.name.IndexOf("H-Bomb") != -1 && on == 9))
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_white").GetComponent(SpriteRenderer).color;
				else
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_purple").GetComponent(SpriteRenderer).color;
			}
		}
	}
	else if (nb == 3) {
		for (var colorobj : GameObject in obj) {
			if ((colorobj.name.IndexOf("Button")) != -1) {
				if ((colorobj.name.IndexOf("Soldier") != -1 && on == 1) || (colorobj.name.IndexOf("Raider") != -1 && on == 2)
					|| (colorobj.name.IndexOf("Hunter") != -1 && on == 4) || (colorobj.name.IndexOf("Cruiser") != -1 && on == 3)
					|| (colorobj.name.IndexOf("Commando") != -1 && on == 5) || (colorobj.name.IndexOf("Bomber") != -1 && on == 6)
					|| (colorobj.name.IndexOf("Fighter") != -1 && on == 8) || (colorobj.name.IndexOf("Destroyer") != -1 && on == 7)
					|| (colorobj.name.IndexOf("H-Bomb") != -1 && on == 9))
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_white").GetComponent(SpriteRenderer).color;
				else
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_green").GetComponent(SpriteRenderer).color;
			}
		}
	}
	else if (nb == 4) {
		for (var colorobj : GameObject in obj) {
			if ((colorobj.name.IndexOf("Button")) != -1) {
				if ((colorobj.name.IndexOf("Soldier") != -1 && on == 1) || (colorobj.name.IndexOf("Raider") != -1 && on == 2)
					|| (colorobj.name.IndexOf("Hunter") != -1 && on == 4) || (colorobj.name.IndexOf("Cruiser") != -1 && on == 3)
					|| (colorobj.name.IndexOf("Commando") != -1 && on == 5) || (colorobj.name.IndexOf("Bomber") != -1 && on == 6)
					|| (colorobj.name.IndexOf("Fighter") != -1 && on == 8) || (colorobj.name.IndexOf("Destroyer") != -1 && on == 7)
					|| (colorobj.name.IndexOf("H-Bomb") != -1 && on == 9))
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_white").GetComponent(SpriteRenderer).color;
				else
					colorobj.GetComponent(SpriteRenderer).color = GameObject.Find("a - Boxes/ContainsPlace/color_yellow").GetComponent(SpriteRenderer).color;
			}
		}
	}
}

function filtre_info(recup : String, nb : int, obj : GameObject[], on : int)
{
	var info_sprite = GameObject.Find("a - Boxes/Infos_Box/Info_Text/Info_Sprite");
	
	filtre_sprite(info_sprite, recup);
	filtre_color(info_sprite, recup);
	filtre_info_pion(nb, obj, on);
}

function filtre_reserve(recup : String)
{
	var reserve_sprites : GameObject[];
	
	reserve_sprites = GameObject.FindGameObjectsWithTag("Button_Reserve");
	for (var reserve : GameObject in reserve_sprites)
	{
		if (reserve.activeInHierarchy && reserve.name != "Reserve_Box")
			filtre_color(reserve, recup);			
	}
}
