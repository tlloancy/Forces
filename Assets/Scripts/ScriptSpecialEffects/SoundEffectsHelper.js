#pragma strict

var Instance : SoundEffectsHelper;
var Boum : AudioClip;
var cam : GameObject;
//var ValeurCurseurHorizontal : float;
//static var volume : float;
private var gnrl_script : GeneralMenu;
var optmenu : GameObject;
var hs_menu : GameObject;
private var buttons_opt : GameObject[];
private var hs_texts : GameObject[];
private var music : int;
private var once_music : boolean;
private var music_valid : GameObject;
private var sound : boolean;
private var wait : boolean;
private var opt_cancel : GameObject;
private var button_opt : GameObject;

private var button_menu : GameObject;
var menu : GameObject;
private var resume : GameObject;
private var exit : GameObject;

private var start : int;
var hs : int;

private var gameplay : int;
private var gamewin : int;
//PlayerPrefs.SetInt("Sound", 1);

function Awake()
{
	if (Instance != null)
		Debug.LogError("Multiple instances of SoundEffectsHelper");
	Instance = this;
}

function Start ()
{
	gnrl_script = GameObject.Find("Space").GetComponent(GeneralMenu);
	optmenu = gnrl_script.option_menu;
	buttons_opt = gnrl_script.options;
	opt_cancel = gnrl_script.opt_cancel;
	hs_menu = gnrl_script.hs_menu;
	cam = GameObject.Find("Main Camera");
	once_music = false;
	DontDestroyOnLoad(optmenu);
	start = 0;
	hs = 0;
	
	var nbr_scriptSF : int = 0;
	var nbr_optmenu : int = 0;
	var tmp_opt_menu : GameObject;
	
	for (var sf : GameObject in GameObject.FindGameObjectsWithTag("Sound"))
		nbr_scriptSF++;
	if (nbr_scriptSF  >= 2)
		Destroy(this.gameObject);
//	ValeurCurseurHorizontal = GetComponent(AudioSource).volume * 10;
}

function sounds(id : int)
{
	if (id == 1)
		MakeSound(Boum);
}

function MakeMusic()
{
	music = PlayerPrefs.GetInt("Sound");
	if (music)
		MakeMix();
}

function ShutMusic()
{
	music = PlayerPrefs.GetInt("Sound");
	if (!music)
		ShutMix();
}

function MakeSound(originalClip : AudioClip)
{
	if (sound == true)
		AudioSource.PlayClipAtPoint(originalClip, transform.position);
}

function MakeMix()
{
	audio.Play();
}

function ShutMix()
{
	audio.Stop();
}

function bydefault(buttons : GameObject[])
{
	for (var button : GameObject in buttons)
	{
		if (button.name.IndexOf("Mute") != -1)
			button.renderer.enabled = false;
		if (button.name == "Music_Valid")
			music_valid = button;
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

function option_menu()
{
	if (Application.loadedLevelName == "Battleground")
	{
		yield WaitForSeconds(0.01);
		if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(opt_cancel)
			&& optmenu.activeInHierarchy)
			optmenu.SetActive(false);
		else if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(button_opt)
				&& !optmenu.activeInHierarchy
				&& !GameObject.Find("0 - Decor").GetComponent(Tutorial).menu_tuto.activeInHierarchy
				&& !menu.activeInHierarchy)
			optmenu.SetActive(true);
	}
}

function menu_pause()
{
	if (Application.loadedLevelName == "Battleground")
	{
		yield WaitForSeconds(0.01);
		if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(button_menu)
			&& !optmenu.activeInHierarchy
			&& !GameObject.Find("0 - Decor").GetComponent(Tutorial).menu_tuto.activeInHierarchy
			&& !menu.activeInHierarchy)
			menu.SetActive(true);
		else if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(resume)
			&& menu.activeInHierarchy)
			menu.SetActive(false);
	}
}

function display_on_off(str : String, str1 : String, button : GameObject)
{
	for (var new_butt in GameObject.FindGameObjectsWithTag("Options"))
	{
		if (new_butt.name == str + "_" + str1)
		{
			yield WaitForSeconds(0.01);
			new_butt.renderer.enabled = true;
		}
	}
}

function display_option()
{
	for (var button : GameObject in GameObject.FindGameObjectsWithTag("Options"))
	{
		if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(button) && button.renderer.enabled)
		{
			if (button.name == "Music_Valid")
				display_on_off("Music", "Mute", button);
			else if (button.name == "Music_Mute")
				display_on_off("Music", "Valid", button);
			else if (button.name == "Sound_Valid")
				display_on_off("Sound", "Mute", button);
			else if (button.name == "Sound_Mute")
				display_on_off("Sound", "Valid", button);
			button.renderer.enabled = false;
		}
	}
}

