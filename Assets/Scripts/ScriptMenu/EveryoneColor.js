#pragma strict

var ia_blue : GameObject;
var ia_red : GameObject;
var ia_yellow : GameObject;
var play_green : GameObject;
var play_blue : GameObject;
var play_red : GameObject;
var play_yellow : GameObject;



private var ia_blue_inst : GameObject;
private var ia_red_inst : GameObject;
private var ia_yellow_inst : GameObject;
private var play_green_inst : GameObject;
private var play_blue_inst : GameObject;
private var play_red_inst : GameObject;
private var play_yellow_inst : GameObject;

function Start () {

}

function Update () {

}

function whoiam()
{
	var player2 = "Waiting_Room(Clone)/Player2";
	var player3 = "Waiting_Room(Clone)/Player3";
	var player4 = "Waiting_Room(Clone)/Player4";
	var player : String;
	var connect : String;
	var name_obj : String;
	
	yield WaitForSeconds(0.02);
	var blue = GameObject.Find(player2).GetComponent(TextMesh).text;
	var red = GameObject.Find(player3).GetComponent(TextMesh).text;
	var yellow = GameObject.Find(player4).GetComponent(TextMesh).text;
	
	var connect_green : TextMesh;
	var connect_blue : TextMesh;
	var connect_red : TextMesh;
	var connect_yellow : TextMesh;
	
	connect_green = GameObject.Find("Waiting_Room(Clone)/Player1/Connection").GetComponent(TextMesh);
	connect_blue = GameObject.Find(player2 + "/Connection").GetComponent(TextMesh);
	connect_red = GameObject.Find(player3 + "/Connection").GetComponent(TextMesh);
	connect_yellow = GameObject.Find(player4 + "/Connection").GetComponent(TextMesh);
	
	if (Network.isClient)
	{
		if (blue == "Player 2" && connect_blue.text == "Not Connected")
		{
			player = "Player2";
			connect = "Connected";
			name_obj = "Player2blue";
			play_obj(play_blue_inst, play_blue);
		}
		else if (red == "Player 3" && connect_red.text == "Not Connected")
		{
			player = "Player3";
			connect = "Connected";
			name_obj = "Player3red";
			play_obj(play_red_inst, play_red);
		}
		else if (yellow == "Player 4" && connect_yellow.text == "Not Connected")
		{
			player = "Player4";
			connect = "Connected";
			name_obj = "Player4yellow";
			play_obj(play_yellow_inst, play_yellow);
		}
	}
	else if (Network.isServer)
	{
		if (connect_green.text == "Not Connected")
		{
			player = "Player1";
			connect = "Connected";
			name_obj = "Player1green";
			play_obj(play_green_inst, play_green);
		}
		ia_obj(ia_blue_inst, ia_blue, blue, "blue");
		ia_obj(ia_red_inst, ia_red, red, "red");
		ia_obj(ia_yellow_inst, ia_yellow, yellow, "yellow");
	}
//	print(connect);
//	print(name_obj);
	networkView.RPC("everyone_own_color", RPCMode.AllBuffered, connect, name_obj, player);
}

function play_obj(play_inst : GameObject, play_prefab : GameObject)
{
	if (play_inst == null)
		play_inst = Network.Instantiate(play_prefab, play_prefab.transform.position, Quaternion.identity, 0);
}

function ia_obj(ia_inst : GameObject, ia_prefab : GameObject, text_mesh : String, color : String)
{
	if (text_mesh.IndexOf("IA") != -1 && ia_inst == null)
	{
		ia_inst = Network.Instantiate(ia_prefab, ia_prefab.transform.position , Quaternion.identity, 0);
		if (text_mesh.IndexOf("easy") != -1)
			ia_inst.name = "IA_" + color + "_easy";
		if (text_mesh.IndexOf("normal") != -1)
			ia_inst.name = "IA_" + color + "_normal";
		if (text_mesh.IndexOf("hard") != -1)
			ia_inst.name = "IA_" + color + "_hard";
	}
}

@RPC
function everyone_own_color(connect_rpc : String, rename_obj : String, player_name : String)
{
	var connect = GameObject.Find("Waiting_Room(Clone)/" + player_name + "/Connection");
		
	connect.GetComponent(TextMesh).text = connect_rpc;
}
