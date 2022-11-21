var cam : GameObject;

var soldier : int = 0;
var raider : int = 0;
var cruiser : int = 0;
var hunter : int = 0;
var commando : int = 0;
var bomber : int = 0;
var fighter : int = 0;
var destroyer : int = 0;
var h_bomb : int = 0;

var coordsoldier : float[];
var coordraider : float[];
var coordcruiser : float[];
var coordhunter : float[];
var coordcommando : float[];
var coordbomber : float[];
var coordfighter : float[];
var coorddestroyer : float[];
var coordh_bomb : float[];
private var allforcethroughnet : int = 0;

var ressoldierall : int = 0;
var resraiderall : int = 0;
var reshunterall : int = 0;
var rescruiserall : int = 0;
var rescommandoall : int = 0;
var resbomberall : int = 0;
var resfighterall : int = 0;
var resdestroyerall : int = 0;
var resforceall : int = 0;
var reshbomball : int = 0;
var color_nb : int;

var exe_blue : int = 0;
var exe_red : int = 0;
var exe_yellow : int = 0;

var decor : GameObject[];
private var move : GameObject[];

private var scriptbibli : Biblidecor;
var scriptinfo : allInfo;
var scriptinfoblue : allInfo;
var scriptinfored : allInfo;
var scriptinfoyellow : allInfo;
var iablue : ScriptIA_blue;
var iayellow : ScriptIA_yellow;
var iared : ScriptIA_red;
var playblue : playerTurn;
var playyellow : playerTurn;
var playred : playerTurn;
var playgreen : playerTurn;
var script_orders : orders;
var script_chaos : chaos;
private var butt : infoButtons;

private var win : GameObject;
private var loose : GameObject;
private var time : int = 1;
private var wait_time : int = 1;
var round : int = 1;
var round1 : int = 1;
var round2 : int = 1;
var ia : int = 0;

private var execblue : int = 0;

var button_info : GameObject[];
private var button_pay : GameObject[];
private var button_reserve : GameObject[];
var button_pad : GameObject[];
private var hbomb_pad : GameObject[];
var info_case : GameObject;

var wait_ordre : int = 0;
var wait_exe : int = 0;
var wait_exebis : int = 0;
var wait_change : int = 0;
var wait_eg : int = 0;
var wait_egbis : int = 0;
var wait_sup : int = 0;
var wait_fight : int = 0;

function force_reserve (script : allInfo) {
	var allforce : int = 0;

	allforce += (script.ressoldier * 2);
	allforce += (script.resraider * 3);
	allforce += (script.reshunter * 5);
	allforce += (script.rescruiser * 10);
	allforce += (script.rescommando * 20);
	allforce += (script.resbomber * 30);
	allforce += (script.resfighter * 25);
	allforce += (script.resdestroyer * 50);
	allforce += (script.force);
	return (allforce);
}

function end_game () {
	var myforce : int = 0;
	var force_blue : int = 0;
	var force_red : int = 0;
	var force_yellow : int = 0;
	var count : int = 0;

	for (var dec : GameObject in decor) {
		myforce += all_view(dec, scriptinfo, 0);
		force_blue += all_view(dec, scriptinfoblue, 1);
		force_red += all_view(dec, scriptinfored, 2);
		force_yellow += all_view(dec, scriptinfoyellow, 3);
	}
	myforce += force_reserve(scriptinfo);
	force_blue += force_reserve(scriptinfoblue);
	force_red += force_reserve(scriptinfored);
	force_yellow += force_reserve(scriptinfoyellow);
	count = comp_force(myforce, force_blue, force_red, force_yellow);

	if ((scriptinfo.isalive == 1 && !scriptinfoblue.isalive && !scriptinfored.isalive && !scriptinfoyellow.isalive)
		|| count == -1 || count == -5)
		win.SetActive(true);
	else
		loose.SetActive(true);

	if (Input.GetKeyDown(KeyCode.Mouse0))
	{
		for (var play : GameObject in GameObject.FindGameObjectsWithTag("Player"))
			Network.Destroy(play);
		Network.Disconnect();
		if (win.activeInHierarchy)
		{
			var highscore_wins : int = PlayerPrefs.GetInt("GameWin") + 1;
			PlayerPrefs.SetInt("GameWin", highscore_wins);
		}
		Application.LoadLevel("menu");
		GameObject.Find("ScriptSF").GetComponent(SoundEffectsHelper).hs = 0;
	}
}

function Zone_Click (object : GameObject) {
	var ht = object.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = object.GetComponent(SpriteRenderer).sprite.rect.width;
	var pos = cam.camera.ScreenPointToRay(Input.mousePosition);
	var height : float;
	var width : float;

	if (object.transform.rotation.z == 0) {
		height = (ht * object.transform.lossyScale.y) / 200;
		width = (wh * object.transform.lossyScale.x) / 200;
	}
	else {
		width = (ht * object.transform.lossyScale.y) / 200;
		height = (wh * object.transform.lossyScale.x) / 200;
	}
	if (pos.origin.x > (object.transform.position.x - width)
		&& pos.origin.x < (object.transform.position.x + width)
		&& pos.origin.y > (object.transform.position.y - height)
		&& pos.origin.y < (object.transform.position.y + height)
		&& GetComponent(Tutorial).menu_tuto.activeInHierarchy == false
		&& GameObject.Find("ScriptSF").GetComponent(SoundEffectsHelper).optmenu.activeInHierarchy == false
		&& GameObject.Find("ScriptSF").GetComponent(SoundEffectsHelper).menu.activeInHierarchy == false)
		return (true);
	return (false);
}

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

function view (dec : GameObject, save : GameObject[], i : int) {
	var ht = dec.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = dec.GetComponent(SpriteRenderer).sprite.rect.width;
    var pos = cam.camera.ScreenPointToRay(Input.mousePosition);
    var height = (ht * dec.transform.lossyScale.x) / 200;
    var width = (wh * dec.transform.lossyScale.y) / 200;
    var count : int;
    var val : int;
    var verif : int;
    var nb : int;

    verif = 0;
    count = -1;
    val = 0;
    nb = 0;
    while (save[++count]) {
        if (save[count].transform.position.x < dec.transform.position.x + width
            && save[count].transform.position.x > dec.transform.position.x - width
            && save[count].transform.position.y < dec.transform.position.y + height
            && save[count].transform.position.y > dec.transform.position.y - height) {
            if (!i) {
                val = count;
                verif = 1;
            }
            else
                nb++;
        }
    }
    if (i)
        return (nb);
    if (verif)
        return (val);
    else
        return (-1);
}

function view2 (dec : GameObject, save : float[], i : int) {
	var ht = dec.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = dec.GetComponent(SpriteRenderer).sprite.rect.width;
    var pos = cam.camera.ScreenPointToRay(Input.mousePosition);
    var height = (ht * dec.transform.lossyScale.x) / 200;
    var width = (wh * dec.transform.lossyScale.y) / 200;
    var count : int;
    var val : int;
    var verif : int;
    var nb : int;

    verif = 0;
    count = 0;
    val = 0;
    nb = 0;
	while (save[count]) {
        if (save[count] < dec.transform.position.x + width
            && save[count] > dec.transform.position.x - width
            && save[count + 1] < dec.transform.position.y + height
            && save[count + 1] > dec.transform.position.y - height) {
            if (!i) {
                val = count;
                verif = 1;
            }
            else
                nb++;
        }
        count += 2;
    }
    if (i)
        return (nb);
    if (verif)
        return (val);
    else
        return (-1);
}

