private var start : int = 0;
private var script_allChoose : allChoose;
private var scriptinfogreen : allInfo;
private var scriptinfoblue : allInfo;
private var scriptinfored : allInfo;
private var scriptinfoyellow : allInfo;

private var information : int = 0;
private var reserve : int = 0; 
private var on : int = 0;
private var nb : int = 0;
var ordre : int = 1;
var nbcount : int = 1;
var exe : int = 0;
var case_name;
private var time : int = 1;
private var wait_time : int = 1;

private var decor : GameObject[];
private var move : GameObject[];

private var soldier : int = 0;
private var raider : int = 0;
private var hunter : int = 0;
private var cruiser : int = 0;
private var commando : int = 0;
private var bomber : int = 0;
private var fighter : int = 0;
private var destroyer : int = 0;
private var h_bomb : int = 0;

private var ressoldier : int = 0;
private var resraider : int = 0;
private var reshunter : int = 0;
private var rescruiser : int = 0;
private var rescommando : int = 0;
private var resbomber : int = 0;
private var resfighter : int = 0;
private var resdestroyer : int = 0;
private var resh_bomb : int = 0;
private var resforce : int = 0;

private var soldierh : int = 0;
private var raiderh : int = 0;
private var hunterh : int = 0;
private var cruiserh : int = 0;
private var commandoh : int = 0;
private var bomberh : int = 0;
private var fighterh : int = 0;
private var destroyerh : int = 0;
private var forceh : int = 0;
private var hbomb_piece : String = null;

private var ressoldier_use : int = 0;
private var resraider_use : int = 0;
private var rescruiser_use : int = 0;
private var reshunter_use : int = 0;
private var rescommando_use : int = 0;
private var resbomber_use : int = 0;
private var resfighter_use : int = 0;
private var resdestroyer_use : int = 0;
private var resh_bomb_use : int = 0;
private var use_force : int = 0;

private var reshbomb_next : int = 0;
private var ressoldier_next : int = 0;
private var resraider_next : int = 0;
private var rescruiser_next : int = 0;
private var reshunter_next : int = 0;
private var rescommando_next : int = 0;
private var resbomber_next : int = 0;
private var resfighter_next : int = 0;
private var resdestroyer_next : int = 0;

var soldier_use : Array = [null];
var raider_use : Array = [null];
var cruiser_use : Array = [null];
var hunter_use : Array = [null];
var commando_use : Array = [null];
var bomber_use : Array = [null];
var fighter_use : Array = [null];
var destroyer_use : Array = [null];
var h_bomb_use : Array = [null];

/* **************************************** FUNCTION D'INITIALISATION **************************************** */