function display_menu()
{
	if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(exit))
	{
		for (var play : GameObject in GameObject.FindGameObjectsWithTag("Player"))
			Network.Destroy(play);
		Network.Disconnect();
		Application.LoadLevel("menu");
		yield WaitForSeconds(0.1);
		var newoptmenu : GameObject = GameObject.Find("Space").GetComponent(GeneralMenu).option_menu;
		Destroy(newoptmenu);
		optmenu.transform.position.z = -3;
		optmenu.transform.localScale.x = 1;
		optmenu.transform.localScale.y = 1;
		hs = 0;
	}
}

function sound_on_off()
{
	for (var button : GameObject in buttons_opt)
	{
		if (button.name == "Music_Valid" && button.renderer.enabled && once_music == false && !GameObject.Find("Waiting_Room(Clone)"))
		{
			PlayerPrefs.SetInt("Sound", 1);
			once_music = true;
			MakeMix();
		}
		else if ((button.name == "Music_Mute" && button.renderer.enabled) || GameObject.Find("Waiting_Room(Clone)"))
		{
			PlayerPrefs.SetInt("Sound", 0);
			once_music = false;
			ShutMusic();
		}
		else if (button.name == "Sound_Valid" && button.renderer.enabled)
			sound = true;
		else if (button.name == "Sound_Mute" && button.renderer.enabled)
			sound = false;
	}
}

function battleground_start()
{
	cam = GameObject.Find("Main Camera");
	optmenu.transform.position.z = -7;
	optmenu.transform.localScale.x = 1.7;
	optmenu.transform.localScale.y = 1.7;
	button_opt = GameObject.Find("a - Boxes/Options/Options");
	button_menu = GameObject.Find("a - Boxes/Options/Menu");
	menu = GameObject.Find("Menu_Pause");
	resume = GameObject.Find("Menu_Pause/Resume");
	exit = GameObject.Find("Menu_Pause/Exit");
	menu.SetActive(false);
	start = 1;
	gameplay = PlayerPrefs.GetInt("GamePlay") + 1;
	PlayerPrefs.SetInt("GamePlay", gameplay);
}

function GetHighscore()
{
	hs = 1;
	hs_menu = GameObject.Find("Space").GetComponent(GeneralMenu).hs_menu;
	hs_menu.SetActive(true);
	for (var txt : GameObject in GameObject.FindGameObjectsWithTag("HighScores"))
	{
		if (txt.name == "Games_Played")
			txt.GetComponent(TextMesh).text = " " + PlayerPrefs.GetInt("GamePlay");
		else if (txt.name == "Games_won")
			txt.GetComponent(TextMesh).text = " " + PlayerPrefs.GetInt("GameWin");
		else if (txt.name == "Ratio" && PlayerPrefs.GetInt("GamePlay") != 0)
		{
			var jeujouee : float = PlayerPrefs.GetInt("GamePlay");
			var jeugagnee : float = PlayerPrefs.GetInt("GameWin");
			var total_bis : float = (jeugagnee / jeujouee) * 100;
			var total_ter : int = total_bis * 100;
			var total_quart : float = total_ter;
			var total : float = total_quart / 100;
			txt.GetComponent(TextMesh).text = total + " %";
		}
	}
	hs_menu.SetActive(false);
}

function Update()
{
	if (Application.loadedLevelName == "Battleground")
	{
		if (start == 0)
			battleground_start();
		if (menu.activeInHierarchy)
			display_menu();
	}
	else
	{
		if (hs == 0)
			GetHighscore();
		start = 0;
		cam = GameObject.Find("Main Camera");
	}
	if (optmenu.activeInHierarchy )
		display_option();
	sound_on_off();
	option_menu();
	menu_pause();
}


// Curseur Horizontal pour controler le volume général

/*
function OnGUI () 
{
	if (script_gnrl.option_menu.activeInHierarchy)
	{
		ValeurCurseurHorizontal = GUI.HorizontalSlider (Rect (400, 200, 200, 20), ValeurCurseurHorizontal, 0.0, 10.0);
		//GUI.Box(Rect(0,0,100,35),"Volume"); 
		AudioListener.volume = ValeurCurseurHorizontal / 10;
	}
}
*/