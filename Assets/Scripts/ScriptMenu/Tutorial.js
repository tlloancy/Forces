#pragma strict

var cam : GameObject;
private var sommary : GameObject;
var helps_menu : GameObject[];
var menu_tuto : GameObject;

var button_tuto : GameObject;
var button_somtuto : GameObject;
var button_help : GameObject[];
var button_cancel : GameObject;

function Start ()
{
	if (Application.loadedLevelName == "Battleground")
	{
		menu_tuto = GameObject.Find("Tutorial_Menu");
		menu_tuto.GetComponent(Tutorial).enabled = false;
		menu_tuto.transform.position.z = -7;
		menu_tuto.transform.localScale.x = 1.7;
		menu_tuto.transform.localScale.y = 1.7;
		cam = GameObject.Find("Main Camera");
		helps_menu = GameObject.FindGameObjectsWithTag("TutoMenu");
		button_somtuto = GameObject.Find("Tutorial_Menu/Som_tuto");
		button_tuto = GameObject.Find("a - Boxes/Options/Tuto");
		button_help = GameObject.FindGameObjectsWithTag("Button_Tuto");
		button_cancel = GameObject.Find("Tutorial_Menu/Cancel");
		button_cancel.GetComponent(SpriteRenderer).sprite = button_somtuto.GetComponent(SpriteRenderer).sprite;
		button_cancel.transform.localScale.x = 1.5;
		button_cancel.transform.localScale.y = 1.5;
		som_tuto(helps_menu, button_somtuto);
		menu_tuto.SetActive(false);
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

function Update ()
{
	if (Application.loadedLevelName == "Battleground")
	{
		if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(button_tuto)
			&& !menu_tuto.activeInHierarchy
			&& !GameObject.Find("ScriptSF").GetComponent(SoundEffectsHelper).optmenu.activeInHierarchy)
		{
			menu_tuto.SetActive(true);
			help(helps_menu, button_somtuto);
		}
		else if (menu_tuto.activeInHierarchy)
		{
			help(helps_menu, button_somtuto);
		}
	}
}

function som_tuto(helps : GameObject[], button : GameObject)
{
	button.gameObject.SetActive(false);
	for (var menu : GameObject in helps)
	{
		if (menu.name == "Sommary")
		{
			sommary = menu;
			menu.gameObject.SetActive(true);
		}
		else
			menu.gameObject.SetActive(false);
	}
	return (false);
}

function isBattleGround()
{
	if (Application.loadedLevelName == "Battleground")
		return (true);
	return (false);
}

function help(helps : GameObject[], buttonsomtuto : GameObject)
{
	var button_help = GameObject.FindGameObjectsWithTag("Button_Tuto");

	yield WaitForSeconds(0.01);
	for (var button : GameObject in button_help)
	{
		if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(button))
		{
			for (var new_menu : GameObject in helps)
			{
				if (new_menu.name == button.name && sommary.gameObject.activeInHierarchy)
				{
					buttonsomtuto.gameObject.SetActive(true);
					new_menu.gameObject.SetActive(true);
				}
				else if (button.name == "Som_tuto" && !isBattleGround())
				{
					som_tuto(helps, buttonsomtuto);
					return ;
				}
				else if (button.name == "Som_tuto" && isBattleGround())
				{
					som_tuto(helps, buttonsomtuto);
					return ;				
				}
			}
			sommary.gameObject.SetActive(false);
		}
	}
	if (isBattleGround() && menu_tuto.activeInHierarchy)
	{
		yield WaitForSeconds(0.01);
		if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(button_cancel))
			menu_tuto.SetActive(false);
	}
}