function Stop () {
	if (!networkView.isMine)
		this.enabled = false;
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

function Start () {
	if (Application.loadedLevelName == "Battleground") {
		start++;
		script_allChoose = GameObject.Find("0 - Decor").GetComponent(allChoose);

		decor = GameObject.FindGameObjectsWithTag("Decor");
		move = GameObject.FindGameObjectsWithTag("Move");

		var bleu : GameObject;
		var rouge : GameObject;
		var jaune : GameObject;
		var vert : GameObject;

		bleu = GameObject.Find(propre("blue"));
		rouge = GameObject.Find(propre("red"));
		jaune = GameObject.Find(propre("yellow"));
		vert = GameObject.Find(propre("green"));
		scriptinfogreen = vert.GetComponent(allInfo);
		scriptinfoblue = bleu.GetComponent(allInfo);
		scriptinfored = rouge.GetComponent(allInfo);
		scriptinfoyellow = jaune.GetComponent(allInfo);
		scriptinfogreen.Stop();
		scriptinfoblue.Stop();
		scriptinfored.Stop();
		scriptinfoyellow.Stop();
		if (Network.isServer) {
			if (propre("blue").IndexOf("PLAY") != -1)
				bleu.GetComponent(infoButtons).Stop();
			if (propre("yellow").IndexOf("PLAY") != -1)
				jaune.GetComponent(infoButtons).Stop();
			if (propre("red").IndexOf("PLAY") != -1)
				rouge.GetComponent(infoButtons).Stop();
		}
		else if (Network.isClient && name.IndexOf("blue") != -1) {
			if (propre("green").IndexOf("PLAY") != -1)
				vert.GetComponent(infoButtons).Stop();
			if (propre("yellow").IndexOf("PLAY") != -1)
				jaune.GetComponent(infoButtons).Stop();
			if (propre("red").IndexOf("PLAY") != -1)
				rouge.GetComponent(infoButtons).Stop();
		}
		else if (Network.isClient && name.IndexOf("red") != -1) {
			if (propre("green").IndexOf("PLAY") != -1)
				vert.GetComponent(infoButtons).Stop();
			if (propre("yellow").IndexOf("PLAY") != -1)
				jaune.GetComponent(infoButtons).Stop();
			if (propre("blue").IndexOf("PLAY") != -1)
				bleu.GetComponent(infoButtons).Stop();
		}
		else if (Network.isClient && name.IndexOf("yellow") != -1) {
			if (propre("green").IndexOf("PLAY") != -1)
				vert.GetComponent(infoButtons).Stop();
			if (propre("blue").IndexOf("PLAY") != -1)
				bleu.GetComponent(infoButtons).Stop();
			if (propre("red").IndexOf("PLAY") != -1)
				rouge.GetComponent(infoButtons).Stop();
		}
		reserve_button();
	}
}

/* **************************************** FUNCTION DE VERIF_ORDRE + FEUILLE_ORDRE **************************************** */

function feuille_ordre (depart, arriver, piece) {
	PlayerPrefs.SetString("Orde" + ordre + "depart", depart);
	PlayerPrefs.SetString("Orde" + ordre + "arriver", arriver);
	PlayerPrefs.SetString("Orde" + ordre + "piece", piece);
	ordre++;
}

function attribut_move(dec : GameObject, save : GameObject[], use : Array) {
	var val = view(dec, save, 0, use);
	if (val != -1)
		attribution_val(val, use, 1);
}

function attribut_changedec(count : int, piece : String, case_name : String, dec : GameObject, save : GameObject[], use : Array) {
	while (++count < (3 - pion_next(piece, case_name))) {
		var val = view(dec, save, 0, use);
		if (val != -1)
			attribution_val(val, use, 1);
	}
}

function verif_ordre (depart : String, arriver : String, piece : String, script : allInfo) {
	var count : int;

	if (depart != "reserve" && depart != "power" && depart != "change" && depart != "changedec") {
		for (var dec : GameObject in GameObject.FindGameObjectsWithTag("Decor")) {
			if (dec.name == depart) {
				if (piece == "soldier")
					attribut_move(dec, script.save_soldier, soldier_use);
				else if (piece == "raider")
					attribut_move(dec, script.save_raider, raider_use);
				else if (piece == "cruiser")
					attribut_move(dec, script.save_cruiser, cruiser_use);
				else if (piece == "hunter")
					attribut_move(dec, script.save_hunter, hunter_use);
				else if (piece == "commando") 
					attribut_move(dec, script.save_commando, commando_use);
				else if (piece == "bomber") 
					attribut_move(dec, script.save_bomber, bomber_use);
				else if (piece == "fighter")
					attribut_move(dec, script.save_fighter, fighter_use);
				else if (piece == "destroyer")
					attribut_move(dec, script.save_destroyer, destroyer_use);
				else if (piece == "h_bomb")
					attribut_move(dec, script.save_hbomb, h_bomb_use);
			}
		}
	}
	else if (depart == "changedec") {
		count = -1;
		ordre--;
		var case_name = arriver;
		for (var dec : GameObject in GameObject.FindGameObjectsWithTag("Decor")) {
			if (dec.name == arriver) {
				if (piece == "soldier")
					attribut_changedec(count, piece, case_name, dec, script.save_soldier, soldier_use);
				else if (piece == "raider") 
					attribut_changedec(count, piece, case_name, dec, script.save_raider, raider_use);
				else if (piece == "hunter") 
					attribut_changedec(count, piece, case_name, dec, script.save_hunter, hunter_use);
				else if (piece == "cruiser")
					attribut_changedec(count, piece, case_name, dec, script.save_cruiser, cruiser_use);
				else if (piece.IndexOf("h_bomb") != -1) {
					var tab : Array = piece.Split("-"[0]);
					var number1 = pion_next("soldier", case_name);
					var number2 = pion_next("raider", case_name);
					var number3 = pion_next("hunter", case_name);
					var number4 = pion_next("cruiser", case_name);
					var number5 = pion_next("commando", case_name);
					var number6 = pion_next("bomber", case_name);
					var number7 = pion_next("fighter", case_name);
					var number8 = pion_next("destroyer", case_name);
					for (var tableau : String in tab) {
						if (tableau == "soldier") {
							if (!number1)
								attribut_move(dec, script.save_soldier, soldier_use);
							else
								number1--;
						}
						else if (tableau == "raider") {
							if (!number2)
								attribut_move(dec, script.save_raider, raider_use);
							else
								number2--;
						}
						else if (tableau == "hunter") {
							if (!number3)
								attribut_move(dec, script.save_hunter, hunter_use);
							else
								number3--;
						}
						else if (tableau == "cruiser") {
							if (!number4)
								attribut_move(dec, script.save_cruiser, cruiser_use);
							else
								number4--;
						}
						else if (tableau == "commando") {
							if (!number5)
								attribut_move(dec, script.save_commando, commando_use);
							else
								number5--;
						}
						else if (tableau == "bomber") {
							if (!number6)
								attribut_move(dec, script.save_bomber, bomber_use);
							else
								number6--;
						}
						else if (tableau == "fighter") {
							if (!number7)
								attribut_move(dec, script.save_fighter, fighter_use);
							else
								number7--;
						}
						else if (tableau == "destroyer") {
							if (!number8)
								attribut_move(dec, script.save_destroyer, destroyer_use);
							else
								number8--;
						}
						else if (tableau == "force")
							use_force++;
					}
				}
			}
		}
		ordre++;
	}
	else if (depart == "reserve" && piece == "h_bomb") {
		resh_bomb_use++;
		reserve_button();
	}
}

/* **************************************** FUNCTION DE REDUCTION DE RESERVE **************************************** */

function reduc_pow_use (piece) {
	if (piece == "soldier") {
		ressoldier_next--;
		use_force -= 2;
	}
	else if (piece == "raider") {
		resraider_next--;
		use_force -= 3;
	}
	else if (piece == "cruiser") {
		rescruiser_next--;
		use_force -= 10;
	}
	else if (piece == "hunter") {
		reshunter_next--;
		use_force -= 5;
	}
}

function reduc_res_use (piece : String, depart : String) {
	var i : int = 1;

	if (depart == "change") {
		i = 3;
		if (piece == "commando") {
			piece = "soldier";
			rescommando_next--;
		}
		else if (piece == "bomber") {
			piece = "raider";
			resbomber_next--;
		}
		else if (piece == "fighter") {
			piece = "hunter";
			resfighter_next--;
		}
		else if (piece == "destroyer") {
			piece = "cruiser";
			resdestroyer_next--;
		}
	}
	if (piece == "soldier")
		ressoldier_use -= 1 * i;
	else if (piece == "raider")
		resraider_use -= 1 * i;
	else if (piece == "cruiser")
		rescruiser_use -= 1 * i;
	else if (piece == "hunter")
		reshunter_use -= 1 * i;
	else if (piece == "commando")
		rescommando_use -= 1 * i;
	else if (piece == "bomber")
		resbomber_use -= 1 * i;
	else if (piece == "fighter")
		resfighter_use -= 1 * i;
	else if (piece == "destroyer")
		resdestroyer_use -= 1 * i;

	if (depart == "change") {
		if (piece.IndexOf("h_bomb") != -1) {
			reshbomb_next--;
			var tab : Array = piece.Split("-"[0]);
			for (var tableau : String in tab) {
				if (tableau == "soldier")
					ressoldier_use--;
				else if (tableau == "raider")
					resraider_use--;
				else if (tableau == "hunter")
					reshunter_use--;
				else if (tableau == "cruiser")
					rescruiser_use--;
				else if (tableau == "commando")
					rescommando_use--;
				else if (tableau == "bomber")
					resbomber_use--;
				else if (tableau == "fighter")
					resfighter_use--;
				else if (tableau == "destroyer")
					resdestroyer_use--;
				else if (tableau == "force")
					use_force--;
			}
		}
	}
}

/* **************************************** FUNCTION D'ATTRIBUTION DE VALEUR + VIEW AVEC USE **************************************** */

function attribution_val (val : int, use : Array, i : int) {
	if (i == 1) {
		var j : int;
		j = 0;
		var verif : int;
		verif = 0;
		while (!verif) {
			if (use[j] == null) {
				use[j] = val;
				use.push(null);
				verif = 1;
			}
			else if (use[j] == -1) {
				use[j] = val;
				verif = 1;
			}
			j++;
		}
	}
	else {
		for (var use_bis in use) {
			if (use_bis != null)
				use_bis = -1;
		}
	}
}

function verif_use (count : int, use : Array) {
	for (var use_bis in use) {
		if (use_bis == count)
			return (0);
	}
	return (1);
}

function view1 (dec : GameObject, save : GameObject[], i : int) {
	var ht = dec.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = dec.GetComponent(SpriteRenderer).sprite.rect.width;
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

function view (dec : GameObject, save : GameObject[], i : int, use : Array) {
	var ht = dec.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = dec.GetComponent(SpriteRenderer).sprite.rect.width;
	var height = (ht * dec.transform.lossyScale.y) / 200;
	var width = (wh * dec.transform.lossyScale.x) / 200;
	var count : int;
	var val : int;
	var verif : int;
    var nbpion : int;

	verif = 0;
	count = -1;
	val = 0;
	nbpion = 0;
	while (save[++count]) {
		if (save[count].transform.position.x < dec.transform.position.x + width
			&& save[count].transform.position.x > dec.transform.position.x - width
			&& save[count].transform.position.y < dec.transform.position.y + height
			&& save[count].transform.position.y > dec.transform.position.y - height
			&& verif_use(count, use)) {
			if (i == 1)
				val = 1;
			else if (!i) {
				val = count;
				verif = 1;
			}
			else
				nbpion++;
		}
	}
	if (i == 2)
		return (nbpion);
	if (i || verif)
		return (val);
	else
		return (-1);
}

function all_view (dec : GameObject, script : allInfo) {
	var allforce : int = 0;
	var val : int;

	val = view(dec, script.save_soldier, 2, soldier_use);
	allforce += (val * 2);
	val = view(dec, script.save_raider, 2, raider_use);
	allforce += (val * 3);
	val = view(dec, script.save_cruiser, 2, cruiser_use);
	allforce += (val * 10);
	val = view(dec, script.save_hunter, 2, hunter_use);
	allforce += (val * 5);
	val = view(dec, script.save_commando, 2, commando_use);
	allforce += (val * 20);
	val = view(dec, script.save_bomber, 2, bomber_use);
	allforce += (val * 30);
	val = view(dec, script.save_fighter, 2, fighter_use);
	allforce += (val * 25);
	val = view(dec, script.save_destroyer, 2, destroyer_use);
	allforce += (val * 50);
	return (allforce);
}

/* **************************************** FUNCTION DE PION_NEXT **************************************** */

function pion_next (piece : String, case_name : String) {
	var nbordre : int;
	var count : int;

	nbordre = 0;
	count = 0;
	while (++nbordre < ordre) {
		var recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
		var recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
		var recup3 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
		if (recup1 != "changedec" && piece != "h_bomb") {
			if (piece == "soldier" && recup3 == "soldier" && recup2 == case_name)
				count++;
			else if (piece == "raider" && recup3 == "raider" && recup2 == case_name)
				count++;
			else if (piece == "hunter" && recup3 == "hunter" && recup2 == case_name)
				count++;
			else if (piece == "cruiser" && recup3 == "cruiser" && recup2 == case_name)
				count++;
			else if (piece == "commando" && recup3 == "commando" && recup2 == case_name)
				count++;
			else if (piece == "bomber" && recup3 == "bomber" && recup2 == case_name)
				count++;
			else if (piece == "fighter" && recup3 == "fighter" && recup2 == case_name)
				count++;
			else if (piece == "destroyer" && recup3 == "destroyer" && recup2 == case_name)
				count++;
		}
		else if (recup1 == "changedec" && nbordre < 5 && recup3.IndexOf("h_bomb") == -1) {
			if (((nbordre == 2 && count == 1) || (nbordre == 3 && count == 1) || (nbordre == 4 && count == 1)) && piece == recup3)
				count--;
			else if (((nbordre == 3 && count == 2) || (nbordre == 4 && count == 2)) && piece == recup3)
				count -= 2;
			else if ((nbordre == 4 && count == 3) && piece == recup3)
				count -= 3;
			else if (piece == "commando" && recup3 == "soldier" && recup2 == case_name)
				count++;
			else if (piece == "bomber" && recup3 == "raider" && recup2 == case_name)
				count++;
			else if (piece == "fighter" && recup3 == "hunter" && recup2 == case_name)
				count++;
			else if (piece == "destroyer" && recup3 == "cruiser" && recup2 == case_name)
				count++;
		}
		else if (recup1 == "changedec" && recup3.IndexOf("h_bomb") != -1 && recup2 == case_name) {
			if (piece == "h_bomb")
				count++;
			var tab : Array = recup3.Split("-"[0]);
			for (var tableau : String in tab) {
				if (tableau == "soldier" && count && piece == "soldier")
					count--;
				else if (tableau == "raider" && count && piece == "raider")
					count--;
				else if (tableau == "hunter" && count && piece == "hunter")
					count--;
				else if (tableau == "cruiser" && count && piece == "cruiser")
					count--;
				else if (tableau == "commando" && count && piece == "commando")
					count--;
				else if (tableau == "bomber" && count && piece == "bomber")
					count--;
				else if (tableau == "fighter" && count && piece == "fighter")
					count--;
				else if (tableau == "destroyer" && count && piece == "destroyer")
					count--;
			}
		}
		else if (piece == "h_bomb" && recup3 == "h_bomb" && nbordre > 1 && nbordre < 5 && case_name == recup2)
			count--;
	}
	return (count);
}

/* **************************************** FUNCTION POUR LA HBOMB **************************************** */

function force_reserve (script : allInfo) {
	var allforce : int = 0;

	allforce += ((script.ressoldier - ressoldier_use) * 2);
	allforce += ((script.resraider - resraider_use) * 3);
	allforce += ((script.reshunter - reshunter_use) * 5);
	allforce += ((script.rescruiser - rescruiser_use) * 10);
	allforce += ((script.rescommando - rescommando_use) * 20);
	allforce += ((script.resbomber - resbomber_use) * 30);
	allforce += ((script.resfighter - resfighter_use) * 25);
	allforce += ((script.resdestroyer - resdestroyer_use) * 50);
	allforce += ((script.force - use_force));
	return (allforce);
}

function force_hbomb (val : int, recup : String, script : allInfo) {
	var count : int = 0;

	if (!val) {
		for (var dec : GameObject in script_allChoose.decor) {
			if (dec.name == recup)
				count = all_view(dec, script);
		}
		count += (pion_next("soldier", case_name) * 2);
		count += (pion_next("raider", case_name) * 3);
		count += (pion_next("cruiser", case_name) * 10);
		count += (pion_next("hunter", case_name) * 5);
		count += (pion_next("commando", case_name) * 20);
		count += (pion_next("bomber", case_name) * 30);
		count += (pion_next("fighter", case_name) * 25);
		count += (pion_next("destroyer", case_name) * 50);
		count += script.force - use_force;
	}
	else {
		count = force_reserve(script);
		count += (ressoldier_next * 2);
		count += (resraider_next * 3);
		count += (reshunter_next * 5);
		count += (rescruiser_next * 10);
		count += (rescommando_next * 20);
		count += (resbomber_next * 30);
		count += (resfighter_next * 25);
		count += (resdestroyer_next * 50);
	}
	return (count);
}

function av_hbomb () {
	var val : int = 0;

	var tab : Array = hbomb_piece.Split("-"[0]);
	for (var tableau : String in tab) {
		if (tableau == "soldier")
			val += 2;
		else if (tableau == "raider")
			val += 3;
		else if (tableau == "hunter")
			val += 5;
		else if (tableau == "cruiser")
			val += 10;
		else if (tableau == "commando")
			val += 20;
		else if (tableau == "bomber")
			val += 30;
		else if (tableau == "fighter")
			val += 25;
		else if (tableau == "destroyer")
			val += 50;
		else if (tableau == "force")
			val++;
	}
	return (val);
}

/* **************************************** FUNCTION DE RESERVE **************************************** */

function reserve_button_pay (force : int, force_limit : int, button_pion : String, ordre_piece : String, respion_next : int, use_forcepion : int)
{
	if (ordre < 6 && force > force_limit)
	{
		script_allChoose.name_button(button_pion).SetActive(true);
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button(button_pion)))
		{
			feuille_ordre("power", "reserve", ordre_piece);
			respion_next++;
			use_force += use_forcepion;
		}
	}
	else
		script_allChoose.name_button(button_pion).SetActive(false);
	return (respion_next);
}