function Start () {

	Screen.orientation = ScreenOrientation.LandscapeLeft;
	decor = GameObject.FindGameObjectsWithTag("Decor");
	move = GameObject.FindGameObjectsWithTag("Move");
	win = GameObject.Find("Winner");
	win.SetActive(false);
	loose = GameObject.Find("Loose");
	loose.SetActive(false);

	script_orders = GetComponent(orders);
	script_chaos = GetComponent(chaos);
	butt = GameObject.Find(propre("green")).GetComponent(infoButtons);

	scriptbibli = GameObject.Find("Main Camera").GetComponent(Biblidecor);

	button_info = GameObject.FindGameObjectsWithTag("Button_Info");
	button_pay = GameObject.FindGameObjectsWithTag("Button_Pay");
	button_reserve = GameObject.FindGameObjectsWithTag("Button_Reserve");
	button_pad = GameObject.FindGameObjectsWithTag("Button_Pad");
	hbomb_pad = GameObject.FindGameObjectsWithTag("HBomb");
	info_case = GameObject.Find("a - Boxes/Infos_Box");

	for (var info : GameObject in button_info)
		info.SetActive(false);
	for (var pad : GameObject in button_pad)
		pad.SetActive(false);
	name_button("Reserve_HBomb1").SetActive(false);
	name_button("Reserve_HBomb2").SetActive(false);
	name_button("Reserve_HBomb3").SetActive(false);
	info_case.SetActive(false);

	var bleu : GameObject;
	var rouge : GameObject;
	var jaune : GameObject;
	var vert : GameObject;

	bleu = GameObject.Find(propre("blue"));
	rouge = GameObject.Find(propre("red"));
	jaune = GameObject.Find(propre("yellow"));
	vert = GameObject.Find(propre("green"));

	if (bleu.name.IndexOf("PLAY") != -1)
		playblue = bleu.GetComponent(playerTurn);
	else
		iablue = bleu.GetComponent(ScriptIA_blue);
	if (rouge.name.IndexOf("PLAY") != -1)
		playred = rouge.GetComponent(playerTurn);
	else
		iared = rouge.GetComponent(ScriptIA_red);
	if (jaune.name.IndexOf("PLAY") != -1)
		playyellow = jaune.GetComponent(playerTurn);
	else
		iayellow = jaune.GetComponent(ScriptIA_yellow);

	scriptinfo = vert.GetComponent(allInfo);
	scriptinfoblue = bleu.GetComponent(allInfo);
	scriptinfored = rouge.GetComponent(allInfo);
	scriptinfoyellow = jaune.GetComponent(allInfo);

	playgreen = rouge.GetComponent(playerTurn);
	playred = rouge.GetComponent(playerTurn);
	playblue = bleu.GetComponent(playerTurn);
	playyellow = jaune.GetComponent(playerTurn);

	scriptinfo.Stop();
	scriptinfoblue.Stop();
	scriptinfored.Stop();
	scriptinfoyellow.Stop();
}

function name_button (name : String) {
	for (var info : GameObject in button_info) {
		if (name == info.name)
			return (info);
	}
	for (var pay : GameObject in button_pay) {
		if (name == pay.name)
			return (pay);
	}
	for (var reserve : GameObject in button_reserve) {
		if (name == reserve.name)
			return (reserve);
	}
	for (var pad : GameObject in button_pad) {
		if (name == pad.name)
			return (pad);
	}
	for (var hb : GameObject in hbomb_pad) {
		if (name == hb.name)
			return (hb);
	}
	return (null);
}

function collect_force (script : allInfo) {
	var val : int;

	val = 0;
	if (scriptinfoblue.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Ice_NW" || dec.name == "Ice_N" || dec.name == "Ice_NE" || dec.name == "Ice_W" || dec.name == "Ice_C"
				|| dec.name == "Ice_E" || dec.name == "Ice_SW" || dec.name == "Ice_S" || dec.name == "Ice_SE") && !val) {
				val = butt.view(dec, script.save_soldier, 1, butt.soldier_use);
				if (!val)
					val = butt.view(dec, script.save_raider, 1, butt.raider_use);
				if (!val)
					val = butt.view(dec, script.save_hunter, 1, butt.hunter_use);
				if (!val)
					val = butt.view(dec, script.save_cruiser, 1, butt.cruiser_use);
				if (!val)
					val = butt.view(dec, script.save_commando, 1, butt.commando_use);
				if (!val)
					val = butt.view(dec, script.save_bomber, 1, butt.bomber_use);
				if (!val)
					val = butt.view(dec, script.save_fighter, 1, butt.fighter_use);
				if (!val)
					val = butt.view(dec, script.save_destroyer, 1, butt.destroyer_use);
			}
		}
		if (val)
			script.force++;
	}
	val = 0;
	if (scriptinfored.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Jungle_NW" || dec.name == "Jungle_N" || dec.name == "Jungle_NE" || dec.name == "Jungle_W"
				|| dec.name == "Jungle_C" || dec.name == "Jungle_E" || dec.name == "Jungle_SW" || dec.name == "Jungle_S"
				|| dec.name == "Jungle_SE") && !val) {
				val = butt.view(dec, script.save_soldier, 1, butt.soldier_use);
				if (!val)
					val = butt.view(dec, script.save_raider, 1, butt.raider_use);
				if (!val)
					val = butt.view(dec, script.save_hunter, 1, butt.hunter_use);
				if (!val)
					val = butt.view(dec, script.save_cruiser, 1, butt.cruiser_use);
				if (!val)
					val = butt.view(dec, script.save_commando, 1, butt.commando_use);
				if (!val)
					val = butt.view(dec, script.save_bomber, 1, butt.bomber_use);
				if (!val)
					val = butt.view(dec, script.save_fighter, 1, butt.fighter_use);
				if (!val)
					val = butt.view(dec, script.save_destroyer, 1, butt.destroyer_use);
			}
		}
		if (val)
			script.force++;
	}
	val = 0;
	if (scriptinfoyellow.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Desert_NW" || dec.name == "Desert_N" || dec.name == "Desert_NE" || dec.name == "Desert_W"
				|| dec.name == "Desert_C" || dec.name == "Desert_E" || dec.name == "Desert_SW" || dec.name == "Desert_S"
				|| dec.name == "Desert_SE") && !val) {
				val = butt.view(dec, script.save_soldier, 1, butt.soldier_use);
				if (!val)
					val = butt.view(dec, script.save_raider, 1, butt.raider_use);
				if (!val)
					val = butt.view(dec, script.save_hunter, 1, butt.hunter_use);
				if (!val)
					val = butt.view(dec, script.save_cruiser, 1, butt.cruiser_use);
				if (!val)
					val = butt.view(dec, script.save_commando, 1, butt.commando_use);
				if (!val)
					val = butt.view(dec, script.save_bomber, 1, butt.bomber_use);
				if (!val)
					val = butt.view(dec, script.save_fighter, 1, butt.fighter_use);
				if (!val)
					val = butt.view(dec, script.save_destroyer, 1, butt.destroyer_use);
			}
		}
		if (val)
			script.force++;
	}
/*	val = 0;
	if (scriptinfo.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Plains_NW" || dec.name == "Plains_N" || dec.name == "Plains_NE" || dec.name == "Plains_W"
				|| dec.name == "Plains_C" || dec.name == "Plains_E" || dec.name == "Plains_SW" || dec.name == "Plains_S"
				|| dec.name == "Plains_SE") && !val) {
				val = butt.view(dec, script.save_soldier, 1, butt.soldier_use);
				if (!val)
					val = butt.view(dec, script.save_raider, 1, butt.raider_use);
				if (!val)
					val = butt.view(dec, script.save_hunter, 1, butt.hunter_use);
				if (!val)
					val = butt.view(dec, script.save_cruiser, 1, butt.cruiser_use);
				if (!val)
					val = butt.view(dec, script.save_commando, 1, butt.commando_use);
				if (!val)
					val = butt.view(dec, script.save_bomber, 1, butt.bomber_use);
				if (!val)
					val = butt.view(dec, script.save_fighter, 1, butt.fighter_use);
				if (!val)
					val = butt.view(dec, script.save_destroyer, 1, butt.destroyer_use);
			}
		}
		if (val)
			script.force++;
	}*/
}

function all_view (dec : GameObject, script : allInfo, color : int) {
	var allforce : int = 0;
	var val : int;

	if (!Network.isServer && color == 0)
		StartBroadcast(dec, "green");
	else if (!Network.isServer && color == 2)
		StartBroadcast(dec, "red");
	else if (!Network.isServer && color == 3)
		StartBroadcast(dec, "yellow");
	else if (Network.isServer && color == 1 && playblue)
		StartBroadcast(dec, "blue");
	else {
		val = view(dec, script.save_soldier, 2);
		allforce += (val * 2);
		val = view(dec, script.save_raider, 2);
		allforce += (val * 3);
		val = view(dec, script.save_cruiser, 2);
		allforce += (val * 10);
		val = view(dec, script.save_hunter, 2);
		allforce += (val * 5);
		val = view(dec, script.save_commando, 2);
		allforce += (val * 20);
		val = view(dec, script.save_bomber, 2);
		allforce += (val * 30);
		val = view(dec, script.save_fighter, 2);
		allforce += (val * 25);
		val = view(dec, script.save_destroyer, 2);
		allforce += (val * 50);
		return (allforce);
	}
	return allforcethroughnet;
}

