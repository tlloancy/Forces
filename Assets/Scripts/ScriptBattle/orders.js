private var script_bibli : Biblidecor ;
private var script_allChoose : allChoose;
private var butt : infoButtons;

private var ia_blue : GameObject;
private var ia_red : GameObject;
private var ia_yellow : GameObject;

function Start()
{
	script_bibli = GameObject.Find("Main Camera").GetComponent(Biblidecor);
	script_allChoose = GameObject.Find("0 - Decor").GetComponent(allChoose);
	butt = GameObject.Find(script_allChoose.propre("green")).GetComponent(infoButtons);

	ia_blue = difficulty_obj("blue");
	ia_red = difficulty_obj("red");
	ia_yellow = difficulty_obj("yellow");
}

function difficulty_obj(color : String)
{
	var ia : GameObject;
	
	ia = GameObject.Find("IA_" + color + "_easy");
	if (!ia)
	{
		ia = GameObject.Find("IA_" + color + "_normal");
		if (!ia)
			ia = GameObject.Find("IA_" + color + "_hard");
	}
	if (ia)
		return (ia);
	return (null);
}

function view (dec : GameObject, save : GameObject[], i : int) {
	var ht = dec.GetComponent(SpriteRenderer).sprite.rect.height;
	var wh = dec.GetComponent(SpriteRenderer).sprite.rect.width;
    var pos = script_allChoose.cam.camera.ScreenPointToRay(Input.mousePosition);
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

function fight_change_reserve (dec : GameObject, recup1 : String, recup2 : String, recup3 : String, nbordre : int, script : allInfo) {
	if (recup1 == "changedec") {
		if (recup3 == "soldier") {
			var val = view(dec, script.save_commando, 0);
			script_allChoose.kill_pion(val, script.save_commando, script.nbcommando);
			script.nbcommando--;
			script.nbsoldier += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
				recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
				script_allChoose.wait_ordre = 0;
				if (recup2 == dec.name && recup1 != "changedec" && recup1 != "reserve" && recup3 == "soldier")
					script_allChoose.exe_ordre(recup2, recup1, recup3, script);
				else
					script_allChoose.wait_ordre = 1;
				while (!script_allChoose.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3 == "raider") {
			val = view(dec, script.save_bomber, 0);
			script_allChoose.kill_pion(val, script.save_bomber, script.nbbomber);
			script.nbbomber--;
			script.nbraider += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
				recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
				script_allChoose.wait_ordre = 0;
				if (recup2 == dec.name && recup1 != "changedec" && recup1 != "reserve" && recup3 == "raider")
					script_allChoose.exe_ordre(recup2, recup1, recup3, script);
				else
					script_allChoose.wait_ordre = 1;
				while (!script_allChoose.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3 == "hunter") {
			val = view(dec, script.save_fighter, 0);
			script_allChoose.kill_pion(val, script.save_fighter, script.nbfighter);
			script.nbfighter--;
			script.nbhunter += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
				recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
				script_allChoose.wait_ordre = 0;
				if (recup2 == dec.name && recup1 != "changedec" && recup1 != "reserve" && recup3 == "hunter")
					script_allChoose.exe_ordre(recup2, recup1, recup3, script);
				else
					script_allChoose.wait_ordre = 1;
				while (!script_allChoose.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3 == "cruiser") {
			val = view(dec, script.save_destroyer, 0);
			script_allChoose.kill_pion(val, script.save_destroyer, script.nbdestroyer);
			script.nbdestroyer--;
			script.nbcruiser += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
				recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
				script_allChoose.wait_ordre = 0;
				if (recup2 == dec.name && recup1 != "changedec" && recup1 != "reserve" && recup3 == "cruiser")
					script_allChoose.exe_ordre(recup2, recup1, recup3, script);
				else
					script_allChoose.wait_ordre = 1;
				while (!script_allChoose.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3.IndexOf("h_bomb") != -1 && view(dec, script.save_hbomb, 0) > -1) {
			val = view(dec, script.save_hbomb, 0);
			script_allChoose.kill_pion(val, script.save_hbomb, script.nbhbomb);
			script.nbhbomb--;
			var tab : Array = recup3.Split("-"[0]);
			for (var tableau : String in tab) {
				if (tableau == "soldier")
					script.nbsoldier++;
				else if (tableau == "raider")
					script.nbraider++;
				else if (tableau == "hunter")
					script.nbhunter++;
				else if (tableau == "cruiser")
					script.nbcruiser++;
				else if (tableau == "commando")
					script.nbcommando++;
				else if (tableau == "bomber")
					script.nbbomber++;
				else if (tableau == "fighter")
					script.nbfighter++;
				else if (tableau == "destroyer")
					script.nbdestroyer++;
				else if (tableau == "force")
					script.force++;
			}
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetString("Orde" + nbordre + "depart");
				recup2 = PlayerPrefs.GetString("Orde" + nbordre + "arriver");
				var recup4 = PlayerPrefs.GetString("Orde" + nbordre + "piece");
				script_allChoose.wait_ordre = 0;
				if (recup2 == dec.name && recup1 != "changedec" && recup1 != "reserve") {
					if ((recup3.IndexOf("soldier") != -1 && recup4 == "soldier") || (recup3.IndexOf("raider") != -1 && recup4 == "raider")
						|| (recup3.IndexOf("hunter") != -1 && recup4 == "hunter") || (recup3.IndexOf("cruiser") != -1 && recup4 == "cruiser")
						|| (recup3.IndexOf("commando") != -1 && recup4 == "commando") || (recup3.IndexOf("bomber") != -1 && recup4 == "bomber")
						|| (recup3.IndexOf("fighter") != -1 && recup4 == "fighter") || (recup3.IndexOf("destroyer") != -1 && recup4 == "destroyer"))
						script_allChoose.exe_ordre(recup2, recup1, recup4, script);
				}
				else
					script_allChoose.wait_ordre = 1;
				while (!script_allChoose.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
	}
	else if (recup1 == "reserve") {
		if (recup3 == "soldier") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_soldier, 0);
			script_allChoose.kill_pion(val, script.save_soldier, script.nbsoldier);
			script.nbsoldier--;
			script.ressoldier++;
		}
		else if (recup3 == "raider") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_raider, 0);
			script_allChoose.kill_pion(val, script.save_raider, script.nbraider);
			script.nbraider--;
			script.resraider++;
		}
		else if (recup3 == "hunter") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_hunter, 0);
			script_allChoose.kill_pion(val, script.save_hunter, script.nbhunter);
			script.nbhunter--;
			script.reshunter++;
		}
		else if (recup3 == "cruiser") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_cruiser, 0);
			script_allChoose.kill_pion(val, script.save_cruiser, script.nbcruiser);
			script.nbcruiser--;
			script.rescruiser++;
		}
		else if (recup3 == "commando") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_commando, 0);
			script_allChoose.kill_pion(val, script.save_commando, script.nbcommando);
			script.nbcommando--;
			script.rescommando++;
		}
		else if (recup3 == "bomber") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_bomber, 0);
			script_allChoose.kill_pion(val, script.save_bomber, script.nbbomber);
			script.nbbomber--;
			script.resbomber++;
		}
		else if (recup3 == "fighter") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_fighter, 0);
			script_allChoose.kill_pion(val, script.save_fighter, script.nbfighter);
			script.nbfighter--;
			script.resfighter++;
		}
		else if (recup3 == "destroyer") {
			yield WaitForSeconds(0.1);
			val = view(dec, script.save_destroyer, 0);
			script_allChoose.kill_pion(val, script.save_destroyer, script.nbdestroyer);
			script.nbdestroyer--;
			script.resdestroyer++;
		}
	}
	script_allChoose.wait_change = 1;
}