function reserve_button_change (respion : int, respion_use : int, respion_next : int, button_pion : String, ordre_piece : String)
{
	if ((respion - respion_use) > (2 - respion_next) && ordre < 6)
	{
		script_allChoose.name_button(button_pion).SetActive(true);
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button(button_pion)))
		{
			feuille_ordre("change", "reserve", ordre_piece);
			respion_use += 3;
			if (ordre_piece == "commando")
				rescommando_next++;
			else if (ordre_piece == "bomber")
				resbomber_next++;
			else if (ordre_piece == "fighter")
				resfighter_next++;
			else if (ordre_piece == "destroyer")
				resdestroyer_next++;
		}
	}
	else
		script_allChoose.name_button(button_pion).SetActive(false);
	return (respion_use);
}

function reserve_button_move(pion_txt : String, respion : int, respion_use : int, respion_next : int, ordre_hq : String, ordre_piece : String)
{
	GameObject.Find("a - Boxes/Reserve_Box/" + pion_txt + "_Box/Reserve_" + pion_txt + "/Reserve_Text").GetComponent(TextMesh).text = (respion - respion_use + respion_next) + " ";
	if (ordre < 6)
	{
		if ((respion + respion_next) > respion_use && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_" + pion_txt)))
		{
			feuille_ordre("reserve", ordre_hq, ordre_piece);
			respion_use++;
		}
	}
	return (respion_use);
}

function reserve_button_moveHB(reshbomb : int)
{
	script_allChoose.name_button("Reserve_H-Bomb").renderer.enabled = true;
	GameObject.Find("a - Boxes/Reserve_Box/H-Bomb_Box/Reserve_H-Bomb/Reserve_Text").GetComponent(TextMesh).text = (reshbomb + reshbomb_next - resh_bomb_use) + " ";
	if (ordre < 6)
	{
		if (reshbomb + reshbomb_next > resh_bomb_use && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_H-Bomb")))
			deplacement(0, 10);
	}
}

function reserve_button_changehb (script : allInfo) {
		if (force_hbomb(1, null, script) >= 100 && ordre < 6) {
			script_allChoose.name_button("Pay_H-Bomb").SetActive(true);
			if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Pay_H-Bomb"))) {
				exe = 3;
				soldierh = script.ressoldier - ressoldier_use + ressoldier_next;
				raiderh = script.resraider - resraider_use + resraider_next;
				hunterh = script.reshunter - reshunter_use + reshunter_next;
				cruiserh = script.rescruiser - rescruiser_use + rescruiser_next;
				commandoh = script.rescommando - rescommando_use + rescommando_next;
				bomberh = script.resbomber - resbomber_use + resbomber_next;
				fighterh = script.resfighter - resfighter_use + resfighter_next;
				destroyerh = script.resdestroyer - resdestroyer_use + resdestroyer_next;
				forceh = script.force - use_force;
				hbomb_piece = "h_bomb";
			}
		}
		else
			script_allChoose.name_button("Pay_H-Bomb").SetActive(false);
}

function reserve_button_playable(filtre_player : String, scriptinfo_color : allInfo, hq_color_res : String)
{
	if (exe == 3) {
		script_allChoose.name_button("Pay_Soldier").SetActive(false);
		script_allChoose.name_button("Pay_Raider").SetActive(false);
		script_allChoose.name_button("Pay_Hunter").SetActive(false);
		script_allChoose.name_button("Pay_Cruiser").SetActive(false);
		script_allChoose.name_button("Pay_Commando").SetActive(false);
		script_allChoose.name_button("Pay_Bomber").SetActive(false);
		script_allChoose.name_button("Pay_Fighter").SetActive(false);
		script_allChoose.name_button("Pay_Destroyer").SetActive(false);
		script_allChoose.name_button("Pay_H-Bomb").SetActive(false);
		script_allChoose.name_button("Reserve_H-Bomb").renderer.enabled = false;
		GameObject.Find("a - Boxes/Reserve_Box/H-Bomb_Box/Reserve_H-Bomb/Reserve_Text").GetComponent(TextMesh).text = " ";
		GameObject.Find("a - Boxes/Reserve_Box/Reserve_Text/Reserve_Text").GetComponent(TextMesh).text = "H-Bomb : " + av_hbomb();
		GameObject.Find("a - Boxes/Reserve_Box/Soldier_Box/Reserve_Soldier/Reserve_Text").GetComponent(TextMesh).text = soldierh + " ";
		if (soldierh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Soldier"))) {
			soldierh--;
			hbomb_piece += "-soldier";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Raider_Box/Reserve_Raider/Reserve_Text").GetComponent(TextMesh).text = raiderh + " ";
		if (raiderh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Raider"))) {
			raiderh--;
			hbomb_piece += "-raider";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Cruiser_Box/Reserve_Cruiser/Reserve_Text").GetComponent(TextMesh).text = cruiserh + " ";
		if (cruiserh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Cruiser"))) {
			cruiserh--;
			hbomb_piece += "-cruiser";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Hunter_Box/Reserve_Hunter/Reserve_Text").GetComponent(TextMesh).text = hunterh + " ";
		if (hunterh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Hunter"))) {
			hunterh--;
			hbomb_piece += "-hunter";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Commando_Box/Reserve_Commando/Reserve_Text").GetComponent(TextMesh).text = commandoh + " ";
		if (commandoh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Commando"))) {
			commandoh--;
			hbomb_piece += "-commando";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Bomber_Box/Reserve_Bomber/Reserve_Text").GetComponent(TextMesh).text = bomberh + " ";
		if (bomberh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Bomber"))) {
			bomberh--;
			hbomb_piece += "-bomber";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Fighter_Box/Reserve_Fighter/Reserve_Text").GetComponent(TextMesh).text = fighterh + " ";
		if (fighterh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Fighter"))) {
			fighterh--;
			hbomb_piece += "-fighter";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Destroyer_Box/Reserve_Destroyer/Reserve_Text").GetComponent(TextMesh).text = destroyerh + " ";
		if (destroyerh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Destroyer"))) {
			destroyerh--;
			hbomb_piece += "-destroyer";
		}
		GameObject.Find("a - Boxes/Reserve_Box/Force_Box/Reserve_Force/Reserve_Text").GetComponent(TextMesh).text = forceh + " ";
		if (forceh && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Force"))) {
			forceh--;
			hbomb_piece += "-force";
		}
		script_allChoose.name_button("Backreserve").SetActive(true);
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Backreserve")))
			exe = 0;
		if (av_hbomb() >= 100) {
			script_allChoose.name_button("Okreserve").SetActive(true);
			if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Okreserve"))) {
				script_allChoose.name_button("Reserve_H-Bomb").renderer.enabled = true;
				script_allChoose.name_button("Okreserve").SetActive(false);
				script_allChoose.name_button("Backreserve").SetActive(false);
				var tab : Array = hbomb_piece.Split("-"[0]);
				for (var tableau : String in tab) {
					if (tableau == "soldier")
						ressoldier_use++;
					else if (tableau == "raider")
						resraider_use++;
					else if (tableau == "hunter")
						reshunter_use++;
					else if (tableau == "cruiser")
						rescruiser_use++;
					else if (tableau == "commando")
						rescommando_use++;
					else if (tableau == "bomber")
						resbomber_use++;
					else if (tableau == "fighter")
						resfighter_use++;
					else if (tableau == "destroyer")
						resdestroyer_use++;
					else if (tableau == "force")
						use_force++;
				}
				reshbomb_next++;
				feuille_ordre("change", "reserve", hbomb_piece);
				nb = 0;
				zoom(-9, 5, 0, 1, 1, 0, "Reserve_Box");
				exe = 0;
				reserve_button();
			}
		}
		else
			script_allChoose.name_button("Okreserve").SetActive(false);	}
	else {
		GameObject.Find("a - Boxes/Reserve_Box/Reserve_Text/Reserve_Text").GetComponent(TextMesh).text = "Reserve";
		script_allChoose.name_button("Backreserve").SetActive(false);
		script_allChoose.name_button("Okreserve").SetActive(false);
		GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_reserve(filtre_player);
		
		ressoldier_next = reserve_button_pay(scriptinfo_color.force - use_force, 1, "Pay_Soldier", "soldier", ressoldier_next, 2);
		resraider_next  = reserve_button_pay(scriptinfo_color.force - use_force, 2, "Pay_Raider",  "raider",  resraider_next,  3);
		reshunter_next  = reserve_button_pay(scriptinfo_color.force - use_force, 4, "Pay_Hunter",  "hunter",  reshunter_next,  5);
		rescruiser_next = reserve_button_pay(scriptinfo_color.force - use_force, 9, "Pay_Cruiser", "cruiser", rescruiser_next, 10);
		
		ressoldier_use = reserve_button_change(scriptinfo_color.ressoldier, ressoldier_use, ressoldier_next, "Pay_Commando",  "commando");
		resraider_use  = reserve_button_change(scriptinfo_color.resraider,  resraider_use,  resraider_next,  "Pay_Bomber",    "bomber");
		reshunter_use  = reserve_button_change(scriptinfo_color.reshunter,  reshunter_use,  reshunter_next,  "Pay_Fighter",   "fighter");
		rescruiser_use = reserve_button_change(scriptinfo_color.rescruiser, rescruiser_use, rescruiser_next, "Pay_Destroyer", "destroyer");	
		reserve_button_changehb(scriptinfo_color);

		ressoldier_use   = reserve_button_move("Soldier",   scriptinfo_color.ressoldier,   ressoldier_use,   ressoldier_next,   hq_color_res, "soldier");
		resraider_use    = reserve_button_move("Raider",    scriptinfo_color.resraider,    resraider_use,    resraider_next,    hq_color_res, "raider");
		rescruiser_use   = reserve_button_move("Cruiser",   scriptinfo_color.rescruiser,   rescruiser_use,   rescruiser_next,   hq_color_res, "cruiser");
		reshunter_use    = reserve_button_move("Hunter",    scriptinfo_color.reshunter,    reshunter_use,    reshunter_next,    hq_color_res, "hunter");
		rescommando_use  = reserve_button_move("Commando",  scriptinfo_color.rescommando,  rescommando_use,  rescommando_next,  hq_color_res, "commando");
		resbomber_use    = reserve_button_move("Bomber",    scriptinfo_color.resbomber,    resbomber_use,    resbomber_next,    hq_color_res, "bomber");
		resfighter_use   = reserve_button_move("Fighter",   scriptinfo_color.resfighter,   resfighter_use,   resfighter_next,   hq_color_res, "fighter");
		resdestroyer_use = reserve_button_move("Destroyer", scriptinfo_color.resdestroyer, resdestroyer_use, resdestroyer_next, hq_color_res, "destroyer");
		reserve_button_moveHB(scriptinfo_color.reshbomb);
		
		GameObject.Find("a - Boxes/Reserve_Box/Force_Box/Reserve_Force/Reserve_Text").GetComponent(TextMesh).text = (scriptinfo_color.force - use_force) + " ";
	}
}

function reserve_button_NOplayable(filtre_player : String, scriptinfo_color : allInfo)
{
	GameObject.Find("a - Boxes/Reserve_Box/Reserve_Text/Reserve_Text").GetComponent(TextMesh).text = "Reserve";
	GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_reserve(filtre_player);
	if (scriptinfo_color.enabled) {
		GameObject.Find("a - Boxes/Reserve_Box/Soldier_Box/Reserve_Soldier/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.ressoldier + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Raider_Box/Reserve_Raider/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.resraider + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Cruiser_Box/Reserve_Cruiser/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.rescruiser + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Hunter_Box/Reserve_Hunter/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.reshunter + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Commando_Box/Reserve_Commando/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.rescommando + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Bomber_Box/Reserve_Bomber/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.resbomber + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Fighter_Box/Reserve_Fighter/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.resfighter + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Destroyer_Box/Reserve_Destroyer/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.resdestroyer + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Force_Box/Reserve_Force/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.force + " ";
		GameObject.Find("a - Boxes/Reserve_Box/H-Bomb_Box/Reserve_H-Bomb/Reserve_Text").GetComponent(TextMesh).text = scriptinfo_color.reshbomb + " ";
	}
	else {
		GameObject.Find("a - Boxes/Reserve_Box/Soldier_Box/Reserve_Soldier/Reserve_Text").GetComponent(TextMesh).text = ressoldier + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Raider_Box/Reserve_Raider/Reserve_Text").GetComponent(TextMesh).text = resraider + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Cruiser_Box/Reserve_Cruiser/Reserve_Text").GetComponent(TextMesh).text = rescruiser + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Hunter_Box/Reserve_Hunter/Reserve_Text").GetComponent(TextMesh).text = reshunter + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Commando_Box/Reserve_Commando/Reserve_Text").GetComponent(TextMesh).text = rescommando + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Bomber_Box/Reserve_Bomber/Reserve_Text").GetComponent(TextMesh).text = resbomber + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Fighter_Box/Reserve_Fighter/Reserve_Text").GetComponent(TextMesh).text = resfighter + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Destroyer_Box/Reserve_Destroyer/Reserve_Text").GetComponent(TextMesh).text = resdestroyer + " ";
		GameObject.Find("a - Boxes/Reserve_Box/Force_Box/Reserve_Force/Reserve_Text").GetComponent(TextMesh).text = resforce + " ";
		GameObject.Find("a - Boxes/Reserve_Box/H-Bomb_Box/Reserve_H-Bomb/Reserve_Text").GetComponent(TextMesh).text = resh_bomb + " ";
	}
}

function reserve_button ()
{
	if (Network.isServer && nb < 2)
		reserve_button_playable("Player Green", scriptinfogreen, "HQ_Green");
	else if (Network.isClient && name.IndexOf("blue") != -1 && (nb == 2 || nb == 0))
		reserve_button_playable("Player Blue", scriptinfoblue, "HQ_Blue");
	else if (Network.isClient && name.IndexOf("red") != -1 && (nb == 3 || nb == 0))
		reserve_button_playable("Player Red", scriptinfored, "HQ_Red");
	else if (Network.isClient && name.IndexOf("yellow") != -1 && (nb == 4 || nb == 0))
		reserve_button_playable("Player Yellow", scriptinfoyellow, "HQ_Yellow");
	else {
		script_allChoose.name_button("Backreserve").SetActive(false);
		script_allChoose.name_button("Okreserve").SetActive(false);
		script_allChoose.name_button("Pay_Soldier").SetActive(false); 
		script_allChoose.name_button("Pay_Raider").SetActive(false);
		script_allChoose.name_button("Pay_Hunter").SetActive(false);
		script_allChoose.name_button("Pay_Cruiser").SetActive(false);
		script_allChoose.name_button("Pay_Commando").SetActive(false);
		script_allChoose.name_button("Pay_Bomber").SetActive(false);
		script_allChoose.name_button("Pay_Fighter").SetActive(false);
		script_allChoose.name_button("Pay_Destroyer").SetActive(false);
		script_allChoose.name_button("Pay_H-Bomb").SetActive(false);
		if (nb == 1)
			reserve_button_NOplayable("Player Green", scriptinfogreen);
		else if (nb == 2)
			reserve_button_NOplayable("Player Blue", scriptinfoblue);
		else if (nb == 3)
			reserve_button_NOplayable("Player Red", scriptinfored);
		else if (nb == 4)
			reserve_button_NOplayable("Player Yellow", scriptinfoyellow);
	}
}

/* **************************************** FUNCTION D'INFORMATION **************************************** */

function info_button_move(player_human : boolean, nb_pion : int, button_pion : String, nbmove : int, val : int)
{
	if (nb_pion)
	{
		script_allChoose.name_button(button_pion).SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/" + button_pion + "/Button_Text").GetComponent(TextMesh).text = nb_pion + " ";
		if (player_human && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button(button_pion)) && information)
			deplacement(nbmove, val);
	}
	else
		script_allChoose.name_button(button_pion).SetActive(false);
		
}

function info_button_move2(player_human : boolean, nb_pion : int, button_pion : String, nbmove : int, val : int)
{
	if (nb_pion)
	{
		script_allChoose.name_button(button_pion).SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/" + button_pion + "/Button_Text").GetComponent(TextMesh).text = nb_pion + " ";
		if (player_human && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button(button_pion)) && information)
			deplacement(nbmove, val);
	}
	else
		script_allChoose.name_button(button_pion).SetActive(false);
		
}

function info_button_change(nb_pion : int, button_pion : String, piece : String)
{
	if (nb_pion > (2 - pion_next(piece, case_name)))
	{
		script_allChoose.name_button(button_pion).SetActive(true);
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button(button_pion)) && information == 1)
		{
			feuille_ordre("changedec", case_name, piece);
			nb = 0;
			zoom(-9, 6.5, 0, 1, 1, -1, "Infos_Box");
			information = 0;
		}
	}
	else
		script_allChoose.name_button(button_pion).SetActive(false);
}

function info_button_changeHB (script : allInfo) {
	if (force_hbomb(0, case_name, script) >= 100) {
		script_allChoose.name_button("Change_HBomb").SetActive(true);
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Change_HBomb")) && information == 1) {
			exe = 2;
			soldierh = soldier + pion_next("soldier", case_name);
			raiderh = raider + pion_next("raider", case_name);
			hunterh = hunter + pion_next("hunter", case_name);
			cruiserh = cruiser + pion_next("cruiser", case_name);
			commandoh = commando + pion_next("commando", case_name);
			bomberh = bomber + pion_next("bomber", case_name);
			fighterh = fighter + pion_next("fighter", case_name);
			destroyerh = destroyer + pion_next("destroyer", case_name);
			forceh = script.force - use_force;
			hbomb_piece = "h_bomb";
		}
	}
	else
		script_allChoose.name_button("Change_HBomb").SetActive(false);
}