function comp_force (force1 : int, force2 : int, force3 : int, force4 : int) {
	var count : int = 0;

	if (force1 > force2 && force1 > force3 && force1 > force4 && (force2 || force3 || force4))
		return (-1);
	if (force2 > force1 && force2 > force3 && force2 > force4 && (force1 || force3 || force4))
		return (-2);
	if (force3 > force2 && force3 > force1 && force3 > force4 && (force2 || force1 || force4))
		return (-3);
	if (force4 > force2 && force4 > force3 && force4 > force1 && (force2 || force3 || force1))
		return (-4);
	if (force1 > force2 && force1 > force3 && force1 > force4)
		return (-5);
	if (force2 > force1 && force2 > force3 && force2 > force4)
		return (-6);
	if (force3 > force2 && force3 > force1 && force3 > force4)
		return (-7);
	if (force4 > force2 && force4 > force3 && force4 > force1)
		return (-8);
	if (!force1 && !force2 && !force3 && !force4)
		return (0);
	else {
		if (force1 == force2 && force1 == force3 && force1 == force4)
			count = 71;
		else if (force2 == force3 && force2 == force4)
			count = 70;
		else if (force1 == force3 && force1 == force4)
			count = 61;
		else if (force1 == force2 && force1 == force4)
			count = 51;
		else if (force1 == force2 && force1 == force3)
			count = 31;
		else if (force3 == force4 && force3 && force4)
			count = 60;
		else if (force2 == force4 && force2 && force4)
			count = 50;
		else if (force2 == force3 && force3 && force2)
			count = 30;
		else if (force1 == force4 && force1 && force4)
			count = 41;
		else if (force1 == force3 && force3 && force1)
			count = 21;
		else if (force1 == force2 && force1 && force2)
			count = 11;
		else
			count = 100;
		return (count);
	}
	return (0);
}


function up_and_kill_next (dec : GameObject, scriptres : int, number : int, script2 : allInfo, script3 : allInfo, script4 : allInfo) {
	var save : GameObject[];
	var save1 : GameObject[];
	var save2 : GameObject[];
	var nbsave : int;
	var nbsave1 : int;
	var nbsave2 : int;
	var val : int;

	if (number == 1) {
		save = script2.save_soldier;
		save1 = script3.save_soldier;
		save2 = script4.save_soldier;
		nbsave = script2.nbsoldier;
		nbsave1 = script3.nbsoldier;
		nbsave2 = script4.nbsoldier;
	}
	else if (number == 2) {
		save = script2.save_raider;
		save1 = script3.save_raider;
		save2 = script4.save_raider;
		nbsave = script2.nbraider;
		nbsave1 = script3.nbraider;
		nbsave2 = script4.nbraider;
	}
	else if (number == 3) {
		save = script2.save_hunter;
		save1 = script3.save_hunter;
		save2 = script4.save_hunter;
		nbsave = script2.nbhunter;
		nbsave1 = script3.nbhunter;
		nbsave2 = script4.nbhunter;
	}
	else if (number == 4) {
		save = script2.save_cruiser;
		save1 = script3.save_cruiser;
		save2 = script4.save_cruiser;
		nbsave = script2.nbcruiser;
		nbsave1 = script3.nbcruiser;
		nbsave2 = script4.nbcruiser;
	}
	else if (number == 5) {
		save = script2.save_commando;
		save1 = script3.save_commando;
		save2 = script4.save_commando;
		nbsave = script2.nbcommando;
		nbsave1 = script3.nbcommando;
		nbsave2 = script4.nbcommando;
	}
	else if (number == 6) {
		save = script2.save_bomber;
		save1 = script3.save_bomber;
		save2 = script4.save_bomber;
		nbsave = script2.nbbomber;
		nbsave1 = script3.nbbomber;
		nbsave2 = script4.nbbomber;
	}
	else if (number == 7) {
		save = script2.save_fighter;
		save1 = script3.save_fighter;
		save2 = script4.save_fighter;
		nbsave = script2.nbfighter;
		nbsave1 = script3.nbfighter;
		nbsave2 = script4.nbfighter;
	}
	else if (number == 8) {
		save = script2.save_destroyer;
		save1 = script3.save_destroyer;
		save2 = script4.save_destroyer;
		nbsave = script2.nbdestroyer;
		nbsave1 = script3.nbdestroyer;
		nbsave2 = script4.nbdestroyer;
	}
	else if (number == 9) {
		save = script2.save_hbomb;
		save1 = script3.save_hbomb;
		save2 = script4.save_hbomb;
		nbsave = script2.nbhbomb;
		nbsave1 = script3.nbhbomb;
		nbsave2 = script4.nbhbomb;
	}
	val = view(dec, save, 0);
	while (val != -1) {
		kill_pion(val, save, nbsave);
		scriptres++;
		nbsave--;
		val = view(dec, save, 0);
	}
	val = view(dec, save1, 0);
	while (val != -1) {
		kill_pion(val, save1, nbsave1);
		scriptres++;
		nbsave1--;
		val = view(dec, save1, 0);
	}
	val = view(dec, save2, 0);
	while (val != -1) {
		kill_pion(val, save2, nbsave2);
		scriptres++;
		nbsave2--;
		val = view(dec, save2, 0);
	}
	if (number == 1) {
		script2.nbsoldier = nbsave;
		script3.nbsoldier = nbsave1;
		script4.nbsoldier = nbsave2;
	}
	else if (number == 2) {
		script2.nbraider = nbsave;
		script3.nbraider = nbsave1;
		script4.nbraider = nbsave2;
	}
	else if (number == 3) {
		script2.nbhunter = nbsave;
		script3.nbhunter = nbsave1;
		script4.nbhunter = nbsave2;
	}
	else if (number == 4) {
		script2.nbcruiser = nbsave;
		script3.nbcruiser = nbsave1;
		script4.nbcruiser = nbsave2;
	}
	else if (number == 5) {
		script2.nbcommando = nbsave;
		script3.nbcommando = nbsave1;
		script4.nbcommando = nbsave2;
	}
	else if (number == 6) {
		script2.nbbomber = nbsave;
		script3.nbbomber = nbsave1;
		script4.nbbomber = nbsave2;
	}
	else if (number == 7) {
		script2.nbfighter = nbsave;
		script3.nbfighter = nbsave1;
		script4.nbfighter = nbsave2;
	}
	else if (number == 8) {
		script2.nbdestroyer = nbsave;
		script3.nbdestroyer = nbsave1;
		script4.nbdestroyer = nbsave2;
	}
	else if (number == 9) {
		script2.nbhbomb = nbsave;
		script3.nbhbomb = nbsave1;
		script4.nbhbomb = nbsave2;
	}
	return (scriptres);
}

function up_and_kill (dec : GameObject, script1 : allInfo, script2 : allInfo, script3 : allInfo, script4 : allInfo) {
	script1.ressoldier = up_and_kill_next(dec, script1.ressoldier, 1, script2, script3, script4);
	script1.resraider = up_and_kill_next(dec, script1.resraider, 2, script2, script3, script4);
	script1.reshunter = up_and_kill_next(dec, script1.reshunter, 3, script2, script3, script4);
	script1.rescruiser = up_and_kill_next(dec, script1.rescruiser, 4, script2, script3, script4);
	script1.rescommando = up_and_kill_next(dec, script1.rescommando, 5, script2, script3, script4);
	script1.resbomber = up_and_kill_next(dec, script1.resbomber, 6, script2, script3, script4);
	script1.resfighter = up_and_kill_next(dec, script1.resfighter, 7, script2, script3, script4);
	script1.resdestroyer = up_and_kill_next(dec, script1.resdestroyer, 8, script2, script3, script4);
	script1.reshbomb = up_and_kill_next(dec, script1.reshbomb, 9, script2, script3, script4);
}