function fight_eg_human(bdd_ordre : String, bdd_dep : String, bdd_arr : String, bdd_pie : String, dec : GameObject, script : allInfo)
{
	var nbordre : int = 0;

	if (script) {
		while (++nbordre < butt.ordre) {
			var recup1 = PlayerPrefs.GetString(bdd_ordre + nbordre + bdd_dep);
			var recup2 = PlayerPrefs.GetString(bdd_ordre + nbordre + bdd_arr);
			var recup3 = PlayerPrefs.GetString(bdd_ordre + nbordre + bdd_pie);
			script_allChoose.wait_ordre = 0;
			script_allChoose.wait_change = 0;
			if (recup2 == dec.name && recup1 != "changedec" && recup1 != "reserve") {
				script_allChoose.exe_ordre(recup2, recup1, recup3, script);
				script_allChoose.wait_change = 1;
			}
			else if (recup2 == dec.name && (recup1 == "changedec" || recup1 == "reserve")) {
				fight_change_reserve(dec, recup1, recup2, recup3, nbordre, script);
				script_allChoose.wait_ordre = 1;
			}
			else {
				script_allChoose.wait_change = 1;
				script_allChoose.wait_ordre = 1;
			}
			while (!script_allChoose.wait_ordre || !script_allChoose.wait_change)
				yield WaitForSeconds(1);
		}
	}
	script_allChoose.wait_egbis = 1;
}