function create_hbomb () {
	script_allChoose.name_button("Change_HBomb").SetActive(false);
	script_allChoose.name_button("Change_Commando").SetActive(false);
	script_allChoose.name_button("Change_Bomber").SetActive(false);
	script_allChoose.name_button("Change_Fighter").SetActive(false);
	script_allChoose.name_button("Change_Destroyer").SetActive(false);
	script_allChoose.name_button("Button_H-Bomb").SetActive(false);
	GameObject.Find("a - Boxes/Infos_Box/Info_Text/Info_Text").GetComponent(TextMesh).text = "H-Bomb : " + av_hbomb();
	if (soldierh) {
		script_allChoose.name_button("Button_Soldier").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Soldier/Button_Text").GetComponent(TextMesh).text = soldierh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Soldier"))) {
			soldierh--;
			hbomb_piece += "-soldier";
		}
	}
	else
		script_allChoose.name_button("Button_Soldier").SetActive(false);
	if (raiderh) {
		script_allChoose.name_button("Button_Raider").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Raider/Button_Text").GetComponent(TextMesh).text = raiderh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Raider"))) {
			raiderh--;
			hbomb_piece += "-raider";
		}
	}
	else
		script_allChoose.name_button("Button_Raider").SetActive(false);
	if (cruiserh) {
		script_allChoose.name_button("Button_Cruiser").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Cruiser/Button_Text").GetComponent(TextMesh).text = cruiserh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Cruiser"))) {
			cruiserh--;
			hbomb_piece += "-cruiser";
		}
	}
	else
		script_allChoose.name_button("Button_Cruiser").SetActive(false);
	if (hunterh) {
		script_allChoose.name_button("Button_Hunter").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Hunter/Button_Text").GetComponent(TextMesh).text = hunterh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Hunter"))) {
			hunterh--;
			hbomb_piece += "-hunter";
		}
	}
	else
		script_allChoose.name_button("Button_Hunter").SetActive(false);
	if (commandoh) {
		script_allChoose.name_button("Button_Commando").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Commando/Button_Text").GetComponent(TextMesh).text = commandoh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Commando"))) {
			commandoh--;
			hbomb_piece += "-commando";
		}
	}
	else
		script_allChoose.name_button("Button_Commando").SetActive(false);
	if (bomberh) {
		script_allChoose.name_button("Button_Bomber").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Bomber/Button_Text").GetComponent(TextMesh).text = bomberh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Bomber"))) {
			bomberh--;
			hbomb_piece += "-bomber";
		}
	}
	else
		script_allChoose.name_button("Button_Bomber").SetActive(false);
	if (fighterh) {
		script_allChoose.name_button("Button_Fighter").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Fighter/Button_Text").GetComponent(TextMesh).text = fighterh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Fighter"))) {
			fighterh--;
			hbomb_piece += "-fighter";
		}
	}
	else
		script_allChoose.name_button("Button_Fighter").SetActive(false);
	if (destroyerh) {
		script_allChoose.name_button("Button_Destroyer").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Button_Destroyer/Button_Text").GetComponent(TextMesh).text = destroyerh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Button_Destroyer"))) {
			destroyerh--;
			hbomb_piece += "-destroyer";
		}
	}
	else
		script_allChoose.name_button("Button_Destroyer").SetActive(false);
	if (forceh) {
		script_allChoose.name_button("Force_Info").SetActive(true);
		GameObject.Find("a - Boxes/Infos_Box/Force_Info/Force_Text").GetComponent(TextMesh).text = forceh + " ";
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Force_Info"))) {
			forceh--;
			hbomb_piece += "-force";
		}
	}
	else
		script_allChoose.name_button("Force_Info").SetActive(false);
	script_allChoose.name_button("Backinfo").SetActive(true);
	if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Backinfo")))
		exe = 0;
	if (av_hbomb() >= 100) {
		script_allChoose.name_button("Okinfo").SetActive(true);
		if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Okinfo"))) {
			feuille_ordre("changedec", case_name, hbomb_piece);
			nb = 0;
			zoom(-9, 6.5, 0, 1, 1, -1, "Infos_Box");
			exe = 0;
			information = 0;
		}
	}
	else
		script_allChoose.name_button("Okinfo").SetActive(false);
}

