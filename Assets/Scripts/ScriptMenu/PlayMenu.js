var cam : GameObject;
private var grp_onglets : GameObject[];
private var grp_difficulty : GameObject[];

function Start () 
{
	grp_onglets = GameObject.FindGameObjectsWithTag("Onglet");
	grp_difficulty = GameObject.FindGameObjectsWithTag("Difficulty");
	for (var onglets : GameObject in grp_onglets)
	{
		if (onglets.transform.name.IndexOf("_cpu") == -1)
			onglets.renderer.enabled = false;
	}
	for (var difficulty: GameObject in grp_difficulty)
	{
		if (difficulty.transform.name.IndexOf("normal") == -1)
			difficulty.renderer.enabled = false;
	}
}

function Zone_Click(object : GameObject)
{
	var ht = object.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = object.GetComponent(SpriteRenderer).sprite.rect.width;
	var pos = cam.camera.ScreenPointToRay(Input.mousePosition);
	
	var height = (ht * object.transform.lossyScale.y) / 200;
	var width = (wh * object.transform.lossyScale.x) / 200;
	if (pos.origin.x > (object.transform.position.x - width)
		&& pos.origin.x < (object.transform.position.x + width)
		&& pos.origin.y > (object.transform.position.y - height)
		&& pos.origin.y < (object.transform.position.y + height))
		return (true);
	return (false);
}

function Search_Objects(objects : GameObject[], name : String)
{
	for (var object : GameObject in objects)
	{
		if (object.transform.name.IndexOf(name) != -1)
			return (object);
	}
	return (null);
}

function IA_Active(player : GameObject, onglet_ia : GameObject, player_color : String)
{
	player.renderer.enabled = false;
	onglet_ia.renderer.enabled = true;
	for (var difficulty: GameObject in grp_difficulty)
	{
		var cat = player_color + "_normal";
		var cat1 = player_color + "_easy";
		var cat2 = player_color + "_hard";
		if (difficulty.transform.name == cat)
			difficulty.renderer.enabled = true;
		else if (difficulty.transform.name == cat1 || difficulty.transform.name == cat2)
			difficulty.renderer.enabled = false;
	}
}

function Player_Active(player : GameObject, onglet_ia : GameObject, player_color : String)
{
	onglet_ia.renderer.enabled = false;
	for (var difficulty: GameObject in grp_difficulty)
	{
		if (difficulty.transform.name.IndexOf(player_color) != -1)
			difficulty.renderer.enabled = false;
	}
	player.renderer.enabled = true;
}

function Difficulty_Active(diff_obj : GameObject, diff : String, color : String)
{
	if (Zone_Click(diff_obj)
		&& diff_obj.renderer.enabled)
	{
		for (var difficulty : GameObject in grp_difficulty)
		{
			var cat = color + "_" + diff;
			if (difficulty.transform.name == cat)
				difficulty.renderer.enabled = true;
			else if (difficulty.transform.name.IndexOf(color) != -1)
				difficulty.renderer.enabled = false;
		}
		return (true);
	}
	return (false);
}

function Onglets_Difficulty(color : String)
{
	var easy = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_easy");
	var normal = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_normal");
	var hard = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_hard");
	
	if (!Difficulty_Active(easy, "normal", color)
		&& !Difficulty_Active(normal, "hard", color))
		Difficulty_Active(hard, "easy", color);
	return (false);
}

function Onglets_color(color : String)
{
	var player = GameObject.Find("Create_Menu/Place_" + color + "/player_" + color);
	var onglet_ia = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "");
	var easy = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_easy");
	var normal = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_normal");
	var hard = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_hard");
	
	var player_inactif = GameObject.Find("Create_Menu/Place_" + color + "/player_inactif");
	var ia_inactif = GameObject.Find("Create_Menu/Place_" + color + "/cpu_inactif");
	
	if (Zone_Click(player_inactif))
	{
		player.renderer.enabled = true;
		Player_Active(player, onglet_ia, color);
		return (true);
	}
	else if (Zone_Click(ia_inactif)
		&& !Zone_Click(easy)
		&& !Zone_Click(normal)
		&& !Zone_Click(hard))
	{
		onglet_ia.renderer.enabled = true;
		IA_Active(player, onglet_ia, color);
		return (true);
	}
	return (false);
}

function Update () 
{
	if (Input.GetKeyDown(KeyCode.Mouse0)) 
	{
		if (!Onglets_color("blue")
			&& !Onglets_color("red")
			&& !Onglets_color("yellow")
			&& !Onglets_Difficulty("blue")
			&& !Onglets_Difficulty("red"))
		{
			Onglets_Difficulty("yellow");
		}
	}
}