function fightia_change_reserve (dec : GameObject, recup1 : int, recup2 : int, recup3 : String, nbordre : int, scriptname : String, bibli : Array, script : allInfo, valia : String) {
	if (scriptname == "blue")
		var scriptia : ScriptIA_blue = ia_blue.GetComponent(ScriptIA_blue);
	else if (scriptname == "red")
		var scriptred : ScriptIA_red = ia_red.GetComponent(ScriptIA_red);
	else if (scriptname == "yellow")
		var scriptyellow : ScriptIA_yellow = ia_yellow.GetComponent(ScriptIA_yellow);

	if (recup1 == 57) {
		if (recup3 == "soldier") {
			var val = scriptia.view1(dec, script.save_commando, 0);
			script_allChoose.kill_pion(val, script.save_commando, script.nbcommando);
			script.nbcommando--;
			script.nbsoldier += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup2 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + valia);
				scriptia.wait_ordre = 0;
				scriptred.wait_ordre = 0;
				scriptyellow.wait_ordre = 0;
				if (bibli[recup2] == dec.name && recup1 < 57 && recup3 == "soldier") {
					if (valia.IndexOf("ia1") != -1)
						scriptred.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia2") != -1)
						scriptyellow.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia") != -1)
						scriptia.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
				}
				else
					scriptia.wait_ordre = 1;
				while (!scriptia.wait_ordre && !scriptred.wait_ordre && !scriptyellow.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3 == "raider") {
			val = scriptia.view1(dec, script.save_bomber, 0);
			script_allChoose.kill_pion(val, script.save_bomber, script.nbbomber);
			script.nbbomber--;
			script.nbraider += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup2 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + valia);
				scriptia.wait_ordre = 0;
				scriptred.wait_ordre = 0;
				scriptyellow.wait_ordre = 0;
				if (bibli[recup2] == dec.name && recup1 < 57 && recup3 == "raider") {
					if (valia.IndexOf("ia1") != -1)
						scriptred.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia2") != -1)
						scriptyellow.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia") != -1)
						scriptia.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
				}
				else
					scriptia.wait_ordre = 1;
				while (!scriptia.wait_ordre && !scriptred.wait_ordre && !scriptyellow.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3 == "hunter") {
			val = scriptia.view1(dec, script.save_fighter, 0);
			script_allChoose.kill_pion(val, script.save_fighter, script.nbfighter);
			script.nbfighter--;
			script.nbhunter += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup2 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + valia);
				scriptia.wait_ordre = 0;
				scriptred.wait_ordre = 0;
				scriptyellow.wait_ordre = 0;
				if (bibli[recup2] == dec.name && recup1 < 57 && recup3 == "hunter") {
					if (valia.IndexOf("ia1") != -1)
						scriptred.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia2") != -1)
						scriptyellow.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia") != -1)
						scriptia.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
				}
				else
					scriptia.wait_ordre = 1;
				while (!scriptia.wait_ordre && !scriptred.wait_ordre && !scriptyellow.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
		else if (recup3 == "cruiser") {
			val = scriptia.view1(dec, script.save_destroyer, 0);
			script_allChoose.kill_pion(val, script.save_destroyer, script.nbdestroyer);
			script.nbdestroyer--;
			script.nbcruiser += 3;
			script.up_pion(dec);
			while (--nbordre > 0) {
				recup1 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup2 = PlayerPrefs.GetInt("Orde" + nbordre + valia);
				recup3 = PlayerPrefs.GetString("Orde" + nbordre + valia);
				scriptia.wait_ordre = 0;
				scriptred.wait_ordre = 0;
				scriptyellow.wait_ordre = 0;
				if (bibli[recup2] == dec.name && recup1 < 57 && recup3 == "cruiser") {
					if (valia.IndexOf("ia1") != -1)
						scriptred.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia2") != -1)
						scriptyellow.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
					else if (valia.IndexOf("ia") != -1)
						scriptia.exe_ordre1(bibli[recup2], bibli[recup1], recup3);
				}
				else
					scriptia.wait_ordre = 1;
				while (!scriptia.wait_ordre && !scriptred.wait_ordre && !scriptyellow.wait_ordre)
					yield WaitForSeconds(1);
			}
		}
	}
	else if (recup1 == 58) {
		if (recup3 == "soldier") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_soldier, 0);
			script_allChoose.kill_pion(val, script.save_soldier, script.nbsoldier);
			script.nbsoldier--;
			script.ressoldier++;
		}
		else if (recup3 == "raider") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_raider, 0);
			script_allChoose.kill_pion(val, script.save_raider, script.nbraider);
			script.nbraider--;
			script.resraider++;
		}
		else if (recup3 == "hunter") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_hunter, 0);
			script_allChoose.kill_pion(val, script.save_hunter, script.nbhunter);
			script.nbhunter--;
			script.reshunter++;
		}
		else if (recup3 == "cruiser") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_cruiser, 0);
			script_allChoose.kill_pion(val, script.save_cruiser, script.nbcruiser);
			script.nbcruiser--;
			script.rescruiser++;
		}
		else if (recup3 == "commando") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_commando, 0);
			script_allChoose.kill_pion(val, script.save_commando, script.nbcommando);
			script.nbcommando--;
			script.rescommando++;
		}
		else if (recup3 == "bomber") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_bomber, 0);
			script_allChoose.kill_pion(val, script.save_bomber, script.nbbomber);
			script.nbbomber--;
			script.resbomber++;
		}
		else if (recup3 == "fighter") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_fighter, 0);
			script_allChoose.kill_pion(val, script.save_fighter, script.nbfighter);
			script.nbfighter--;
			script.resfighter++;
		}
		else if (recup3 == "destroyer") {
			yield WaitForSeconds(0.1);
			val = scriptia.view1(dec, script.save_destroyer, 0);
			script_allChoose.kill_pion(val, script.save_destroyer, script.nbdestroyer);
			script.nbdestroyer--;
			script.resdestroyer++;
		}
	}
	script_allChoose.wait_change = 1;
}