function kill_hq (scripthqkill : allInfo, scripthqwin : allInfo) {
	scripthqkill.isalive = 0;
	scripthqwin.force += scripthqkill.force;
	scripthqkill.force = 0;
	scripthqwin.ressoldier += scripthqkill.ressoldier;
	scripthqwin.resraider += scripthqkill.resraider;
	scripthqwin.reshunter += scripthqkill.reshunter;
	scripthqwin.rescruiser += scripthqkill.rescruiser;
	scripthqwin.rescommando += scripthqkill.rescommando;
	scripthqwin.resbomber += scripthqkill.resbomber;
	scripthqwin.resfighter += scripthqkill.resfighter;
	scripthqwin.resdestroyer += scripthqkill.resdestroyer;
	scripthqwin.reshbomb += scripthqkill.reshbomb;
	scripthqkill.ressoldier = 0;
	scripthqkill.resraider = 0;
	scripthqkill.reshunter = 0;
	scripthqkill.rescruiser = 0;
	scripthqkill.rescommando = 0;
	scripthqkill.resbomber = 0;
	scripthqkill.resfighter = 0;
	scripthqkill.resdestroyer = 0;
	scripthqkill.reshbomb = 0;
	while (scripthqkill.save_soldier[0]) {
		kill_pion(0, scripthqkill.save_soldier, scripthqkill.nbsoldier);
		scripthqkill.nbsoldier--;
		scripthqwin.ressoldier++;
	}
	while (scripthqkill.save_raider[0]) {
		kill_pion(0, scripthqkill.save_raider, scripthqkill.nbraider);
		scripthqkill.nbraider--;
		scripthqwin.resraider++;
	}
	while (scripthqkill.save_hunter[0]) {
		kill_pion(0, scripthqkill.save_hunter, scripthqkill.nbhunter);
		scripthqkill.nbhunter--;
		scripthqwin.reshunter++;
	}
	while (scripthqkill.save_cruiser[0]) {
		kill_pion(0, scripthqkill.save_cruiser, scripthqkill.nbcruiser);
		scripthqkill.nbcruiser--;
		scripthqwin.rescruiser++;
	}
	while (scripthqkill.save_commando[0]) {
		kill_pion(0, scripthqkill.save_commando, scripthqkill.nbcommando);
		scripthqkill.nbcommando--;
		scripthqwin.rescommando++;
	}
	while (scripthqkill.save_bomber[0]) {
		kill_pion(0, scripthqkill.save_bomber, scripthqkill.nbbomber);
		scripthqkill.nbbomber--;
		scripthqwin.resbomber++;
	}
	while (scripthqkill.save_fighter[0]) {
		kill_pion(0, scripthqkill.save_fighter, scripthqkill.nbfighter);
		scripthqkill.nbfighter--;
		scripthqwin.resfighter++;
	}
	while (scripthqkill.save_destroyer[0]) {
		kill_pion(0, scripthqkill.save_destroyer, scripthqkill.nbdestroyer);
		scripthqkill.nbdestroyer--;
		scripthqwin.resdestroyer++;
	}
	while (scripthqkill.save_hbomb[0]) {
		kill_pion(0, scripthqkill.save_hbomb, scripthqkill.nbhbomb);
		scripthqkill.nbhbomb--;
		scripthqwin.reshbomb++;
	}
}

function exe_fight_hq (hqgreen : GameObject, hqblue : GameObject, hqred : GameObject, hqyellow : GameObject) {
	var count : int = 0;
	var myforce : int;
	var force_blue : int;
	var force_yellow : int;
	var force_red : int;

	if (hqgreen) {
		myforce = all_view(hqgreen, scriptinfo, 0);
		force_blue = all_view(hqgreen, scriptinfoblue, 1);
		force_red = all_view(hqgreen, scriptinfored, 2);
		force_yellow = all_view(hqgreen, scriptinfoyellow, 3);
		count = comp_force(myforce, force_blue, force_red, force_yellow);
		if (count >= -4 && count <= -1)
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, hqgreen, count);
		if (count == -1)
			up_and_kill(hqgreen, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
		else {
			if (count == -2 || count == -6) {
				up_and_kill(hqgreen, scriptinfoblue, scriptinfo, scriptinfored, scriptinfoyellow);
				if ((view(hqgreen, scriptinfoblue.save_soldier, 1)) || (view(hqgreen, scriptinfoblue.save_commando, 1)))
					kill_hq(scriptinfo, scriptinfoblue);
			}
			else if (count == -3 || count == -7) {
				up_and_kill(hqgreen, scriptinfored, scriptinfoblue, scriptinfo, scriptinfoyellow);
				if ((view(hqgreen, scriptinfored.save_soldier, 1)) || (view(hqgreen, scriptinfored.save_commando, 1)))
					kill_hq(scriptinfo, scriptinfored);
			}
			else if (count == -4 || count == -8) {
				up_and_kill(hqgreen, scriptinfoyellow, scriptinfoblue, scriptinfored, scriptinfo);
				if (!(view(hqgreen, scriptinfoyellow.save_soldier, 1)) || !(view(hqgreen, scriptinfoyellow.save_commando, 1)))
					kill_hq(scriptinfo, scriptinfoyellow);
			}
		}
	}
	if (hqblue) {
		myforce = all_view(hqblue, scriptinfo, 0);
		force_blue = all_view(hqblue, scriptinfoblue, 1);
		force_red = all_view(hqblue, scriptinfored, 2);
		force_yellow = all_view(hqblue, scriptinfoyellow, 3);
		count = comp_force(myforce, force_blue, force_red, force_yellow);
		if (count >= -4 && count <= -1)
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, hqblue, count);
		if (count == -2)
			up_and_kill(hqblue, scriptinfoblue, scriptinfo, scriptinfored, scriptinfoyellow);
		else {
			if (count == -1 || count == -5) {
				up_and_kill(hqblue, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
				if ((view(hqblue, scriptinfo.save_soldier, 1)) || (view(hqblue, scriptinfo.save_commando, 1)))
					kill_hq(scriptinfoblue, scriptinfo);
			}
			else if (count == -3 || count == -7) {
				up_and_kill(hqblue, scriptinfored, scriptinfoblue, scriptinfo, scriptinfoyellow);
				if ((view(hqblue, scriptinfored.save_soldier, 1)) || (view(hqblue, scriptinfored.save_commando, 1)))
					kill_hq(scriptinfoblue, scriptinfored);
			}
			else if (count == -4 || count == -8) {
				up_and_kill(hqblue, scriptinfoyellow, scriptinfoblue, scriptinfored, scriptinfo);
				if ((view(hqblue, scriptinfoyellow.save_soldier, 1)) || (view(hqblue, scriptinfoyellow.save_commando, 1)))
					kill_hq(scriptinfoblue, scriptinfoyellow);
			}
		}
	}
	if (hqred) {
		myforce = all_view(hqred, scriptinfo, 0);
		force_blue = all_view(hqred, scriptinfoblue, 1);
		force_red = all_view(hqred, scriptinfored, 2);
		force_yellow = all_view(hqred, scriptinfoyellow, 3);
		count = comp_force(myforce, force_blue, force_red, force_yellow);
		if (count >= -4 && count <= -1)
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, hqred, count);
		if (count == -3)
			up_and_kill(hqred, scriptinfored, scriptinfoblue, scriptinfo, scriptinfoyellow);
		else {
			if (count == -2 || count == -6) {
				up_and_kill(hqred, scriptinfoblue, scriptinfo, scriptinfored, scriptinfoyellow);
				if ((view(hqred, scriptinfoblue.save_soldier, 1)) || (view(hqred, scriptinfoblue.save_commando, 1)))
					kill_hq(scriptinfored, scriptinfoblue);
			}
			else if (count == -1 || count == -5) {
				up_and_kill(hqred, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
				if ((view(hqred, scriptinfo.save_soldier, 1)) || (view(hqred, scriptinfo.save_commando, 1)))
					kill_hq(scriptinfored, scriptinfo);
			}
			else if (count == -4 || count == -8) {
				up_and_kill(hqred, scriptinfoyellow, scriptinfoblue, scriptinfored, scriptinfo);
				if ((view(hqred, scriptinfoyellow.save_soldier, 1)) || (view(hqred, scriptinfoyellow.save_commando, 1)))
					kill_hq(scriptinfored, scriptinfoyellow);
			}
		}
	}
	if (hqyellow) {
		myforce = all_view(hqyellow, scriptinfo, 0);
		force_blue = all_view(hqyellow, scriptinfoblue, 1);
		force_red = all_view(hqyellow, scriptinfored, 2);
		force_yellow = all_view(hqyellow, scriptinfoyellow, 3);
		count = comp_force(myforce, force_blue, force_red, force_yellow);
		if (count >= -4 && count <= -1)
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, hqyellow, count);
		if (count == -4)
			up_and_kill(hqyellow, scriptinfoyellow, scriptinfoblue, scriptinfored, scriptinfo);
		else {
			if (count == -2 || count == -6) {
				up_and_kill(hqyellow, scriptinfoblue, scriptinfo, scriptinfored, scriptinfoyellow);
				if ((view(hqyellow, scriptinfoblue.save_soldier, 1)) || (view(hqyellow, scriptinfoblue.save_commando, 1)))
					kill_hq(scriptinfoyellow, scriptinfoblue);
			}
			else if (count == -3 || count == -7) {
				up_and_kill(hqyellow, scriptinfored, scriptinfoblue, scriptinfo, scriptinfoyellow);
				if ((view(hqyellow, scriptinfored.save_soldier, 1)) || (view(hqyellow, scriptinfored.save_commando, 1)))
					kill_hq(scriptinfoyellow, scriptinfored);
			}
			else if (count == -1 || count == -5) {
				up_and_kill(hqyellow, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
				if ((view(hqyellow, scriptinfo.save_soldier, 1)) || (view(hqyellow, scriptinfo.save_commando, 1)))
					kill_hq(scriptinfoyellow, scriptinfo);
			}
		}
	}
}