function info_button2()
{
	GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_info(case_name, nb, script_allChoose.button_info, 0);
	info_button_move(false, soldier, "Button_Soldier", 0, 0);
	info_button_move(false, raider, "Button_Raider", 0, 0);
	info_button_move(false, cruiser, "Button_Cruiser", 0, 0);
	info_button_move(false, hunter, "Button_Hunter", 0, 0);
	info_button_move(false, commando, "Button_Commando", 0, 0);
	info_button_move(false, bomber, "Button_Bomber", 0, 0);
	info_button_move(false, fighter, "Button_Fighter", 0, 0);
	info_button_move(false, destroyer, "Button_Destroyer", 0, 0);
	info_button_move(false, h_bomb, "Button_H-Bomb", 0, 0);
}

function info_button()
{
	if (nb > 0)
	{
		if ((Network.isServer && nb == 1)
			|| (Network.isClient && nb == 2 && name.IndexOf("blue") != -1)
			|| (Network.isClient && nb == 3 && name.IndexOf("red") != -1)
			|| (Network.isClient && nb == 4 && name.IndexOf("yellow") != -1)) {
			if (exe == 2)
				create_hbomb();
			else {
				script_allChoose.info_case.SetActive(true);
				script_allChoose.name_button("Info_Text").SetActive(true);
				GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_info(case_name, nb, script_allChoose.button_info, on);
				script_allChoose.name_button("Force_Info").SetActive(false);
				script_allChoose.name_button("Backinfo").SetActive(false);
				script_allChoose.name_button("Okinfo").SetActive(false);
				GameObject.Find("a - Boxes/Infos_Box/Info_Text/Info_Text").GetComponent(TextMesh).text = "Case Info";
				
				info_button_move(true, soldier, "Button_Soldier", 2, 1);
				info_button_move(true, raider, "Button_Raider", 3, 2);
				info_button_move(true, cruiser, "Button_Cruiser", 0, 3);
				info_button_move(true, hunter, "Button_Hunter", 0, 4);
				
				info_button_change(soldier, "Change_Commando", "soldier");
				info_button_change(raider, "Change_Bomber", "raider");
				info_button_change(hunter, "Change_Fighter", "hunter");
				info_button_change(cruiser, "Change_Destroyer", "cruiser");
				if (nb == 1)
					info_button_changeHB(scriptinfogreen);
				else if (nb == 2)
					info_button_changeHB(scriptinfoblue);
				else if (nb == 3)
					info_button_changeHB(scriptinfored);
				else if (nb == 4)
					info_button_changeHB(scriptinfoyellow);
				
				info_button_move(true, commando, "Button_Commando", 2, 5);
				info_button_move(true, bomber, "Button_Bomber", 3, 6);
				info_button_move(true, destroyer, "Button_Destroyer", 0, 7);
				info_button_move(true, fighter, "Button_Fighter", 0, 8);
				info_button_move2(true, h_bomb, "Button_H-Bomb", 0, 9);
			}
		}
		else {
			script_allChoose.info_case.SetActive(true);
			script_allChoose.name_button("Info_Text").SetActive(true);
			script_allChoose.name_button("Change_Commando").SetActive(false);
			script_allChoose.name_button("Change_Fighter").SetActive(false);
			script_allChoose.name_button("Change_Destroyer").SetActive(false);
			script_allChoose.name_button("Change_Bomber").SetActive(false);
			script_allChoose.name_button("Change_HBomb").SetActive(false);
			GameObject.Find("a - Boxes/Infos_Box/Info_Text/Info_Text").GetComponent(TextMesh).text = "Case Info";
			info_button2();
		}
	}
	else if (nb == 0)
		script_allChoose.info_case.SetActive(false);
}

/* **************************************** FUNCTION D'UPDATE ET D'ACTIVATE ET DE SELECT ET D'EXECUTION D'ORDRE **************************************** */

function select (mov : GameObject) {
	if (on == 1) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "soldier");
		}
	}
	else if (on == 2) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "raider");
		}
	}
	else if (on == 3) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "cruiser");
		}
	}
	else if (on == 4) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "hunter");
		}
	}
	else if (on == 5) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "commando");
		}
	}
	else if (on == 6) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "bomber");
		}
	}
	else if (on == 7) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "destroyer");
		}
	}
	else if (on == 8) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "fighter");
		}
	}
	else if (on == 9) {
		for (var dec : GameObject in decor) {
			if (dec.name == case_name)
				feuille_ordre(dec.name, mov.name, "h_bomb");
		}
	}
	else if (on == 10)
		feuille_ordre("reserve", mov.name, "h_bomb");
	renderer_of(1);
	nb = 0;
}