function fight_eg_ia(scriptname : String, bdd_dep : String, bdd_arr : String, bdd_pie : String, dec : GameObject, biblidecor : Array, script1 : allInfo)
{
	var nbordre : int = 0;
	if (scriptname == "blue")
		var script : ScriptIA_blue = ia_blue.GetComponent(ScriptIA_blue);
	else if (scriptname == "red")
		var scriptred : ScriptIA_red = ia_red.GetComponent(ScriptIA_red);
	else if (scriptname == "yellow")
		var scriptyellow : ScriptIA_yellow = ia_yellow.GetComponent(ScriptIA_yellow);
	if (scriptname == "blue") {
		while (++nbordre < script.ordre) {
			var recup4 = PlayerPrefs.GetInt("Orde" + nbordre + bdd_dep);
			var recup5 = PlayerPrefs.GetInt("Orde" + nbordre + bdd_arr);
			var recup6 = PlayerPrefs.GetString("Orde" + nbordre + bdd_pie);
			script.wait_ordre = 0;
			script_allChoose.wait_change = 0;
			if (recup4 < 57 && biblidecor[recup5] == dec.name) {
				script.exe_ordre1(biblidecor[recup5], biblidecor[recup4], recup6);
				script_allChoose.wait_change = 1;
			}
			else if ((recup4 == 57 && recup5 != -1 && biblidecor[recup5] == dec.name)
				|| (recup4 == 58 && biblidecor[recup5] == dec.name)) {
				fightia_change_reserve(dec, recup4, recup5, recup6, nbordre, scriptname, biblidecor, script1, bdd_arr);
				script.wait_ordre = 1;
			}
			else {
				script_allChoose.wait_change = 1;
				script.wait_ordre = 1;
			}
			while (!script.wait_ordre || !script_allChoose.wait_change)
				yield WaitForSeconds(1);
		}
	}
	else if (scriptname == "red") {
		while (++nbordre < scriptred.ordre) {
			recup4 = PlayerPrefs.GetInt("Orde" + nbordre + bdd_dep);
			recup5 = PlayerPrefs.GetInt("Orde" + nbordre + bdd_arr);
			recup6 = PlayerPrefs.GetString("Orde" + nbordre + bdd_pie);
			scriptred.wait_ordre = 0;
			script_allChoose.wait_change = 0;
			if (recup4 < 57 && biblidecor[recup5] == dec.name) {
				scriptred.exe_ordre1(biblidecor[recup5], biblidecor[recup4], recup6);
				script_allChoose.wait_change = 1;
			}
			else if ((recup4 == 57 && recup5 != -1 && biblidecor[recup5] == dec.name)
				|| (recup4 == 58 && biblidecor[recup5] == dec.name)) {
				fightia_change_reserve(dec, recup4, recup5, recup6, nbordre, scriptname, biblidecor, script1, bdd_arr);
				scriptred.wait_ordre = 1;
			}
			else {
				script_allChoose.wait_change = 1;
				scriptred.wait_ordre = 1;
			}
			while (!scriptred.wait_ordre || !script_allChoose.wait_change)
				yield WaitForSeconds(1);
		}
	}
	else if (scriptname == "yellow") {
		while (++nbordre < scriptyellow.ordre) {
			recup4 = PlayerPrefs.GetInt("Orde" + nbordre + bdd_dep);
			recup5 = PlayerPrefs.GetInt("Orde" + nbordre + bdd_arr);
			recup6 = PlayerPrefs.GetString("Orde" + nbordre + bdd_pie);
			scriptyellow.wait_ordre = 0;
			script_allChoose.wait_change = 0;
			if (recup4 < 57 && biblidecor[recup5] == dec.name) {
				scriptyellow.exe_ordre1(biblidecor[recup5], biblidecor[recup4], recup6);
				script_allChoose.wait_change = 1;
			}
			else if ((recup4 == 57 && recup5 != -1 && biblidecor[recup5] == dec.name)
				|| (recup4 == 58 && biblidecor[recup5] == dec.name)) {
				fightia_change_reserve(dec, recup4, recup5, recup6, nbordre, scriptname, biblidecor, script1, bdd_arr);
				scriptyellow.wait_ordre = 1;
			}
			else {
				script_allChoose.wait_change = 1;
				scriptyellow.wait_ordre = 1;
			}
			while (!scriptyellow.wait_ordre || !script_allChoose.wait_change)
				yield WaitForSeconds(1);
		}
	}
	script_allChoose.wait_egbis = 1;
}