function exe_fight_sup () {
	var count : int = 0;
	var myforce : int;
	var force_blue : int;
	var force_yellow : int;
	var force_red : int;
	var hqgreen : GameObject;
	var hqblue : GameObject;
	var hqred : GameObject;
	var hqyellow : GameObject;

	for (var dec : GameObject in decor) {
		myforce = all_view(dec, scriptinfo, 0);
		force_blue = all_view(dec, scriptinfoblue, 1);
		force_red = all_view(dec, scriptinfored, 2);
		force_yellow = all_view(dec, scriptinfoyellow, 3);
		count = comp_force(myforce, force_blue, force_red, force_yellow);
		if (count >= -4 && count <= -1)
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, dec, count);
		if (dec.name != "HQ_Green" && dec.name != "HQ_Blue" && dec.name != "HQ_Red" && dec.name != "HQ_Yellow") {
			if (count == -1 || count == -5) {
				if (count == -5 && (view(dec, scriptinfoblue.save_hbomb, 1)
					 || view(dec, scriptinfored.save_hbomb, 1)
					 || view(dec, scriptinfoyellow.save_hbomb, 1))) {
					up_and_kill(dec, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
					GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, dec, count);
				}
				else
					up_and_kill(dec, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
			}
			else if (count == -2 || count == -6) {
				if (count == -6 && (view(dec, scriptinfo.save_hbomb, 1)
					 || view(dec, scriptinfored.save_hbomb, 1)
					 || view(dec, scriptinfoyellow.save_hbomb, 1))) {
					up_and_kill(dec, scriptinfoblue, scriptinfo, scriptinfored, scriptinfoyellow);
					GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, dec, count);
				}
				else
					up_and_kill(dec, scriptinfoblue, scriptinfo, scriptinfored, scriptinfoyellow);
			}
			else if (count == -3 || count == -7) {
				if (count == -7 && (view(dec, scriptinfoblue.save_hbomb, 1)
					 || view(dec, scriptinfo.save_hbomb, 1)
					 || view(dec, scriptinfoyellow.save_hbomb, 1))) {
					up_and_kill(dec, scriptinfored, scriptinfoblue, scriptinfo, scriptinfoyellow);
					GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, dec, count);
				}
				else
					up_and_kill(dec, scriptinfored, scriptinfoblue, scriptinfo, scriptinfoyellow);
			}
			else if (count == -4 || count == -8) {
				if (count == -8 && (view(dec, scriptinfoblue.save_hbomb, 1)
					 || view(dec, scriptinfored.save_hbomb, 1)
					 || view(dec, scriptinfo.save_hbomb, 1))) {
					up_and_kill(dec, scriptinfoyellow, scriptinfoblue, scriptinfored, scriptinfo);
					GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, dec, count);
				}
				else
					up_and_kill(dec, scriptinfoyellow, scriptinfoblue, scriptinfored, scriptinfo);
			}
		}
		else {
			if (dec.name == "HQ_Green" && count < 0)
				hqgreen = dec;
			else if (dec.name == "HQ_Green")
				hqgreen = null;
			else if (dec.name == "HQ_Blue" && count < 0)
				hqblue = dec;
			else if (dec.name == "HQ_Blue")
				hqblue = null;
			else if (dec.name == "HQ_Red" && count < 0)
				hqred = dec;
			else if (dec.name == "HQ_Red")
				hqred = null;
			else if (dec.name == "HQ_Yellow" && count < 0)
				hqyellow = dec;
			else if (dec.name == "HQ_Yellow")
				hqyellow = null;
		}
	}
	exe_fight_hq(hqgreen, hqblue, hqred, hqyellow);
}





function kill_pion (val : int, save : GameObject[], number : int) {
	var count : int;

	if (val > -1) {
		if (val == (number - 1)) {
			Network.Destroy(save[val]);
			save[val] = null;
		}
		else if (val != (number - 1)) {
			count = -1;
			while (++count < number - 1) {
				if (count >= val)
					save[count].transform.position = save[count + 1].transform.position;
			}
			Network.Destroy(save[count]);
			save[count] = null;
		}
	}
}

function kill_reserve (script: allInfo) {
	script.ressoldier = 0;
	script.resraider = 0;
	script.reshunter = 0;
	script.rescruiser = 0;
	script.rescommando = 0;
	script.resbomber = 0;
	script.resfighter = 0;
	script.resdestroyer = 0;
	script.reshbomb = 0;
	script.force = 0;
}

function exe_ordre_h_bomb (depart : String, arriver : String, piece : String, script : allInfo) {
	if (depart.IndexOf("change") != -1) {
		if (depart == "changedec") {
			for (var dec : GameObject in decor) {
				if (dec.name == arriver) {
					var tab : Array = piece.Split("-"[0]);
					for (var tableau : String in tab) {
						if (tableau == "soldier") {
							var val = view(dec, script.save_soldier, 0);
							kill_pion(val, script.save_soldier, script.nbsoldier);
							script.nbsoldier--;
						}
						else if (tableau == "raider") {
							val = view(dec, script.save_raider, 0);
							kill_pion(val, script.save_raider, script.nbraider);
							script.nbraider--;
						}
						else if (tableau == "hunter") {
							val = view(dec, script.save_hunter, 0);
							kill_pion(val, script.save_hunter, script.nbhunter);
							script.nbhunter--;
						}
						else if (tableau == "cruiser") {
							val = view(dec, script.save_cruiser, 0);
							kill_pion(val, script.save_cruiser, script.nbcruiser);
							script.nbcruiser--;
						}
						else if (tableau == "commando") {
							val = view(dec, script.save_commando, 0);
							kill_pion(val, script.save_commando, script.nbcommando);
							script.nbcommando--;
						}
						else if (tableau == "bomber") {
							val = view(dec, script.save_bomber, 0);
							kill_pion(val, script.save_bomber, script.nbbomber);
							script.nbbomber--;
						}
						else if (tableau == "fighter") {
							val = view(dec, script.save_fighter, 0);
							kill_pion(val, script.save_fighter, script.nbfighter);
							script.nbfighter--;
						}
						else if (tableau == "destroyer") {
							val = view(dec, script.save_destroyer, 0);
							kill_pion(val, script.save_destroyer, script.nbdestroyer);
							script.nbdestroyer--;
						}
						else if (tableau == "force")
							script.force--;
					}
					script.nbhbomb++;
					script.pions_hbomb(dec);
					GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).change("h_bomb", dec, script);
				}
			}
		}
		else if (depart == "change") {
			tab = piece.Split("-"[0]);
			for (var tableau : String in tab) {
				if (tableau == "soldier")
					script.ressoldier--;
				else if (tableau == "raider")
					script.resraider--;
				else if (tableau == "hunter")
					script.reshunter--;
				else if (tableau == "cruiser")
					script.rescruiser--;
				else if (tableau == "commando")
					script.rescommando--;
				else if (tableau == "bomber")
					script.resbomber--;
				else if (tableau == "fighter")
					script.resfighter--;
				else if (tableau == "destroyer")
					script.resdestroyer--;
				else if (tableau == "force")
					script.force--;
			}
			script.reshbomb++;
		}
	}
	else if (arriver.IndexOf("reserve") != -1) {
		if (depart == "reserve")
			script.reshbomb--;
		else {
			for (var dec : GameObject in decor) {
				if (dec.name == depart) {
					val = view(dec, script.save_hbomb, 0);
					kill_pion(val, script.save_hbomb, script.nbhbomb);
					script.nbhbomb--;
				}
			}
		}
		if (arriver.IndexOf("blue") != -1)
			kill_reserve(script);
		else if (arriver.IndexOf("red") != -1)
			kill_reserve(script);
		else if (arriver.IndexOf("yellow") != -1)
			kill_reserve(script);
		else if (arriver.IndexOf("green") != -1)
			kill_reserve(script);
	}
	else if (depart == "reserve") {
		script.reshbomb--;
		for (var dec : GameObject in decor) {
			if (dec.name == arriver) {
				kill_all_pion(dec);
				GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(true, dec, -1);
			}
		}
	}
	else {
		for (var dec : GameObject in decor) {
			if (dec.name == depart) {
				for (var mov : GameObject in decor) {
					if (mov.name == arriver) {
						val = view(dec, script.save_hbomb, 0);
						kill_pion(val, script.save_hbomb, script.nbhbomb);
						script.nbhbomb--;
						kill_all_pion(mov);
						GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(true, mov, -1);
					}
				}
			}
		}
	}
	wait_ordre = 1;
}