function pad_hbomb () {
	script_allChoose.name_button("Pad_Box").SetActive(false);
	if (scriptinfoblue.isalive)
		script_allChoose.name_button("Reserve_HBomb1").SetActive(true);
	if (scriptinfored.isalive)
		script_allChoose.name_button("Reserve_HBomb2").SetActive(true);
	if (scriptinfoyellow.isalive)
		script_allChoose.name_button("Reserve_HBomb3").SetActive(true);
	if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_HBomb1")) && scriptinfoblue.isalive) {
		if (on == 10)
			feuille_ordre("reserve", "reserve_blue", "h_bomb");
		else
			feuille_ordre(case_name, "reserve_blue", "h_bomb");
		renderer_of(1);
		reserve_button();
	}
	else if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_HBomb2")) && scriptinfored.isalive) {
		if (on == 10)
			feuille_ordre("reserve", "reserve_red", "h_bomb");
		else
			feuille_ordre(case_name, "reserve_red", "h_bomb");
		renderer_of(1);
		reserve_button();
	}
	else if (Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_HBomb3")) && scriptinfoyellow.isalive) {
		if (on == 10)
			feuille_ordre("reserve", "reserve_yellow", "h_bomb");
		else
			feuille_ordre(case_name, "reserve_yellow", "h_bomb");
		renderer_of(1);
		reserve_button();
	}
}

function zoom (posx, posy, posz, scalex, scaley, nbres, text : String) {
	if (nbres != -1)
		reserve = nbres;
	script_allChoose.name_button(text).transform.localPosition.x = posx;
	script_allChoose.name_button(text).transform.localPosition.y = posy;
	script_allChoose.name_button(text).transform.localPosition.z = posz;
	script_allChoose.name_button(text).transform.localScale.x = scalex;
	script_allChoose.name_button(text).transform.localScale.y = scaley;
}

function exe_all_ordre () {
	var nbordre : int;
	nbordre = 0;
	attribution_val(0, soldier_use, 15);
	attribution_val(0, raider_use, 15);
	attribution_val(0, cruiser_use, 15);
	attribution_val(0, hunter_use, 15);
	attribution_val(0, commando_use, 15);
	attribution_val(0, bomber_use, 15);
	attribution_val(0, fighter_use, 15);
	attribution_val(0, destroyer_use, 15);
	attribution_val(0, h_bomb_use, 15);
	ressoldier_use = 0;
	resraider_use = 0;
	rescruiser_use = 0;
	reshunter_use = 0;
	rescommando_use = 0;
	resbomber_use = 0;
	resfighter_use = 0;
	resdestroyer_use = 0;
	resh_bomb_use = 0;
	ressoldier_next = 0;
	resraider_next = 0;
	rescruiser_next = 0;
	reshunter_next = 0;
	rescommando_next = 0;
	resbomber_next = 0;
	resfighter_next = 0;
	resdestroyer_next = 0;
	reshbomb_next = 0;
	use_force = 0;

	script_allChoose.wait_exe = 0;
	while (++nbordre < ordre) {
		var recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
		var recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
		var recup3 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
		script_allChoose.wait_ordre = 0;
		if (recup3.IndexOf("h_bomb") != -1) {
			if (name.IndexOf("green") != -1)
				script_allChoose.exe_ordre_h_bomb(recup1, recup2, recup3, scriptinfogreen);
			else if (name.IndexOf("blue") != -1)
				script_allChoose.exe_ordre_h_bomb(recup1, recup2, recup3, scriptinfoblue);
			else if (name.IndexOf("red") != -1)
				script_allChoose.exe_ordre_h_bomb(recup1, recup2, recup3, scriptinfored);
			else if (name.IndexOf("yellow") != -1)
				script_allChoose.exe_ordre_h_bomb(recup1, recup2, recup3, scriptinfoyellow);
		}
		else if (recup1 != "reserve" && recup1 != "power" && recup1 != "change" && recup1 != "changedec") {
			if (name.IndexOf("green") != -1)
				script_allChoose.exe_ordre(recup1, recup2, recup3, scriptinfogreen);
			else if (name.IndexOf("blue") != -1)
				script_allChoose.exe_ordre(recup1, recup2, recup3, scriptinfoblue);
			else if (name.IndexOf("red") != -1)
				script_allChoose.exe_ordre(recup1, recup2, recup3, scriptinfored);
			else if (name.IndexOf("yellow") != -1)
				script_allChoose.exe_ordre(recup1, recup2, recup3, scriptinfoyellow);
		}
		else if (recup1 == "changedec") {
			if (name.IndexOf("green") != -1)
				script_allChoose.exe_ordre2(recup2, recup3, scriptinfogreen);
			else if (name.IndexOf("blue") != -1)
				script_allChoose.exe_ordre2(recup2, recup3, scriptinfoblue);
			else if (name.IndexOf("red") != -1)
				script_allChoose.exe_ordre2(recup2, recup3, scriptinfored);
			else if (name.IndexOf("yellow") != -1)
				script_allChoose.exe_ordre2(recup2, recup3, scriptinfoyellow);
		}
		else {
			if (name.IndexOf("green") != -1)
				script_allChoose.exe_ordre1(recup1, recup3, recup2, scriptinfogreen);
			else if (name.IndexOf("blue") != -1)
				script_allChoose.exe_ordre1(recup1, recup3, recup2, scriptinfoblue);
			else if (name.IndexOf("red") != -1)
				script_allChoose.exe_ordre1(recup1, recup3, recup2, scriptinfored);
			else if (name.IndexOf("yellow") != -1)
				script_allChoose.exe_ordre1(recup1, recup3, recup2, scriptinfoyellow);
		}
		while (!script_allChoose.wait_ordre)
			yield WaitForSeconds(1);
	}
	script_allChoose.wait_exe = 1;
	script_allChoose.client_exe_ordre("blue", script_allChoose.wait_exe, 1);
}

function write_timer_s () {
	var time_s : int;
	var time_string : String;

	time_s = time % 60;
	if ((60 - time_s) < 10)
		time_string = "0" + (60 - time_s);
	else if ((60 - time_s) == 60)
		time_string = "00";
	else
		time_string = "" + (60 - time_s);
	return (time_string);
}

function write_timer_m () {
	var time_m : int;

	time_m = time / 60;
	if (write_timer_s() == "00")
		time_m--;
	return (59 - time_m);
}

function pad_button () {
	if (time < 3601)
		GameObject.Find("a - Boxes/Pad_Box/Pad_Text").GetComponent(TextMesh).text = "Orders / timer : " + write_timer_m() + ":" + write_timer_s() ;
	if (ordre > 1) {
		script_allChoose.name_button("Order_1").SetActive(true);
		var recup ;
		GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_pad(recup, 1);
		if (ordre > 2) {
			script_allChoose.name_button("Order_2").SetActive(true);
			GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_pad(recup, 2);
			if (ordre > 3) {
				script_allChoose.name_button("Order_3").SetActive(true);
				GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_pad(recup, 3);
				if (ordre > 4) {
					script_allChoose.name_button("Order_4").SetActive(true);
					GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_pad(recup, 4);
					if (ordre > 5) {
						script_allChoose.name_button("Order_5").SetActive(true);
						GameObject.Find("0 - Decor").GetComponent(filtre_case_name).filtre_pad(recup, 5);
					}
					else
						script_allChoose.name_button("Order_5").SetActive(false);
				}
				else
					script_allChoose.name_button("Order_4").SetActive(false);
			}
			else
				script_allChoose.name_button("Order_3").SetActive(false);
		}
		else
			script_allChoose.name_button("Order_2").SetActive(false);

		if (!on && !exe) {
			script_allChoose.name_button("Back").SetActive(true);
			if (!reserve && !information && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Back"))) {
				attribution_val(0, soldier_use, 15);
				attribution_val(0, raider_use, 15);
				attribution_val(0, cruiser_use, 15);
				attribution_val(0, hunter_use, 15);
				attribution_val(0, commando_use, 5);
				attribution_val(0, bomber_use, 5);
				attribution_val(0, fighter_use, 5);
				attribution_val(0, destroyer_use, 5);
				attribution_val(0, h_bomb_use, 5);
				resh_bomb_use = 0;
				ordre--;
					recup = PlayerPrefs.GetString("Orde" + ordre + "depart");
				if (recup == "reserve" || recup == "change")
					reduc_res_use(PlayerPrefs.GetString("Orde" + ordre + "piece"), recup);
				else if (recup == "power")
					reduc_pow_use(PlayerPrefs.GetString("Orde" + ordre + "piece"));
				nbcount = 1;
				nb = 0;
				reserve_button();
			}
		}
		else
			script_allChoose.name_button("Back").SetActive(false);
		while (nbcount < ordre && !exe) {
			if (Network.isServer)
				verif_ordre(PlayerPrefs.GetString("Orde" + nbcount + "depart"), PlayerPrefs.GetString("Orde" + nbcount + "arriver"), PlayerPrefs.GetString("Orde" + nbcount + "piece"), scriptinfogreen);
			else if (Network.isClient && name.IndexOf("blue") != -1)
				verif_ordre(PlayerPrefs.GetString("Orde" + nbcount + "depart"), PlayerPrefs.GetString("Orde" + nbcount + "arriver"), PlayerPrefs.GetString("Orde" + nbcount + "piece"), scriptinfoblue);
			else if (Network.isClient && name.IndexOf("red") != -1)
				verif_ordre(PlayerPrefs.GetString("Orde" + nbcount + "depart"), PlayerPrefs.GetString("Orde" + nbcount + "arriver"), PlayerPrefs.GetString("Orde" + nbcount + "piece"), scriptinfored);
			else if (Network.isClient && name.IndexOf("yellow") != -1)
				verif_ordre(PlayerPrefs.GetString("Orde" + nbcount + "depart"), PlayerPrefs.GetString("Orde" + nbcount + "arriver"), PlayerPrefs.GetString("Orde" + nbcount + "piece"), scriptinfoyellow);
			nbcount++;
		}
		if (!on && !exe) {
			script_allChoose.name_button("OK").SetActive(true);
			if (!reserve && !information && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("OK"))) {
				exe = 1;
				renderer_of(1);
				if (Network.isServer) {
					if (scriptinfoblue.enabled && scriptinfored.enabled && scriptinfoyellow.enabled)
						script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					else if (!scriptinfoblue.enabled && scriptinfored.enabled && scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_blue)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
					else if (!scriptinfoblue.enabled && !scriptinfored.enabled && scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_blue || !script_allChoose.exe_red)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
					else if (!scriptinfoblue.enabled && !scriptinfored.enabled && !scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_blue || !script_allChoose.exe_red || !script_allChoose.exe_yellow)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
					else if (scriptinfoblue.enabled && !scriptinfored.enabled && scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_red)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
					else if (scriptinfoblue.enabled && !scriptinfored.enabled && !scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_blue || !script_allChoose.exe_yellow)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
					else if (scriptinfoblue.enabled && scriptinfored.enabled && !scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_yellow)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
					else if (!scriptinfoblue.enabled && scriptinfored.enabled && !scriptinfoyellow.enabled) {
						while (!script_allChoose.exe_blue || !script_allChoose.exe_yellow)
							yield WaitForSeconds(1);
							script_allChoose.script_chaos.execution_all_ordre(scriptinfogreen, scriptinfoblue, scriptinfored, scriptinfoyellow);
					}
				}
				else {
					if (name.IndexOf("blue") != -1) {
						while (!script_allChoose.wait_for_order_blue) {
							script_allChoose.client_exe_ordre("blue", script_allChoose.wait_exe, 0);
							yield WaitForSeconds(1);
						}
						exe_all_ordre();
					}
					else if (name.IndexOf("red") != -1) {
						while (!script_allChoose.wait_for_order_red) {
							script_allChoose.client_exe_ordre("red", script_allChoose.wait_exe, 0);
							yield WaitForSeconds(1);
						}
						exe_all_ordre();
					}
					else if (name.IndexOf("yellow") != -1) {
						while (!script_allChoose.wait_for_order_yellow) {
							script_allChoose.client_exe_ordre("yellow", script_allChoose.wait_exe, 0);
							yield WaitForSeconds(1);
						}
						exe_all_ordre();
					}
				}
			}
		}
		else
			script_allChoose.name_button("OK").SetActive(false);
	}
	else {
		for (var pad : GameObject in script_allChoose.button_pad)
			pad.SetActive(false);
	}
}

