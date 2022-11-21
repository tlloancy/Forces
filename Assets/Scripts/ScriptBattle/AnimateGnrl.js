#pragma strict

//var o_speed : float = 360;

var animate : GameObject;
private var animate_inst : GameObject;

function Start ()
{

}

function Update ()
{

}

function config_begin_anim(color : Color, alpha : float, scale : float)
{
	var animsprite = animate_inst.GetComponent(SpriteRenderer);
	
	animsprite.color = color;		//couleur d'arrivée
	animsprite.color.a = alpha;		//alpha ou transparence d'arrivée 
									//de 0 à 1 (0 à 100%) où 0 = transparent									
	animate_inst.transform.localScale.x = scale;				//scale ou grossissement d'arrivée
	animate_inst.transform.localScale.y = scale;
}

function config_final_anim(color : Color, alpha : float, scale : float, speedColor : float, speedScale : float)
{
	animate_inst.GetComponent(Animate).destinationColor = color;		//couleur d'arrivée
	animate_inst.GetComponent(Animate).speedColor = speedColor;			//vitesse des couleurs
	animate_inst.GetComponent(Animate).destinationColor.a = alpha;		//alpha ou transparence d'arrivée 
																		//de 0 à 1 (0 à 100%) où 0 = transparent
	animate_inst.GetComponent(Animate).destScaleX = scale;				//scale ou grossissement d'arrivée
	animate_inst.GetComponent(Animate).destScaleY = scale;
	animate_inst.GetComponent(Animate).speed = speedScale;				//vitesse de grossissement
}

function effect_change(dec : GameObject, sprite_name : String, color : Color)
{
	//Animation instanciée
	animate_inst = Network.Instantiate(animate, dec.transform.position, transform.rotation, 0);
	animate_inst.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/Reserve_Box/" + sprite_name + "_Box/Reserve_" + sprite_name).GetComponent(SpriteRenderer).sprite;
	config_begin_anim(color, 1, 3);
	config_final_anim(color, 0, 9, 2, 2.5);
}

//		Pansement pour anti-réseau		//
function propre (name : String) {
	for (var ia : GameObject in GameObject.FindGameObjectsWithTag("Player")) {
		if (ia.name.IndexOf("blue") != -1 && name == "blue")
			return (ia.name);
		if (ia.name.IndexOf("red") != -1 && name == "red")
			return (ia.name);
		if (ia.name.IndexOf("yellow") != -1 && name == "yellow")
			return (ia.name);
		if (ia.name.IndexOf("green") != -1 && name == "green")
			return (ia.name);
	}
	return (null);
}
//////////////////////////////////////////

function change(piece : String, dec : GameObject, info : allInfo)
{
//		Pansement pour anti-réseau		//
	var color : Color;
	
	if (info == GameObject.Find(propre("green")).GetComponent(allInfo))
		color = GameObject.Find("a - Boxes/ContainsPlace/color_red").GetComponent(SpriteRenderer).color;
	else if (info == GameObject.Find(propre("red")).GetComponent(allInfo))
		color = GameObject.Find("a - Boxes/ContainsPlace/color_green").GetComponent(SpriteRenderer).color;
	else if (info == GameObject.Find(propre("blue")).GetComponent(allInfo))
		color = GameObject.Find("a - Boxes/ContainsPlace/color_purple").GetComponent(SpriteRenderer).color;
	else if (info == GameObject.Find(propre("yellow")).GetComponent(allInfo))
		color = GameObject.Find("a - Boxes/ContainsPlace/color_yellow").GetComponent(SpriteRenderer).color;
//////////////////////////////////////////		
	if (piece == "soldier")
		effect_change(dec, "Commando", color);
	else if (piece == "raider")
		effect_change(dec, "Bomber", color);
	else if (piece == "hunter")
		effect_change(dec, "Fighter", color);
	else if (piece == "cruiser")
		effect_change(dec, "Destroyer", color);
	else if (piece == "h_bomb")
		effect_change(dec, "H-Bomb", color);
}

function effect_fight(h_bomb : boolean, dec : GameObject, color : String)
{
	animate_inst = Network.Instantiate(animate, dec.transform.position, transform.rotation, 0);
	if (h_bomb)
		animate_inst.GetComponent(SpriteRenderer).sprite = GameObject.Find("a - Boxes/ContainsPlace/ExplodeHBomb").GetComponent(SpriteRenderer).sprite;
	var color_fight = GameObject.Find("a - Boxes/ContainsPlace/color_" + color).GetComponent(SpriteRenderer).color;
	config_begin_anim(color_fight, 1, 1);
	config_final_anim(color_fight, 0.5, 4.5, 2, 2.5);
}

function fight(h_bomb : boolean, dec : GameObject, count : int)
{
	var winner : String = null;
	if (count == -1 || count == -5)
		winner = "green";
	if (count == -2 || count == -6)
		winner = "blue";
	if (count == -3 || count == -7)
		winner = "red";
	if (count == -4 || count == -8)
		winner = "yellow";
	if (count == -9)
		winner = "grey";
	
	if (winner == "green")
		effect_fight(h_bomb, dec, "red");
	else if (winner == "blue")
		effect_fight(h_bomb, dec, "purple");
	else if (winner == "red")
		effect_fight(h_bomb, dec, "green");
	else if (winner == "yellow")
		effect_fight(h_bomb, dec, "yellow");
	else if (winner == "grey")
		effect_fight(h_bomb, dec, "grey");
}

function destroy()
{
	yield WaitForSeconds(2);
	for (var anim : GameObject in GameObject.FindGameObjectsWithTag("Animation"))
		Network.Destroy(anim);
}

