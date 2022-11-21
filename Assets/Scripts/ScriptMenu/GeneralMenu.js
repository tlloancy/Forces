var cam : GameObject;
var obj_script : GameObject;
private var object_script : GameObject;
private var grp_menu : GameObject[];
var helps_menu : GameObject[];
var button_somtuto : GameObject;
var gnrl_menu : GameObject;
var tuto_menu : GameObject;
var server_menu : GameObject;
var option_menu : GameObject;
var hs_menu : GameObject;
var options : GameObject[];
var opt_cancel : GameObject;
var join : GameObject;
var create : GameObject;
var players : int;

var room_obj : GameObject;
private var room_inst : GameObject;

var ScriptsEffects : SoundEffectsHelper;

var o_move : GameObject;
var o_speed : float;

function Start () 
{
	Screen.orientation = ScreenOrientation.LandscapeLeft;
	ScriptsEffects = GameObject.Find("ScriptSF").GetComponent(SoundEffectsHelper);
	o_move = GameObject.Find("General_Menu/O");
	o_speed = 360;
	grp_menu = GameObject.FindGameObjectsWithTag("Menu");
	helps_menu = GameObject.FindGameObjectsWithTag("TutoMenu");
	button_somtuto = GameObject.Find("Tutorial_Menu/Som_tuto");
	join = GameObject.Find("General_Menu/Join");
	create = GameObject.Find("Create_Menu/Start");
	options = GameObject.FindGameObjectsWithTag("Options");
	opt_cancel = GameObject.Find("Options_Menu/Cancel");
		
	GameObject.Find("Tutorial_Menu").GetComponent(Tutorial).som_tuto(helps_menu, button_somtuto);
	ScriptsEffects.bydefault(options);
	for (var menu : GameObject in grp_menu)
	{
		if (menu.transform.name == "General_Menu")
			gnrl_menu = menu;
		else if (menu.transform.name == "Create_Menu")
		{
			server_menu = menu;
			menu.gameObject.SetActive(false);
		}
		else if (menu.name == "Tutorial_Menu")
		{
			tuto_menu = menu;
			tuto_menu.transform.position.z = -3;
			menu.gameObject.SetActive(false);
		}
		else if (menu && menu.name == "Options_Menu")
		{
			option_menu = menu;
			option_menu.transform.position.z = -3;
			menu.gameObject.SetActive(false);
		}
		else if (menu.name == "Highscores_Menu")
		{
			hs_menu = menu;
			menu.gameObject.SetActive(false);
		}
		else
			menu.gameObject.SetActive(false);
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

function config()
{
	if (Network.peerType == NetworkPeerType.Server && object_script == null)
	{
		object_script = Network.Instantiate(obj_script, transform.position, Quaternion.identity, 0);
		var script = object_script.GetComponent(ConfigGame);
		var script2 = GameObject.Find("Space").GetComponent(Connect);
		players = script.ConfigGame();
		script2.maxClients = players;
	}
//		print("j'attends");
}



function menu_gnrl(menu : GameObject)
{
	var button_object;
	
	if (button_object == null)
		button_object = GameObject.FindGameObjectsWithTag("Sous-menu");
	for (var button : GameObject in button_object)
	{
		if (Input.GetKeyDown(KeyCode.Mouse0)) 
			{
				if (Zone_Click(button))
				{
					var cat = button.transform.name + "_Menu";
					for (var new_menu in grp_menu)
					{
						if (cat == "Options_Menu" && !new_menu)
							ScriptsEffects.optmenu.SetActive(true);
						else if (new_menu)
						{
							
							if (cat == new_menu.transform.name && cat != menu.transform.name)
								new_menu.gameObject.SetActive(true);
							else if (button.transform.name == "Cancel")
							{
								gnrl_menu.gameObject.SetActive(true);
								server_menu.gameObject.SetActive(false);
							}
							else if (button.transform.name == "Start")
							{
								yield WaitForSeconds(0.01);
								if (Network.peerType == NetworkPeerType.Server && room_inst == null)
									room_inst = Network.Instantiate(room_obj, transform.position, Quaternion.identity, 0);
								server_menu.gameObject.SetActive(true);
								config();
							}
							if (button.name == "Tutorial")
								tuto_menu.GetComponent(Tutorial).som_tuto(helps_menu, button_somtuto);
						}
					}
					menu.gameObject.SetActive(false);
				}
			}
	}
}

function O_Animate(active : boolean)
{
	if (active)
	{
		var direction : float = -1;
		var arondi : int = Time.realtimeSinceStartup / 1;
		
		// Mouvement
	    var movement : Vector3 = Vector3(0, 0, o_speed * direction);
	    movement = movement * Time.deltaTime;
	    o_move.transform.Rotate(movement);
	    if (arondi % 2 > 0)
	    	o_move.transform.rotation.z = 0;
	}
}

function Update () 
{
	var menu_active;
	var tuto_script = tuto_menu.GetComponent(Tutorial);
	tuto_script.cam = cam;

	if (menu_active == null)
		menu_active = GameObject.FindGameObjectsWithTag("Menu");
	for (var menu : GameObject in menu_active)
		menu_gnrl(menu);
	if (tuto_menu.gameObject.activeInHierarchy)
		tuto_script.help(helps_menu, button_somtuto);
	if (gnrl_menu.gameObject.activeInHierarchy)
		O_Animate(true);
	else
		O_Animate(false);	
}