function fight_eg (dec : GameObject, script1 : allInfo, script2 : allInfo, script3 : allInfo, script4 : allInfo) {
	var nbordre : int = 0;

	GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(false, dec, -9);
	if (script1) {
		script_allChoose.wait_egbis = 0;
		fight_eg_human("Orde", "depart", "arriver", "piece", dec, script1);
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}

	if (script2 && Network.isServer) {
		script_allChoose.wait_egbis = 0;
		fight_eg_ia("blue", "departia", "arriveria", "pieceia", dec, script_bibli.biblidecor, script2);
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}
	else if (Network.isClient) {
		script_allChoose.wait_egbis = 0;
		fight_eg_human("Ordre", "départbleu", "arrivéebleue", "piècebleue", dec, script2);
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}
		
	if (script3 && Network.isServer) {
		script_allChoose.wait_egbis = 0;
		fight_eg_ia("red", "departia1", "arriveria1", "pieceia1", dec, script_bibli.biblidecor1, script3);
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}
	else if (Network.isClient) {
		script_allChoose.wait_egbis = 0;
		fight_eg_human("Ordre", "départrouge", "arrivéerouge", "piècerouge", dec, script3);
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}
	
	if (script4 && Network.isServer) {
		script_allChoose.wait_egbis = 0;
		fight_eg_ia("yellow", "departia2", "arriveria2", "pieceia2", dec, script_bibli.biblidecor2, script4);
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}
	else if (Network.isClient) {
		script_allChoose.wait_egbis = 0;
		fight_eg_human("Ordre", "départjaune", "arrivéejaune", "piècejaune", dec, script4);	
		while (!script_allChoose.wait_egbis)
			yield WaitForSeconds(1);
	}
	script_allChoose.wait_eg = 1;
}