function exe_ordre2 (depart, piece, script : allInfo) {
	var count : int;
	count = -1;
	for (var dec : GameObject in decor) {
		if (dec.name == depart) {
			if (piece == "soldier") {
				while (++count < 3) {
					var val = view(dec, script.save_soldier, 0);
					kill_pion(val, script.save_soldier, script.nbsoldier);
					script.nbsoldier--;
				}
				script.nbcommando++;
				script.up_pion(dec);
			}
			else if (piece == "raider") {
				while (++count < 3) {
					val = view(dec, script.save_raider, 0);
					kill_pion(val, script.save_raider, script.nbraider);
					script.nbraider--;
				}
				script.nbbomber++;
				script.up_pion(dec);
			}
			else if (piece == "hunter") {
				while (++count < 3) {
					val = view(dec, script.save_hunter, 0);
					kill_pion(val, script.save_hunter, script.nbhunter);
					script.nbhunter--;
				}
				script.nbfighter++;
				script.up_pion(dec);
			}
			else if (piece == "cruiser") {
				while (++count < 3) {
					val = view(dec, script.save_cruiser, 0);
					kill_pion(val, script.save_cruiser, script.nbcruiser);
					script.nbcruiser--;
				}
				script.nbdestroyer++;
				script.up_pion(dec);
			}
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).change(piece, dec, script);
		}
	}
	wait_ordre = 1;
}

function exe_ordre1 (depart, piece, arriver, script : allInfo) {
	if (depart == "power" || depart == "change") {
		if (piece == "soldier" && script.force) {
			script.ressoldier += 1;
			script.force -= 2;
		}
		else if (piece == "raider" && script.force) {
			script.resraider += 1;
			script.force -= 3;
		}
		else if (piece == "cruiser" && script.force) {
			script.rescruiser += 1;
			script.force -= 10;
		}
		else if (piece == "hunter" && script.force) {
			script.reshunter += 1;
			script.force -= 5;
		}
		else if (piece == "commando" && script.ressoldier) {
			script.rescommando += 1;
			script.ressoldier -= 3;
		}
		else if (piece == "bomber" && script.resraider) {
			script.resbomber += 1;
			script.resraider -= 3;
		}
		else if (piece == "fighter" && script.reshunter) {
			script.resfighter += 1;
			script.reshunter -= 3;
		}
		else if (piece == "destroyer" && script.rescruiser) {
			script.resdestroyer += 1;
			script.rescruiser -= 3;
		}
	}
	else if (depart == "reserve") {
		if (piece == "soldier" && script.ressoldier) {
			script.ressoldier -= 1;
			script.nbsoldier += 1;
			script.up_pion(null);
		}
		else if (piece == "raider" && script.resraider) {
			script.resraider -= 1;
			script.nbraider += 1;
			script.up_pion(null);
		}
		else if (piece == "cruiser" && script.rescruiser) {
			script.rescruiser -= 1;
			script.nbcruiser += 1;
			script.up_pion(null);
		}
		else if (piece == "hunter" && script.reshunter) {
			script.reshunter -= 1;
			script.nbhunter += 1;
			script.up_pion(null);
		}
		else if (piece == "commando" && script.rescommando) {
			script.rescommando -= 1;
			script.nbcommando += 1;
			script.up_pion(null);
		}
		else if (piece == "bomber" && script.resbomber) {
			script.resbomber -= 1;
			script.nbbomber += 1;
			script.up_pion(null);
		}
		else if (piece == "fighter" && script.resfighter) {
			script.resfighter -= 1;
			script.nbfighter += 1;
			script.up_pion(null);
		}
		else if (piece == "destroyer" && script.resdestroyer) {
			script.resdestroyer -= 1;
			script.nbdestroyer += 1;
			script.up_pion(null);
		}
	}
	wait_ordre = 1;
}

function movement (piece :GameObject, movx : float, movy : float) {
	var posx : float = piece.transform.position.x;
	var posy : float = piece.transform.position.y;

	if (piece.transform.position.x >= movx && piece.transform.position.y >= movy) {
		while ((piece.transform.position.x > movx) || (piece.transform.position.y > movy)) {
			if (piece.transform.position.x > movx) {
				if ((posx - movx) < 0.01)
					piece.transform.position.x = movx;
				else
					piece.transform.position.x -= ((posx - movx) / 25);
			}
			if (piece.transform.position.y > movy) {
				if ((posy - movy) < 0.01)
					piece.transform.position.y = movy;
				else
					piece.transform.position.y -= ((posy - movy) / 25);
			}
			yield WaitForSeconds(0.01);
		}
	}
	else if (piece.transform.position.x <= movx && piece.transform.position.y >= movy) {
		while (piece.transform.position.x < movx || piece.transform.position.y > movy) {
			if (piece.transform.position.x < movx) {
				if ((movx - posx) < 0.01)
					piece.transform.position.x = movx;
				else
					piece.transform.position.x += ((movx - posx) / 25);
			}
			if (piece.transform.position.y > movy) {
				if ((posy - movy) < 0.01)
					piece.transform.position.y = movy;
				else
					piece.transform.position.y -= ((posy - movy) / 25);
			}
			yield WaitForSeconds(0.01);
		}
	}
	else if (piece.transform.position.y <= movy && piece.transform.position.x >= movx) {
		while (piece.transform.position.y < movy || piece.transform.position.x > movx) {
			if (piece.transform.position.x > movx) {
				if ((posx - movx) < 0.01)
					piece.transform.position.x = movx;
				else
					piece.transform.position.x -= ((posx - movx) / 25);
			}
			if (piece.transform.position.y < movy) {
				if ((movy - posy) < 0.01)
					piece.transform.position.y = movy;
				else
					piece.transform.position.y += ((movy - posy) / 25);
			}
			yield WaitForSeconds(0.01);
		}
	}
	else if (piece.transform.position.y <= movy && piece.transform.position.x <= movx) {
		while (piece.transform.position.y < movy || piece.transform.position.x < movx) {
			if (piece.transform.position.x < movx) {
				if ((movx - posx) < 0.01)
					piece.transform.position.x = movx;
				else
					piece.transform.position.x += ((movx - posx) / 25);
			}
			if (piece.transform.position.y < movy) {
				if ((movy - posy) < 0.01)
					piece.transform.position.y = movy;
				else
					piece.transform.position.y += ((movy - posy) / 25);
			}
			yield WaitForSeconds(0.01);
		}
	}
	piece.transform.position.y = movy;
	piece.transform.position.x = movx;
	wait_ordre = 1;
}