function deplacement (nbmove : int, val : int) {
	var script = GameObject.Find("Main Camera").GetComponent(Dep_terre);
	var script1 = GameObject.Find("Main Camera").GetComponent(Dep_air);
	var script2 = GameObject.Find("Main Camera").GetComponent(Dep_mer);

	on = val;
	if (on != 10) {
		zoom(-9, 6.5, 0, 1, 1, -1, "Infos_Box");
		information = 2;
	}
	else if (on == 10) {
		zoom(-9, 5, 0, 1, 1, 0, "Reserve_Box");
		reserve = 2;
	}
	if ((on == 1 || on == 5) && script)
		script.deplacement_terrestre(nbmove, case_name);
	else if ((on == 2 || on == 6) && script)
		script.deplacement_terrestre(nbmove, case_name);
	else if ((on == 3 || on == 7) && script2)
		script2.deplacement_mer(case_name);
	else if ((on == 4 || on == 8) && script1)
		script1.deplacement_air(case_name);
	if (on == 9 || on == 10) {
		for (var mov : GameObject in move) {
			if (mov.name != case_name || on == 10)
				mov.renderer.enabled = true;
		}
	}
}

function renderer_of (param : int) {
	if (param) {
		nb = 0;
		information = 0;
		reserve = 0;
	}
	on = 0;
	for (var mov : GameObject in move) {
		if (mov.renderer.enabled)
			mov.renderer.enabled = false;
	}
}

function activate (dec : GameObject, script : allInfo, view_ok : int) {

	if (view_ok > 0) {
		if (view_ok == 1) {
			soldier = view(dec, script.save_soldier, 2, soldier_use);
			raider = view(dec, script.save_raider, 2, raider_use);
			cruiser = view(dec, script.save_cruiser, 2, cruiser_use);
			hunter = view(dec, script.save_hunter, 2, hunter_use);
			commando = view(dec, script.save_commando, 2, commando_use);
			bomber = view(dec, script.save_bomber, 2, bomber_use);
			fighter = view(dec, script.save_fighter, 2, fighter_use);
			destroyer = view(dec, script.save_destroyer, 2, destroyer_use);
			h_bomb = view(dec, script.save_hbomb, 2, h_bomb_use);
			h_bomb += pion_next("h_bomb", case_name);
		}
		else {
			soldier = view1(dec, script.save_soldier, 2);
			raider = view1(dec, script.save_raider, 2);
			cruiser = view1(dec, script.save_cruiser, 2);
			hunter = view1(dec, script.save_hunter, 2);
			commando = view1(dec, script.save_commando, 2);
			bomber = view1(dec, script.save_bomber, 2);
			fighter = view1(dec, script.save_fighter, 2);
			destroyer = view1(dec, script.save_destroyer, 2);
			h_bomb = view1(dec, script.save_hbomb, 2);
		}
	}
	else {
		script_allChoose.soldier = 0;
		script_allChoose.raider = 0;
		script_allChoose.hunter = 0;
		script_allChoose.cruiser = 0;
		script_allChoose.commando = 0;
		script_allChoose.bomber = 0;
		script_allChoose.fighter = 0;
		script_allChoose.destroyer = 0;
		script_allChoose.h_bomb = 0;

		script_allChoose.ressoldierall = 0;
		script_allChoose.resraiderall = 0;
		script_allChoose.reshunterall = 0;
		script_allChoose.rescruiserall = 0;
		script_allChoose.rescommandoall = 0;
		script_allChoose.resbomberall = 0;
		script_allChoose.resfighterall = 0;
		script_allChoose.resdestroyerall = 0;
		script_allChoose.resforceall = 0;
		script_allChoose.reshbomball = 0;
		if (Network.isServer) {
			if (view_ok == -2 && !nb) {
				soldier = view2(dec, script_allChoose.scriptinfoblue.coordsoldier, 2);
				raider = view2(dec, script_allChoose.scriptinfoblue.coordraider, 2);
				cruiser = view2(dec, script_allChoose.scriptinfoblue.coordcruiser, 2);
				hunter = view2(dec, script_allChoose.scriptinfoblue.coordhunter, 2);
				commando = view2(dec, script_allChoose.scriptinfoblue.coordcommando, 2);
				bomber = view2(dec, script_allChoose.scriptinfoblue.coordbomber, 2);
				fighter = view2(dec, script_allChoose.scriptinfoblue.coordfighter, 2);
				destroyer = view2(dec, script_allChoose.scriptinfoblue.coorddestroyer, 2);
				h_bomb = view2(dec, script_allChoose.scriptinfoblue.coordhbomb, 2);
				ressoldier = script_allChoose.scriptinfoblue.ressoldier;
				resraider = script_allChoose.scriptinfoblue.resraider;
				reshunter = script_allChoose.scriptinfoblue.reshunter;
				rescruiser = script_allChoose.scriptinfoblue.rescruiser;
				rescommando = script_allChoose.scriptinfoblue.rescommando;
				resbomber = script_allChoose.scriptinfoblue.resbomber;
				resfighter = script_allChoose.scriptinfoblue.resfighter;
				resdestroyer = script_allChoose.scriptinfoblue.resdestroyer;
				resh_bomb = script_allChoose.scriptinfoblue.reshbomb;
				resforce = script_allChoose.scriptinfoblue.force;
			}
			else if (view_ok == -3 && !nb) {
				soldier = view2(dec, script_allChoose.scriptinfored.coordsoldier, 2);
				raider = view2(dec, script_allChoose.scriptinfored.coordraider, 2);
				cruiser = view2(dec, script_allChoose.scriptinfored.coordcruiser, 2);
				hunter = view2(dec, script_allChoose.scriptinfored.coordhunter, 2);
				commando = view2(dec, script_allChoose.scriptinfored.coordcommando, 2);
				bomber = view2(dec, script_allChoose.scriptinfored.coordbomber, 2);
				fighter = view2(dec, script_allChoose.scriptinfored.coordfighter, 2);
				destroyer = view2(dec, script_allChoose.scriptinfored.coorddestroyer, 2);
				h_bomb = view2(dec, script_allChoose.scriptinfored.coordhbomb, 2);
				ressoldier = script_allChoose.scriptinfored.ressoldier;
				resraider = script_allChoose.scriptinfored.resraider;
				reshunter = script_allChoose.scriptinfored.reshunter;
				rescruiser = script_allChoose.scriptinfored.rescruiser;
				rescommando = script_allChoose.scriptinfored.rescommando;
				resbomber = script_allChoose.scriptinfored.resbomber;
				resfighter = script_allChoose.scriptinfored.resfighter;
				resdestroyer = script_allChoose.scriptinfored.resdestroyer;
				resh_bomb = script_allChoose.scriptinfored.reshbomb;
				resforce = script_allChoose.scriptinfored.force;
			}
			else if (view_ok == -4 && !nb) {
				soldier = view2(dec, script_allChoose.scriptinfoyellow.coordsoldier, 2);
				raider = view2(dec, script_allChoose.scriptinfoyellow.coordraider, 2);
				cruiser = view2(dec, script_allChoose.scriptinfoyellow.coordcruiser, 2);
				hunter = view2(dec, script_allChoose.scriptinfoyellow.coordhunter, 2);
				commando = view2(dec, script_allChoose.scriptinfoyellow.coordcommando, 2);
				bomber = view2(dec, script_allChoose.scriptinfoyellow.coordbomber, 2);
				fighter = view2(dec, script_allChoose.scriptinfoyellow.coordfighter, 2);
				destroyer = view2(dec, script_allChoose.scriptinfoyellow.coorddestroyer, 2);
				h_bomb = view2(dec, script_allChoose.scriptinfoyellow.coordhbomb, 2);
				ressoldier = script_allChoose.scriptinfoyellow.ressoldier;
				resraider = script_allChoose.scriptinfoyellow.resraider;
				reshunter = script_allChoose.scriptinfoyellow.reshunter;
				rescruiser = script_allChoose.scriptinfoyellow.rescruiser;
				rescommando = script_allChoose.scriptinfoyellow.rescommando;
				resbomber = script_allChoose.scriptinfoyellow.resbomber;
				resfighter = script_allChoose.scriptinfoyellow.resfighter;
				resdestroyer = script_allChoose.scriptinfoyellow.resdestroyer;
				resh_bomb = script_allChoose.scriptinfoyellow.reshbomb;
				resforce = script_allChoose.scriptinfoyellow.force;
			}
		}
		else if (Network.isClient) {
			if (view_ok == -1)
				script_allChoose.client(dec, "green");
			else if (view_ok == -2)
				script_allChoose.client(dec, "blue");
			else if (view_ok == -3)
				script_allChoose.client(dec, "red");
			else if (view_ok == -4)
				script_allChoose.client(dec, "yellow");
			yield WaitForSeconds(0.05);
			if (!nb && (view_ok == -1 && script_allChoose.color_nb == 1)
				|| (view_ok == -2 && script_allChoose.color_nb == 2)
				|| (view_ok == -3 && script_allChoose.color_nb == 3)
				|| (view_ok == -4 && script_allChoose.color_nb == 4)) {
				soldier = script_allChoose.soldier;
				raider = script_allChoose.raider;
				hunter = script_allChoose.hunter;
				cruiser = script_allChoose.cruiser;
				commando = script_allChoose.commando;
				bomber = script_allChoose.bomber;
				fighter = script_allChoose.fighter;
				destroyer = script_allChoose.destroyer;
				h_bomb = script_allChoose.h_bomb;
				ressoldier = script_allChoose.ressoldierall;
				resraider = script_allChoose.resraiderall;
				reshunter = script_allChoose.reshunterall;
				rescruiser = script_allChoose.rescruiserall;
				rescommando = script_allChoose.rescommandoall;
				resbomber = script_allChoose.resbomberall;
				resfighter = script_allChoose.resfighterall;
				resdestroyer = script_allChoose.resdestroyerall;
				resh_bomb = script_allChoose.reshbomball;
				resforce = script_allChoose.resforceall;
			}
		}
		if ((soldier || raider || cruiser || hunter || commando || bomber || fighter || destroyer || h_bomb) && !nb && Network.isClient) {
			if (view_ok == -1)
				nb = 1;
			else if (view_ok == -2)
				nb = 2;
			else if (view_ok == -3)
				nb = 3;
			else if (view_ok == -4)
				nb = 4;
			reserve_button();
		}
	}
}