function exe_fight_eg (scriptinfo : allInfo, scriptinfoblue : allInfo, scriptinfored : allInfo, scriptinfoyellow : allInfo) {
	var j : int = 1;
	var count : int = 0;
	var myforce : int;
	var force_blue : int;
	var force_yellow : int;
	var force_red : int;

	while (j) {
		j = 0;
		for (var dec : GameObject in GameObject.FindGameObjectsWithTag("Decor")) {
			myforce = script_allChoose.all_view(dec, scriptinfo, 0);
			force_blue = script_allChoose.all_view(dec, scriptinfoblue, 1);
			force_red = script_allChoose.all_view(dec, scriptinfored, 2);
			force_yellow = script_allChoose.all_view(dec, scriptinfoyellow, 3);
			count = script_allChoose.comp_force(myforce, force_blue, force_red, force_yellow);
			if (count > 0) {
				script_allChoose.wait_eg = 0;
				if (count == 11) {
					fight_eg(dec, scriptinfo, scriptinfoblue, null, null);
					j++;
				}
				else if (count == 21) {
					fight_eg(dec, scriptinfo, null, scriptinfored, null);
					j++;
				}
				else if (count == 41) {
					fight_eg(dec, scriptinfo, null, null, scriptinfoyellow);
					j++;
				}
				else if (count == 30) {
					fight_eg(dec, null, scriptinfoblue, scriptinfored, null);
					j++;
				}
				else if (count == 50) {
					fight_eg(dec, null, scriptinfoblue, null, scriptinfoyellow);
					j++;
				}
				else if (count == 60) {
					fight_eg(dec, null, null, scriptinfored, scriptinfoyellow);
					j++;
				}
				else if (count == 31) {
					fight_eg(dec, scriptinfo, scriptinfoblue, scriptinfored, null);
					j++;
				}
				else if (count == 51) {
					fight_eg(dec, scriptinfo, scriptinfoblue, null, scriptinfoyellow);
					j++;
				}
				else if (count == 61) {
					fight_eg(dec, scriptinfo, null, scriptinfored, scriptinfoyellow);
					j++;
				}
				else if (count == 70) {
					fight_eg(dec, null, scriptinfoblue, scriptinfored, scriptinfoyellow);
					j++;
				}
				else if (count == 71) {
					fight_eg(dec, scriptinfo, scriptinfoblue, scriptinfored, scriptinfoyellow);
					j++;
				}
				else {
					Debug.LogWarning("error");
					j = 0;
					script_allChoose.wait_eg = 1;
				}
				while (!script_allChoose.wait_eg)
					yield WaitForSeconds(1);
			}
		}
	}
	script_allChoose.wait_sup = 1;
}

function exe_fight (script1 : allInfo, script2 : allInfo, script3 : allInfo, script4 : allInfo) {
	script_allChoose.wait_sup = 0;
	exe_fight_eg(script1, script2, script3, script4);
	while (!script_allChoose.wait_sup)
		yield WaitForSeconds(1);
	script_allChoose.exe_fight_sup();
	script_allChoose.wait_fight = 1;
}