function exe_ordre (depart, arriver, piece, script : allInfo) {
	for (var dec : GameObject in decor) {
		if (dec.name == depart) {
			for (var mov : GameObject in decor) {
				if (mov.name == arriver) {
					if (piece == "soldier") {
						var val = view(dec, script.save_soldier, 0);
						if (val > -1)
							movement(script.save_soldier[val], mov.transform.position.x - 0.75, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "raider") {
						val = view(dec, script.save_raider, 0);
						if (val > -1)
							movement(script.save_raider[val], mov.transform.position.x + 0.75, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "cruiser") {
						val = view(dec, script.save_cruiser, 0);
						if (val > -1)
							movement(script.save_cruiser[val], mov.transform.position.x - 0.25, mov.transform.position.y + 0.25);
						else
							wait_ordre = 1;
					}
					else if (piece == "hunter") {
						val = view(dec, script.save_hunter, 0);
						if (val > -1)
							movement(script.save_hunter[val], mov.transform.position.x - 0.75, mov.transform.position.y - 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "commando") {
						val = view(dec, script.save_commando, 0);
						if (val > -1)
							movement(script.save_commando[val], mov.transform.position.x - 0.25, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "bomber") {
						val = view(dec, script.save_bomber, 0);
						if (val > -1)
							movement(script.save_bomber[val], mov.transform.position.x + 0.25, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "fighter") {
						val = view(dec, script.save_fighter, 0);
						if (val > -1)
							movement(script.save_fighter[val], mov.transform.position.x + 0.75, mov.transform.position.y - 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "destroyer") {
						val = view(dec, script.save_destroyer, 0);
						if (val > -1)
							movement(script.save_destroyer[val], mov.transform.position.x + 0.25, mov.transform.position.y + 0.25);
						else
							wait_ordre = 1;
					}
				}
			}
		}
	}
}

function kill_all_pion_next (script : allInfo, mov : GameObject) {
	var val : int;

	val = view(mov, script.save_soldier, 0);
	while (val != -1) {
		kill_pion(val, script.save_soldier, script.nbsoldier);
		script.nbsoldier--;
		val = view(mov, script.save_soldier, 0);
	}
	val = view(mov, script.save_raider, 0);
	while (val != -1) {
		kill_pion(val, script.save_raider, script.nbraider);
		script.nbraider--;
		val = view(mov, script.save_raider, 0);
	}
	val = view(mov, script.save_hunter, 0);
	while (val != -1) {
		kill_pion(val, script.save_hunter, script.nbhunter);
		script.nbhunter--;
		val = view(mov, script.save_hunter, 0);
	}
	val = view(mov, script.save_cruiser, 0);
	while (val != -1) {
		kill_pion(val, script.save_cruiser, script.nbcruiser);
		script.nbcruiser--;
		val = view(mov, script.save_cruiser, 0);
	}
	val = view(mov, script.save_commando, 0);
	while (val != -1) {
		kill_pion(val, script.save_commando, script.nbcommando);
		script.nbcommando--;
		val = view(mov, script.save_commando, 0);
	}
	val = view(mov, script.save_bomber, 0);
	while (val != -1) {
		kill_pion(val, script.save_bomber, script.nbbomber);
		script.nbbomber--;
		val = view(mov, script.save_bomber, 0);
	}
	val = view(mov, script.save_fighter, 0);
	while (val != -1) {
		kill_pion(val, script.save_fighter, script.nbfighter);
		script.nbfighter--;
		val = view(mov, script.save_fighter, 0);
	}
	val = view(mov, script.save_destroyer, 0);
	while (val != -1) {
		kill_pion(val, script.save_destroyer, script.nbdestroyer);
		script.nbdestroyer--;
		val = view(mov, script.save_destroyer, 0);
	}
	val = view(mov, script.save_hbomb, 0);
	while (val != -1) {
		kill_pion(val, script.save_hbomb, script.nbhbomb);
		script.nbhbomb--;
		val = view(mov, script.save_hbomb, 0);
	}
}

function kill_all_pion (mov : GameObject) {
	kill_all_pion_next(scriptinfo, mov);
	kill_all_pion_next(scriptinfoblue, mov);
	kill_all_pion_next(scriptinfored, mov);
	kill_all_pion_next(scriptinfoyellow, mov);
}

@RPC
function response(all_pieces : float[], total_pieces : int)
{
	ressoldierall = all_pieces[0];
	resraiderall = all_pieces[1];
	rescruiserall = all_pieces[2];
	reshunterall = all_pieces[3];
	rescommandoall = all_pieces[4];
	resbomberall = all_pieces[5];
	resfighterall = all_pieces[6];
	resdestroyerall = all_pieces[7];
	resforceall = all_pieces[8];
	reshbomball = all_pieces[9];
	color_nb = all_pieces[10];

	soldier = all_pieces[11];
	raider = all_pieces[12];
	cruiser = all_pieces[13];
	hunter = all_pieces[14];
	commando = all_pieces[15];
	bomber = all_pieces[16];
	fighter = all_pieces[17];
	destroyer = all_pieces[18];
	h_bomb = all_pieces[19];
}

function playTurn_view1(place : GameObject, player : playerTurn, script : allInfo, color : String) {
	var info_case_res : Array = [];
	
	if (script.enabled) {
		info_case_res.push(script.ressoldier);
		info_case_res.push(script.resraider);
		info_case_res.push(script.rescruiser);
		info_case_res.push(script.reshunter);
		info_case_res.push(script.rescommando);
		info_case_res.push(script.resbomber);
		info_case_res.push(script.resfighter);
		info_case_res.push(script.resdestroyer);
		info_case_res.push(script.force);
		info_case_res.push(script.reshbomb);
		if (color == "blue")
			info_case_res.push(2);
		else if (color == "red")
			info_case_res.push(3);
		else if (color == "yellow")
			info_case_res.push(4);
		else
			info_case_res.push(1);
		info_case_res.push(view(place, script.save_soldier, 1));
		info_case_res.push(view(place, script.save_raider, 1));
		info_case_res.push(view(place, script.save_cruiser, 1));
		info_case_res.push(view(place, script.save_hunter, 1));
		info_case_res.push(view(place, script.save_commando, 1));
		info_case_res.push(view(place, script.save_bomber, 1));
		info_case_res.push(view(place, script.save_fighter, 1));
		info_case_res.push(view(place, script.save_destroyer, 1));
		info_case_res.push(view(place, script.save_hbomb, 1));
	}
	else {
		info_case_res.push(script.ressoldier);
		info_case_res.push(script.resraider);
		info_case_res.push(script.rescruiser);
		info_case_res.push(script.reshunter);
		info_case_res.push(script.rescommando);
		info_case_res.push(script.resbomber);
		info_case_res.push(script.resfighter);
		info_case_res.push(script.resdestroyer);
		info_case_res.push(script.force);
		info_case_res.push(script.reshbomb);
		if (color == "blue")
			info_case_res.push(2);
		else if (color == "red")
			info_case_res.push(3);
		else if (color == "yellow")
			info_case_res.push(4);
		info_case_res.push(view2(place, script.coordsoldier, 1));
		info_case_res.push(view2(place, script.coordraider, 1));
		info_case_res.push(view2(place, script.coordcruiser, 1));
		info_case_res.push(view2(place, script.coordhunter, 1));
		info_case_res.push(view2(place, script.coordcommando, 1));
		info_case_res.push(view2(place, script.coordbomber, 1));
		info_case_res.push(view2(place, script.coordfighter, 1));
		info_case_res.push(view2(place, script.coorddestroyer, 1));
		info_case_res.push(view2(place, script.coordhbomb, 1));
	}
	return (info_case_res);
}

@RPC
function ServerLookup (info : String) {
	var arr : Array = info.Split("*"[0]);
	var script : allInfo;
	var place : GameObject;

	if (arr[1] == "blue")
		script = scriptinfoblue;
	else if (arr[1] == "red")
		script = scriptinfored;
	else if (arr[1] == "yellow")
		script = scriptinfoyellow;
	else if (arr[1] == "green")
		script = scriptinfo;

	for (var dec : GameObject in decor) {
		if (dec.name == arr[0])
			place = dec;
	}
	
	var info_case_res : float[];

	info_case_res = playTurn_view1(place, playblue, script, arr[1]);
	var total_force_case : int = info_case_res[11] * 2 + info_case_res[12] * 3 + info_case_res[13] * 10 + info_case_res[14] * 5 + info_case_res[15] * 20 + info_case_res[16] * 30 + info_case_res[17] * 25 + info_case_res[18] * 50;
	if ((total_force_case != 0) && Network.isServer)
		networkView.RPC("response", RPCMode.Server, info_case_res, 0);
}

function StartBroadcast (dec : GameObject, color : String) {
	networkView.RPC("ServerLookup", RPCMode.Server, dec.name + "*" + color);
}

function client (dec : GameObject, color : String) {
	if (!Network.isServer && !networkView.isMine)
		StartBroadcast(dec, color);
}

function Server_info_next (info_case : float[], number : int) {
	var count : int = -1;
	var info_case_save : Array = [];

	while (++count < info_case[number])
		info_case_save.push(info_case[count + number + 1]);
	info_case_save.push(null);
	return (info_case_save);
}

@RPC
function Server_info (info_case : float[], color : String, exe_val : int) {
	var count : int = 11;
	var number1 : int = 0;
	var number2 : int = 0;
	var number3 : int = 0;
	var number4 : int = 0;
	var number5 : int = 0;
	var number6 : int = 0;
	var number7 : int = 0;
	var number8 : int = 0;

	while (info_case[count])
		count++;
	number1 = ++count;
	while (info_case[count])
		count++;
	number2 = ++count;
	while (info_case[count])
		count++;
	number3 = ++count;
	while (info_case[count])
		count++;
	number4 = ++count;
	while (info_case[count])
		count++;
	number5 = ++count;
	while (info_case[count])
		count++;
	number6 = ++count;
	while (info_case[count])
		count++;
	number7 = ++count;
	while (info_case[count])
		count++;
	number8 = ++count;
	if (color == "blue") {
		scriptinfoblue.ressoldier = info_case[0];
		scriptinfoblue.resraider = info_case[1];
		scriptinfoblue.reshunter = info_case[2];
		scriptinfoblue.rescruiser = info_case[3];
		scriptinfoblue.rescommando = info_case[4];
		scriptinfoblue.resbomber = info_case[5];
		scriptinfoblue.resfighter = info_case[6];
		scriptinfoblue.resdestroyer = info_case[7];
		scriptinfoblue.reshbomb = info_case[8];
		scriptinfoblue.force = info_case[9];
		scriptinfoblue.coordsoldier = Server_info_next(info_case, 11);
		scriptinfoblue.coordraider = Server_info_next(info_case, number1);
		scriptinfoblue.coordhunter = Server_info_next(info_case, number2);
		scriptinfoblue.coordcruiser = Server_info_next(info_case, number3);
		scriptinfoblue.coordcommando = Server_info_next(info_case, number4);
		scriptinfoblue.coordbomber = Server_info_next(info_case, number5);
		scriptinfoblue.coordfighter = Server_info_next(info_case, number6);
		scriptinfoblue.coorddestroyer = Server_info_next(info_case, number7);
		scriptinfoblue.coordhbomb = Server_info_next(info_case, number8);
		exe_blue = exe_val;
	}
	else if (color == "red") {
		scriptinfored.ressoldier = info_case[0];
		scriptinfored.resraider = info_case[1];
		scriptinfored.reshunter = info_case[2];
		scriptinfored.rescruiser = info_case[3];
		scriptinfored.rescommando = info_case[4];
		scriptinfored.resbomber = info_case[5];
		scriptinfored.resfighter = info_case[6];
		scriptinfored.resdestroyer = info_case[7];
		scriptinfored.reshbomb = info_case[8];
		scriptinfored.force = info_case[9];
		scriptinfored.coordsoldier = Server_info_next(info_case, 11);
		scriptinfored.coordraider = Server_info_next(info_case, number1);
		scriptinfored.coordhunter = Server_info_next(info_case, number2);
		scriptinfored.coordcruiser = Server_info_next(info_case, number3);
		scriptinfored.coordcommando = Server_info_next(info_case, number4);
		scriptinfored.coordbomber = Server_info_next(info_case, number5);
		scriptinfored.coordfighter = Server_info_next(info_case, number6);
		scriptinfored.coorddestroyer = Server_info_next(info_case, number7);
		scriptinfored.coordhbomb = Server_info_next(info_case, number8);
		exe_red = exe_val;
	}
	else if (color == "yellow") {
		scriptinfoyellow.ressoldier = info_case[0];
		scriptinfoyellow.resraider = info_case[1];
		scriptinfoyellow.reshunter = info_case[2];
		scriptinfoyellow.rescruiser = info_case[3];
		scriptinfoyellow.rescommando = info_case[4];
		scriptinfoyellow.resbomber = info_case[5];
		scriptinfoyellow.resfighter = info_case[6];
		scriptinfoyellow.resdestroyer = info_case[7];
		scriptinfoyellow.reshbomb = info_case[8];
		scriptinfoyellow.force = info_case[9];
		scriptinfoyellow.coordsoldier = Server_info_next(info_case, 11);
		scriptinfoyellow.coordraider = Server_info_next(info_case, number1);
		scriptinfoyellow.coordhunter = Server_info_next(info_case, number2);
		scriptinfoyellow.coordcruiser = Server_info_next(info_case, number3);
		scriptinfoyellow.coordcommando = Server_info_next(info_case, number4);
		scriptinfoyellow.coordbomber = Server_info_next(info_case, number5);
		scriptinfoyellow.coordfighter = Server_info_next(info_case, number6);
		scriptinfoyellow.coorddestroyer = Server_info_next(info_case, number7);
		scriptinfoyellow.coordhbomb = Server_info_next(info_case, number8);
		exe_yellow = exe_val;
	}
}

function attribute_save (save : GameObject[], number : int, info_case : Array) {
	var count : int = -1;

	info_case.push(null);
	info_case.push(number * 2);
	while (++count < number) {
		info_case.push(save[count].transform.position.x);
		info_case.push(save[count].transform.position.y);
	}
	return (info_case);
}

function client_info_bis (script : allInfo) {
	var info_case : Array = [];

	info_case.push(script.ressoldier);
	info_case.push(script.resraider);
	info_case.push(script.reshunter);
	info_case.push(script.rescruiser);
	info_case.push(script.rescommando);
	info_case.push(script.resbomber);
	info_case.push(script.resfighter);
	info_case.push(script.resdestroyer);
	info_case.push(script.reshbomb);
	info_case.push(script.force);
	info_case = attribute_save(script.save_soldier, script.nbsoldier, info_case);
	info_case = attribute_save(script.save_raider, script.nbraider, info_case);
	info_case = attribute_save(script.save_hunter, script.nbhunter, info_case);
	info_case = attribute_save(script.save_cruiser, script.nbcruiser, info_case);
	info_case = attribute_save(script.save_commando, script.nbcommando, info_case);
	info_case = attribute_save(script.save_bomber, script.nbbomber, info_case);
	info_case = attribute_save(script.save_fighter, script.nbfighter, info_case);
	info_case = attribute_save(script.save_destroyer, script.nbdestroyer, info_case);
	info_case = attribute_save(script.save_hbomb, script.nbhbomb, info_case);
	return (info_case);
}

@RPC
function client_info (script : allInfo, color : String, exe_val : int) {
	if (!Network.isServer && !networkView.isMine) {
		var info_case : float[];

		info_case = client_info_bis(script);
		networkView.RPC("Server_info", RPCMode.Server, info_case, color, exe_val);
	}
}

var wait_for_order_blue : int = 0;
var wait_for_order_red : int = 0;
var wait_for_order_yellow : int = 0;

@RPC
function reponse_order (color : String, wait_val : int) {
	if (color == "blue")
		wait_for_order_blue = wait_val;
	if (color == "red")
		wait_for_order_red = wait_val;
	if (color == "yellow")
		wait_for_order_yellow = wait_val;
}

@RPC
function Server_ordre (color : String, wait_one : int, val_ok : int) {
	if (val_ok)
		wait_exe = wait_one;
	if (color == "blue")
		networkView.RPC("reponse_order", RPCMode.Server, color, wait_for_order_blue);
	else if (color == "red")
		networkView.RPC("reponse_order", RPCMode.Server, color, wait_for_order_red);
	else if (color == "yellow")
		networkView.RPC("reponse_order", RPCMode.Server, color, wait_for_order_yellow);
}

@RPC
function client_exe_ordre (color : String, wait_one : int, val_ok : int) {
	if (!Network.isServer && !networkView.isMine)
		networkView.RPC("Server_ordre", RPCMode.Server, color, wait_one, val_ok);
}

function timer() {
	wait_time++;
	yield WaitForSeconds(1);
	time++;
}

function Update () {
	if (wait_time == time)
		timer();
	if ((!scriptinfo.isalive || scriptinfo.isalive == 2) || (!scriptinfoblue.isalive && !scriptinfored.isalive && !scriptinfoyellow.isalive)
		|| (time > 3600 /*&& ordre...*/) || time > 4200)
		end_game();
}