function timer() {
	wait_time++;
	yield WaitForSeconds(1);
	time++;
}

function Update () {
	if (Application.loadedLevelName == "Battleground") {
		if (!start)
			Start();
		if (Network.isClient) {
			if (name.IndexOf("blue") != -1 && scriptinfoblue.enabled)
				script_allChoose.client_info(scriptinfoblue, "blue", exe);
			else if (name.IndexOf("red") != -1 && scriptinfored.enabled)
				script_allChoose.client_info(scriptinfored, "red", exe);
			else if (name.IndexOf("yellow") != -1 && scriptinfoyellow.enabled)
				script_allChoose.client_info(scriptinfoyellow, "yellow", exe);
		}
		if (ordre == 6)
			nb = 0;
		if (Input.GetKeyDown(KeyCode.Mouse0) && !on && ordre < 6 && !reserve && !information && !exe) {
			for (var dec : GameObject in decor) {
				if (script_allChoose.Zone_Click(dec)) {
					case_name = dec.name;
					nb = 0;
					if (Network.isServer)
						activate(dec, scriptinfogreen, 1);
					else if (Network.isClient && name.IndexOf("blue") != -1)
						activate(dec, scriptinfoblue, 1);
					else if (Network.isClient && name.IndexOf("red") != -1)
						activate(dec, scriptinfored, 1);
					else if (Network.isClient && name.IndexOf("yellow") != -1)
						activate(dec, scriptinfoyellow, 1);
					if ((soldier || raider || cruiser || hunter || commando || bomber || fighter || destroyer || h_bomb
						|| pion_next("soldier", case_name) > 2 || pion_next("raider", case_name) > 2 || pion_next("hunter", case_name) > 2 || pion_next("cruiser", case_name) > 2)) {
						if (Network.isServer)
							nb = 1;
						else if (Network.isClient && name.IndexOf("blue") != -1)
							nb = 2;
						else if (Network.isClient && name.IndexOf("red") != -1)
							nb = 3;
						else if (Network.isClient && name.IndexOf("yellow") != -1)
							nb = 4;
						reserve_button();
					}
					else {
						if (Network.isServer && scriptinfoblue.enabled)
							activate(dec, scriptinfoblue, 2);
						else if (Network.isServer && !scriptinfoblue.enabled)
							activate(dec, scriptinfoblue, -2);
						else if (Network.isClient && name.IndexOf("blue") != -1)
							activate(dec, scriptinfogreen, -1);
						else if (Network.isClient && name.IndexOf("red") != -1)
							activate(dec, scriptinfoblue, -2);
						else if (Network.isClient && name.IndexOf("yellow") != -1)
							activate(dec, scriptinfoblue, -2);
						if ((soldier || raider || cruiser || hunter || commando || bomber || fighter || destroyer || h_bomb) && Network.isServer) {
							nb = 2;
							reserve_button();
						}
						else {
							if (Network.isServer && scriptinfored.enabled)
								activate(dec, scriptinfored, 2);
							else if (Network.isServer && !scriptinfored.enabled)
								activate(dec, scriptinfored, -3);
							else if (Network.isClient && name.IndexOf("red") != -1)
								activate(dec, scriptinfogreen, -1);
							else if (Network.isClient && name.IndexOf("blue") != -1)
								activate(dec, scriptinfored, -3);
							else if (Network.isClient && name.IndexOf("yellow") != -1)
								activate(dec, scriptinfored, -3);
							if ((soldier || raider || cruiser || hunter || commando || bomber || fighter || destroyer || h_bomb) && Network.isServer) {
								nb = 3;
								reserve_button();
							}
							else {
								if (Network.isServer && scriptinfoyellow.enabled)
									activate(dec, scriptinfoyellow, 2);
								else if (Network.isServer && !scriptinfoyellow.enabled)
									activate(dec, scriptinfoyellow, -4);
								else if (Network.isClient && name.IndexOf("yellow") != -1)
									activate(dec, scriptinfogreen, -1);
								else if (Network.isClient && name.IndexOf("red") != -1)
									activate(dec, scriptinfoyellow, -4);
								else if (Network.isClient && name.IndexOf("blue") != -1)
									activate(dec, scriptinfoyellow, -4);
								if ((soldier || raider || cruiser || hunter || commando || bomber || fighter || destroyer || h_bomb) && Network.isServer) {
									nb = 4;
									reserve_button();
								}
								else {
									nb = 0;
									reserve_button();
								}
							}
						}
					}
				}
			}
		}
		else if (Input.GetKeyDown(KeyCode.Mouse0) && on && (!reserve || reserve == 2)) {
			for (var mov : GameObject in move) {
				if (mov.renderer.enabled) {
					if (script_allChoose.Zone_Click(mov)) {
						select(mov);
						information = 0;
						reserve = 0;
					}
				}
			}
		}
		info_button();
		if ((!information || information == 2) && !reserve && nb && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Infos_Box"))) {
			zoom(-5.5, 5, -1, 3, 3, -1, "Infos_Box");
			information = 1;
			renderer_of(0);
		}
		else if (information && Input.GetKeyDown(KeyCode.Mouse0) && (script_allChoose.Zone_Click(script_allChoose.name_button("Info_Text")) || !script_allChoose.Zone_Click(script_allChoose.name_button("Infos_Box"))) && !on) {
			zoom(-9, 6.5, 0, 1, 1, -1, "Infos_Box");
			information = 0;
		}
		else if ((!reserve || reserve == 2) && !information && Input.GetKeyDown(KeyCode.Mouse0) && script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Box")) && !exe) {
			zoom(-5.5, 4, -1, 3, 3, 1, "Reserve_Box");
			renderer_of(0);
		}
		else if (reserve) {
			if (!on) {
				if (Input.GetKeyDown(KeyCode.Mouse0) && (script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Text")) || !script_allChoose.Zone_Click(script_allChoose.name_button("Reserve_Box"))) && !exe)
					zoom(-9, 5, 0, 1, 1, 0, "Reserve_Box");
				reserve_button();
			}
		}
		if (on != 10 && on != 9) {
			script_allChoose.name_button("Pad_Box").SetActive(true);
			pad_button();
			script_allChoose.name_button("Reserve_HBomb1").SetActive(false);
			script_allChoose.name_button("Reserve_HBomb2").SetActive(false);
			script_allChoose.name_button("Reserve_HBomb3").SetActive(false);
		}
		else
			pad_hbomb();
		if (wait_time == time)
			timer();
	}
}
