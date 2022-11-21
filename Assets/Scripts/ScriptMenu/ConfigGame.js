#pragma strict
private var grp_onglets : GameObject[];
private var grp_difficulty : GameObject[];
var nbr_players : int;

private var ext_value_p2 : GameObject;
private var ext_value_p3 : GameObject;
private var ext_value_p4 : GameObject;

function Start ()
{
	
}

function ConfigGame()
{
	grp_onglets = GameObject.FindGameObjectsWithTag("Onglet");
	var obj_blue : GameObject;
	var obj_red : GameObject;
	var obj_yellow : GameObject;
	var diff_blue : String;
	var diff_red : String;
	var diff_yellow : String;
	nbr_players = 0;
	
	for (var onglets : GameObject in grp_onglets)
	{
		if (onglets.renderer.enabled == true)
		{
			if (onglets.transform.name.IndexOf("_blue") != -1)
			{
				if (onglets.transform.name.IndexOf("player") != -1)
					nbr_players++;
				else
					diff_blue = Config_Difficulty("blue");
				obj_blue = onglets;
			}
			else if (onglets.transform.name.IndexOf("_red") != -1)
			{
				if (onglets.transform.name.IndexOf("player") != -1)
					nbr_players++;
				else
					diff_red = Config_Difficulty("red");
				obj_red = onglets;
			}
			else if (onglets.transform.name.IndexOf("_yellow") != -1)
			{
				if (onglets.transform.name.IndexOf("player") != -1)
					nbr_players++;
				else
					diff_yellow = Config_Difficulty("yellow");
				obj_yellow = onglets;
			}
		}
	}
	diff_blue = obj_blue.name + "_" + diff_blue;
	diff_red = obj_red.name + "_" + diff_red;
	diff_yellow = obj_yellow.name + "_" + diff_yellow;
	
//	var script = GameObject.Find("Space").GetComponent(Connect);
//	script.maxClients = nbr_players;
//	networkView.RPC("PrintText", RPCMode.AllBuffered, nbr_players);
	networkView.RPC("Player_Type_Txt", RPCMode.AllBuffered, diff_blue, diff_red, diff_yellow/*, diff_blue, diff_red, diff_yellow*/);
	return nbr_players;
}

// All RPC calls need the @RPC attribute!
@RPC
function PrintText (nbr_players : int)
{
    Debug.Log("Number of players : " + nbr_players);
}

function Config_Difficulty(color : String)
{
	grp_difficulty = GameObject.FindGameObjectsWithTag("Difficulty");
	var easy = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_easy");
	var normal = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_normal");
	var hard = GameObject.Find("Create_Menu/Place_" + color + "/onglet_cpu_" + color + "/" + color + "_hard");
	
	if (easy.renderer.enabled == true)
		return ("easy");
	else if (normal.renderer.enabled == true)
		return ("normal");
	else if (hard.renderer.enabled == true)
		return ("hard");
	return (null);
}

function Difficulty_Type_Txt(data : String)
{
	if (data.IndexOf("easy") != -1)
		return ("easy");
	else if (data.IndexOf("normal") != -1)
		return ("normal");
	else if (data.IndexOf("hard") != -1)
		return ("hard");
	return (null);
}

@RPC
function Player_Type_Txt(blue : String, red : String, yellow : String)
{
	var blue_txt = GameObject.Find("Waiting_Room(Clone)/Player2");
	var red_txt = GameObject.Find("Waiting_Room(Clone)/Player3");
	var yellow_txt = GameObject.Find("Waiting_Room(Clone)/Player4");
	var connect_blue = GameObject.Find("Waiting_Room(Clone)/Player2/Connection");
	var connect_red = GameObject.Find("Waiting_Room(Clone)/Player3/Connection");
	var connect_yellow = GameObject.Find("Waiting_Room(Clone)/Player4/Connection");

	if (blue.IndexOf("player") != -1)
	{
		blue_txt.GetComponent(TextMesh).text = "Player 2";
		connect_blue.GetComponent(TextMesh).text = "Not Connected";
	}
	else
	{
		blue_txt.GetComponent(TextMesh).text = "IA (" + Difficulty_Type_Txt(blue) + ")";
		connect_blue.GetComponent(TextMesh).text = "";
	}
	if (red.IndexOf("player") != -1)
	{
		red_txt.GetComponent(TextMesh).text = "Player 3";
		connect_red.GetComponent(TextMesh).text = "Not Connected";
	}
	else
	{
		red_txt.GetComponent(TextMesh).text = "IA (" + Difficulty_Type_Txt(red) + ")";
		connect_red.GetComponent(TextMesh).text = "";
	}
	if (yellow.IndexOf("player") != -1)
	{
		yellow_txt.GetComponent(TextMesh).text = "Player 4";
		connect_yellow.GetComponent(TextMesh).text = "Not Connected";
	}
	else
	{
		yellow_txt.GetComponent(TextMesh).text = "IA (" + Difficulty_Type_Txt(yellow) + ")";
		connect_yellow.GetComponent(TextMesh).text = "";
	}
}

function Update ()
{

}
