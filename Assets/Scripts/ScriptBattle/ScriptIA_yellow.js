var cam : GameObject;
var ordre : int = 1;

private var decor : GameObject[];
private var move : GameObject[];

private var scripttest : Biblidecor;
private var scriptchoose : allChoose;
private var scriptinfo1 : allInfo;
private var scriptinfo2 : allInfo;
private var scriptinfo3 : allInfo;
private var scriptinfo4 : allInfo;

private var hbombready : int = 0;

var wait_ordre : int = 0;
var wait_exe : int = 0;

var hunterforce = 5;
var raiderforce = 3; // L'objet permet peut etre une autre facon de voir les choses
var soldierforce = 2;
var cruiserforce = 10;
var fighterforce = 25;
var bomberforce = 30;
var commandoforce = 20;
var destroyerforce = 50;

function collect_force () {
	var val : int;

	val = 0;
	if (scriptinfo4.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Plains_NW" || dec.name == "Plains_N" || dec.name == "Plains_NE" || dec.name == "Plains_W"
				|| dec.name == "Plains_C" || dec.name == "Plains_E" || dec.name == "Plains_SW" || dec.name == "Plains_S"
				|| dec.name == "Plains_SE") && !val) {
				val = view1(dec, scriptinfo1.save_soldier, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_raider, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_hunter, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_cruiser, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_commando, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_bomber, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_fighter, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_destroyer, 1);
			}
		}
		if (val)
			scriptinfo1.force++;
	}
	val = 0;
	if (scriptinfo2.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Jungle_NW" || dec.name == "Jungle_N" || dec.name == "Jungle_NE" || dec.name == "Jungle_W"
				|| dec.name == "Jungle_C" || dec.name == "Jungle_E" || dec.name == "Jungle_SW" || dec.name == "Jungle_S"
				|| dec.name == "Jungle_SE") && !val) {
				val = view1(dec, scriptinfo1.save_soldier, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_raider, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_hunter, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_cruiser, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_commando, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_bomber, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_fighter, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_destroyer, 1);
			}
		}
		if (val)
			scriptinfo1.force++;
	}
	val = 0;
	if (scriptinfo3.isalive) {
		for (var dec : GameObject in decor) {
			if ((dec.name == "Ice_NW" || dec.name == "Ice_N" || dec.name == "Ice_NE" || dec.name == "Ice_W" || dec.name == "Ice_C"
				|| dec.name == "Ice_E" || dec.name == "Ice_SW" || dec.name == "Ice_S" || dec.name == "Ice_SE") && !val) {
				val = view1(dec, scriptinfo1.save_soldier, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_raider, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_hunter, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_cruiser, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_commando, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_bomber, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_fighter, 1);
				if (!val)
					val = view1(dec, scriptinfo1.save_destroyer, 1);
			}
		}
		if (val)
			scriptinfo1.force++;
	}
}

function view1(dec : GameObject, save : GameObject[], i : int) {
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

function kill_pion (val : int, save : GameObject[], number : int) {
	var count : int;

	if (val > -1) {
		if (val == (number - 1)) {
			Destroy(save[val], 0);
			save[val] = null;
		}
		else if (val != (number - 1)) {
			count = -1;
			while (++count < number - 1) {
				if (count >= val)
					save[count].transform.position = save[count + 1].transform.position;
			}
			Destroy(save[count], 0);
			save[count] = null;
		}
	}
}

function feuille_ordre1 (depart : int, arriver : int, piece) {
	PlayerPrefs.SetInt("Orde" + ordre + "departia2", depart);
	PlayerPrefs.SetInt("Orde" + ordre + "arriveria2", arriver);
	PlayerPrefs.SetString("Orde" + ordre + "pieceia2", piece);
	ordre++;
}

function exe_ordre_h_bomb (depart : String, arriver : String, piece : String, script : allInfo) {
	if (depart.IndexOf("change") != -1) {
		if (depart == "changedec") {
			for (var dec : GameObject in decor) {
				if (dec.name == arriver) {
					var tab : Array = piece.Split("-"[0]);
					for (var tableau : String in tab) {
						if (tableau == "soldier") {
							var val = view1(dec, script.save_soldier, 0);
							kill_pion(val, script.save_soldier, script.nbsoldier);
							script.nbsoldier--;
						}
						else if (tableau == "raider") {
							val = view1(dec, script.save_raider, 0);
							kill_pion(val, script.save_raider, script.nbraider);
							script.nbraider--;
						}
						else if (tableau == "hunter") {
							val = view1(dec, script.save_hunter, 0);
							kill_pion(val, script.save_hunter, script.nbhunter);
							script.nbhunter--;
						}
						else if (tableau == "cruiser") {
							val = view1(dec, script.save_cruiser, 0);
							kill_pion(val, script.save_cruiser, script.nbcruiser);
							script.nbcruiser--;
						}
						else if (tableau == "commando") {
							val = view1(dec, script.save_commando, 0);
							kill_pion(val, script.save_commando, script.nbcommando);
							script.nbcommando--;
						}
						else if (tableau == "bomber") {
							val = view1(dec, script.save_bomber, 0);
							kill_pion(val, script.save_bomber, script.nbbomber);
							script.nbbomber--;
						}
						else if (tableau == "fighter") {
							val = view1(dec, script.save_fighter, 0);
							kill_pion(val, script.save_fighter, script.nbfighter);
							script.nbfighter--;
						}
						else if (tableau == "destroyer") {
							val = view1(dec, script.save_destroyer, 0);
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
					val = view1(dec, script.save_hbomb, 0);
					kill_pion(val, script.save_hbomb, script.nbhbomb);
					script.nbhbomb--;
				}
			}
		}
		if (arriver.IndexOf("blue") != -1)
			scriptchoose.kill_reserve(script);
		else if (arriver.IndexOf("red") != -1)
			scriptchoose.kill_reserve(script);
		else if (arriver.IndexOf("yellow") != -1)
			scriptchoose.kill_reserve(script);
		else if (arriver.IndexOf("green") != -1)
			scriptchoose.kill_reserve(script);
	}
	else if (depart == "reserve") {
		script.reshbomb--;
		for (var dec : GameObject in decor) {
			if (dec.name == arriver) {
				scriptchoose.kill_all_pion(dec);
				GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(true, dec, -4);
			}
		}
	}
	else {
		for (var dec : GameObject in decor) {
			if (dec.name == depart) {
				for (var mov : GameObject in decor) {
					if (mov.name == arriver) {
						val = view1(dec, script.save_hbomb, 0);
						kill_pion(val, script.save_hbomb, script.nbhbomb);
						script.nbhbomb--;
						scriptchoose.kill_all_pion(mov);
						GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).fight(true, mov, -4);
					}
				}
			}
		}
	}
	wait_ordre = 1;
}

function exe_ordre2 (piece, arrivee) {
	var count : int;
	count = -1;
	for (var dec : GameObject in decor) {
		if (dec.name == arrivee) {
			if (piece == "soldier") {
				while (++count < 3) {
					var val = view1(dec, scriptinfo1.save_soldier, 0);
					kill_pion(val, scriptinfo1.save_soldier, scriptinfo1.nbsoldier);
					scriptinfo1.nbsoldier--;
				}
				scriptinfo1.nbcommando++;
				scriptinfo1.up_pion(dec);
			}
			else if (piece == "raider") {
				while (++count < 3) {
					val = view1(dec, scriptinfo1.save_raider, 0);
					kill_pion(val, scriptinfo1.save_raider, scriptinfo1.nbraider);
					scriptinfo1.nbraider--;
				}
				scriptinfo1.nbbomber++;
				scriptinfo1.up_pion(dec);
			}
			else if (piece == "hunter") {
				while (++count < 3) {
					val = view1(dec, scriptinfo1.save_hunter, 0);
					kill_pion(val, scriptinfo1.save_hunter, scriptinfo1.nbhunter);
					scriptinfo1.nbhunter--;
				}
				scriptinfo1.nbfighter++;
				scriptinfo1.up_pion(dec);
			}
			else if (piece == "cruiser") {
				while (++count < 3) {
					val = view1(dec, scriptinfo1.save_cruiser, 0);
					kill_pion(val, scriptinfo1.save_cruiser, scriptinfo1.nbcruiser);
					scriptinfo1.nbcruiser--;
				}
				scriptinfo1.nbdestroyer++;
				scriptinfo1.up_pion(dec);
			}
			GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).change(piece, dec, scriptinfo1); // 
		}
	}
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

function exe_ordre1 (depart, arriver, piece) {
 //Debug.LogWarning("dep : " + depart + " arriver : " + arriver + " soldat : " + piece);
	for (var dec : GameObject in decor) {
		if (dec.name == depart) {
			for (var mov : GameObject in decor) {
				if (mov.name == arriver) {
					if (piece == "soldier") {
						var val = view1(dec, scriptinfo1.save_soldier, 0);
						if (val > -1)
							movement(scriptinfo1.save_soldier[val], mov.transform.position.x - 0.75, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "raider") {
						val = view1(dec, scriptinfo1.save_raider, 0);
						if (val > -1)
							movement(scriptinfo1.save_raider[val], mov.transform.position.x + 0.75, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "cruiser") {
						val = view1(dec, scriptinfo1.save_cruiser, 0);
						if (val > -1)
							movement(scriptinfo1.save_cruiser[val], mov.transform.position.x - 0.25, mov.transform.position.y + 0.25);
						else
							wait_ordre = 1;
					}
					else if (piece == "hunter") {
						val = view1(dec, scriptinfo1.save_hunter, 0);
						if (val > -1)
							movement(scriptinfo1.save_hunter[val], mov.transform.position.x - 0.75, mov.transform.position.y - 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "commando") {
						val = view1(dec, scriptinfo1.save_commando, 0);
						if (val > -1)
							movement(scriptinfo1.save_commando[val], mov.transform.position.x - 0.25, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "bomber") {
						val = view1(dec, scriptinfo1.save_bomber, 0);
						if (val > -1)
							movement(scriptinfo1.save_bomber[val], mov.transform.position.x + 0.25, mov.transform.position.y + 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "fighter") {
						val = view1(dec, scriptinfo1.save_fighter, 0);
						if (val > -1)
							movement(scriptinfo1.save_fighter[val], mov.transform.position.x + 0.75, mov.transform.position.y - 0.75);
						else
							wait_ordre = 1;
					}
					else if (piece == "destroyer") {
						val = view1(dec, scriptinfo1.save_destroyer, 0);
						if (val > -1)
							movement(scriptinfo1.save_destroyer[val], mov.transform.position.x + 0.25, mov.transform.position.y + 0.25);
						else
							wait_ordre = 1;
					}
				}
			}
		}
	}
}

function exe_ordre (depart : int, piece) {
	if (depart == 57) {
		if (piece == "soldier" && scriptinfo1.force) {
			scriptinfo1.ressoldier += 1;
			scriptinfo1.force -= 2;
		}
		else if (piece == "raider" && scriptinfo1.force) {
			scriptinfo1.resraider += 1;
			scriptinfo1.force -= 3;
		}
		else if (piece == "cruiser" && scriptinfo1.force) {
			scriptinfo1.rescruiser += 1;
			scriptinfo1.force -= 10;
		}
		else if (piece == "hunter" && scriptinfo1.force) {
			scriptinfo1.reshunter += 1;
			scriptinfo1.force -= 5;
		}
		else if (piece == "commando" && scriptinfo1.ressoldier) {
			scriptinfo1.rescommando += 1;
			scriptinfo1.ressoldier -= 3;
		}
		else if (piece == "bomber" && scriptinfo1.resraider) {
			scriptinfo1.resbomber += 1;
			scriptinfo1.resraider -= 3;
		}
		else if (piece == "fighter" && scriptinfo1.reshunter) {
			scriptinfo1.resfighter += 1;
			scriptinfo1.reshunter -= 3;
		}
		else if (piece == "destroyer" && scriptinfo1.rescruiser) {
			scriptinfo1.resdestroyer += 1;
			scriptinfo1.rescruiser -= 3;
		}
	}
	else if (depart == 58) {
		if (piece == "soldier" && scriptinfo1.ressoldier) {
			scriptinfo1.ressoldier -= 1;
			scriptinfo1.nbsoldier += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "raider" && scriptinfo1.resraider) {
			scriptinfo1.resraider -= 1;
			scriptinfo1.nbraider += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "cruiser" && scriptinfo1.rescruiser) {
			scriptinfo1.rescruiser -= 1;
			scriptinfo1.nbcruiser += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "hunter" && scriptinfo1.reshunter) {
			scriptinfo1.reshunter -= 1;
			scriptinfo1.nbhunter += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "commando" && scriptinfo1.rescommando) {
			scriptinfo1.rescommando -= 1;
			scriptinfo1.nbcommando += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "bomber" && scriptinfo1.resbomber) {
			scriptinfo1.resbomber -= 1;
			scriptinfo1.nbbomber += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "fighter" && scriptinfo1.resfighter) {
			scriptinfo1.resfighter -= 1;
			scriptinfo1.nbfighter += 1;
			scriptinfo1.up_pion(null);
		}
		else if (piece == "destroyer" && scriptinfo1.resdestroyer) {
			scriptinfo1.resdestroyer -= 1;
			scriptinfo1.nbdestroyer += 1;
			scriptinfo1.up_pion(null);
		}
	}
}

function dep_hunter (playerzone : int) {
	if (playerzone == 0) { // Ici vrai test playerzone == couleur de l'ia
//		onehunterhome = 1;
		var coords : int = Random.Range(0, 3);
		if (coords == 0)
			coords = 3;
		else if (coords == 1) // C'est dégueulasse mais pour l'instant j'ai pas mieux
			coords = 7;
		else if (coords == 2)
			coords = 9;
		feuille_ordre1(0, coords, "hunter"); // 0 is representng the Hq
	} 
	else {
		if (playerzone == 30)
			coords = 1;
		else {
			coords = Random.Range(0, 2); // Les seules coordonnées de déplacement possible
			if (coords == 0)
					coords = 1;
			else {
				if (playerzone == 10)
					coords = 7;
				else
					coords = 3;
			}
		}
		feuille_ordre1(0, playerzone + coords, "hunter"); // premier ordre
	}
}

function difficulty()
{
	if (this.name.IndexOf("easy") != -1)
		return (2);
	if (this.name.IndexOf("normal") != -1)
		return (6);
	if (this.name.IndexOf("hard") != -1)
		return (9);	
	return(6);
}

function exe_all_ordre () {
	var nbordre : int;
	nbordre = 0;
	wait_exe = 0;
	while (++nbordre < ordre) {
		var recup1 = PlayerPrefs.GetInt("Orde" + nbordre + "departia2");
		var recup2 = PlayerPrefs.GetInt("Orde" + nbordre + "arriveria2");
		var recup3 = PlayerPrefs.GetString("Orde" + nbordre + "pieceia2");
		wait_ordre = 0;
		if (recup1 < 57 && hbombready == 0)
			exe_ordre1(scripttest.biblidecor2[recup1], scripttest.biblidecor2[recup2], recup3);
		else
		{
			if (recup1 == 57 && recup2 != -1 && hbombready == 0)
				exe_ordre2(recup3, scripttest.biblidecor2[recup2]);
			else if (hbombready && recup1 != 57){
				exe_ordre_h_bomb(scripttest.biblidecor2[recup1], scripttest.biblidecor2[recup2], recup3, scriptinfo1);
				Debug.LogWarning("ben ques que tu fais");//
				Debug.LogWarning(scripttest.biblidecor2[recup1]);//
				Debug.LogWarning(scripttest.biblidecor2[recup2]);//
				Debug.LogWarning(recup3);//
				hbombready = 0;
			}
			else if (hbombready && recup1 == 57){
				exe_ordre_h_bomb("changedec", scripttest.biblidecor2[recup2], recup3, scriptinfo1);
				Debug.LogWarning(scripttest.biblidecor2[recup2]);//
				Debug.LogWarning("ben alors");//
				Debug.LogWarning( recup3);//
				Debug.LogWarning("ben alors");//
			}
			else
				exe_ordre(recup1, recup3);
			wait_ordre = 1;
		}
		while (!wait_ordre)
			yield WaitForSeconds(1);
	}
	wait_exe = 1;
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

function recup_ordre () 
{
	if (Application.loadedLevelName == "Battleground")
	{
		decor = GameObject.FindGameObjectsWithTag("Decor");
		move = GameObject.FindGameObjectsWithTag("Move");
		scripttest = GameObject.Find("Main Camera").GetComponent(Biblidecor);
		scriptchoose = GameObject.Find("0 - Decor").GetComponent(allChoose);
		scriptinfo1 = GameObject.Find(propre("yellow")).GetComponent(allInfo); // IA de reference ordre blue red yellow green
		scriptinfo2 = GameObject.Find(propre("red")).GetComponent(allInfo);// Donc scriptinfo 1 -> script de l ia 
		scriptinfo3 = GameObject.Find(propre("blue")).GetComponent(allInfo);
		scriptinfo4 = GameObject.Find(propre("green")).GetComponent(allInfo); // Script info 1 zone 0 etc a optimiser plus tard
		if (scriptchoose.round2 == 1 && scriptchoose.ia == scriptchoose.round2) // est-ce le premier round
		{
			var coords = 0;
			var onehunterhome = 0;
			var LevelStrenght = difficulty();
			var playerzone = Random.Range(0, 4);
			var reverse = 10 - LevelStrenght;
			var random = Random.Range(0, 11);
			if (random <= reverse)
				playerzone = 0;
			else if (random > reverse && playerzone == 0)
				playerzone = Random.Range(1, 4);
			playerzone *= 10;
			dep_hunter(playerzone);
			random = Random.Range(0, 11);
			if (random <= reverse)
				playerzone = 0;
			else
			{
				random = Random.Range(0, 11);
				if (random <= LevelStrenght / 2 + 4)
				{
					var playerzone2 = Random.Range(1, 4);
					while (playerzone2 == playerzone)
						playerzone2 = Random.Range(1, 4);
					playerzone = playerzone2 * 10;	
				}
			}
			dep_hunter(playerzone);
			coords = Random.Range(0, 3);
			if (coords == 0)
				coords = 3;
			else if (coords == 1)
				coords = 7;
			else if (coords == 2)
				coords = 9;
			feuille_ordre1(0, coords, "raider");    // troisieme ordre
			feuille_ordre1(0, coords, "raider");    // quatrieme ordre
			coords = Random.Range(0, 3);
			if (coords == 0)
				coords = 49;
			else if (coords == 2)
				coords = 50;
			feuille_ordre1(0, coords, "cruiser");    // cinquieme ordre			

			//execution des ordres
			scriptchoose.round2++;
		}
		if (scriptchoose.round2 != 1 && scriptchoose.ia == scriptchoose.round2) // est-ce le premier round
		{
			var count : int;
			var noennemies : int; 
			var iamode : int;
			var nbhunters0 : int;
			var nbraiders0 : int;
			var nbsoldiers0 : int;
			var nbcruisers0 : int;
			var nbfighters0 : int;
			var nbbombers0 : int;
			var nbcommandos0 : int;
			var nbdestroyers0 : int;
			var nbhunters1 : int;
			var nbraiders1 : int;
			var nbsoldiers1 : int;
			var nbcruisers1 : int;
			var nbfighters1 : int;
			var nbbombers1 : int;
			var nbcommandos1 : int;
			var nbdestroyers1 : int;
			var nbhunters2 : int;
			var nbraiders2 : int;
			var nbsoldiers2 : int;
			var nbcruisers2 : int;
			var nbfighters2 : int;
			var nbbombers2 : int;
			var nbcommandos2 : int;
			var nbdestroyers2 : int;
			var nbhunters3 : int;
			var nbraiders3 : int;
			var nbsoldiers3 : int;
			var nbcruisers3 : int;
			var nbfighters3 : int;
			var nbbombers3 : int;
			var nbcommandos3 : int;
			var nbdestroyers3 : int;
			var forces0 : int;
			var totalforces0 : int;
			var totalforces1 : int;
			var totalforces2 : int;
			var totalforces3 : int;
			var reshunters0 : int;
			var resraiders0 : int;
			var ressoldiers0 : int;
			var rescruisers0 : int;
			var resfighters0 : int;
			var resbombers0 : int;
			var rescommandos0 : int;
			var resdestroyers0 : int;
			var reshunters1 : int;
			var resraiders1 : int;
			var ressoldiers1 : int;
			var rescruisers1 : int;
			var resfighters1 : int;
			var resbombers1 : int;
			var rescommandos1 : int;
			var resdestroyers1 : int;
			var reshunters2 : int;
			var resraiders2 : int;
			var ressoldiers2 : int;
			var rescruisers2 : int;
			var resfighters2 : int;
			var resbombers2 : int;
			var rescommandos2 : int;
			var resdestroyers2 : int;
			var reshunters3 : int;
			var resraiders3 : int;
			var ressoldiers3 : int;
			var rescruisers3 : int;
			var resfighters3 : int;
			var resbombers3 : int;
			var rescommandos3 : int;
			var resdestroyers3 : int;
			var res0 : int;
			var res1 : int;
			var res2 : int;
			var res3 : int;
			var diff : float;
			LevelStrenght = difficulty();
			diff = 3/2;
			count = 0;
			noennemies = 0;
			iamode = 1;
			while (count < 57) // Ne surtout pas oublier count == 0 count == 10  count == 20
			{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								var name : GameObject = dec;
						}
						if ((view1(name, scriptinfo2.save_soldier, 0) == -1) && (view1(name, scriptinfo2.save_commando, 0) == -1) && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies++;// On englobe pas tte la condition sinon signifie que si count > 10 && view1 existe est aussi vrai
						}
						if ((view1(name, scriptinfo3.save_soldier, 0) == -1) && (view1(name, scriptinfo3.save_commando, 0) == -1) && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies++;
						}
						if ((view1(name, scriptinfo4.save_soldier, 0) == -1) && (view1(name, scriptinfo4.save_commando, 0) == -1) && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies++;
						}
						if (noennemies == 39)
							iamode = 1;
						count++;// et compter directement l'equivalent évolué de trois pièces
			}
			count = 0;
			while (count < 57) // Ne surtout pas oublier count == 0 count == 10  count == 20
			{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						} 
						nbhunters0 += view1(name, scriptinfo1.save_hunter, 1);
						nbraiders0 += view1(name, scriptinfo1.save_raider, 1);
						nbsoldiers0 += view1(name, scriptinfo1.save_soldier, 1);
						nbcruisers0 += view1(name, scriptinfo1.save_cruiser, 1);
						nbfighters0 += view1(name, scriptinfo1.save_fighter, 1);
						nbbombers0 += view1(name, scriptinfo1.save_bomber, 1);
						nbcommandos0 += view1(name, scriptinfo1.save_commando, 1);
						nbdestroyers0 += view1(name, scriptinfo1.save_destroyer, 1);
						nbhunters1 += view1(name, scriptinfo2.save_hunter, 1);
						nbraiders1 += view1(name, scriptinfo2.save_raider, 1);
						nbsoldiers1 += view1(name, scriptinfo2.save_soldier, 1);
						nbcruisers1 += view1(name, scriptinfo2.save_cruiser, 1);
						nbfighters1 += view1(name, scriptinfo2.save_fighter, 1);
						nbbombers1 += view1(name, scriptinfo2.save_bomber, 1);
						nbcommandos1 += view1(name, scriptinfo2.save_commando, 1);
						nbdestroyers1 += view1(name, scriptinfo2.save_destroyer, 1);
						nbhunters2 += view1(name, scriptinfo3.save_hunter, 1);
						nbraiders2 += view1(name, scriptinfo3.save_raider, 1);
						nbsoldiers2 += view1(name, scriptinfo3.save_soldier, 1);
						nbcruisers2 += view1(name, scriptinfo3.save_cruiser, 1);
						nbfighters2 += view1(name, scriptinfo3.save_fighter, 1);
						nbbombers2 += view1(name, scriptinfo3.save_bomber, 1);
						nbcommandos2 += view1(name, scriptinfo3.save_commando, 1);
						nbdestroyers2 += view1(name, scriptinfo3.save_destroyer, 1);
						nbhunters3 += view1(name, scriptinfo4.save_hunter, 1);
						nbraiders3 += view1(name, scriptinfo4.save_raider, 1);
						nbsoldiers3 += view1(name, scriptinfo4.save_soldier, 1);
						nbcruisers3 += view1(name, scriptinfo4.save_cruiser, 1);
						nbfighters3 += view1(name, scriptinfo4.save_fighter, 1);
						nbbombers3 += view1(name, scriptinfo4.save_bomber, 1);
						nbcommandos3 += view1(name, scriptinfo4.save_commando, 1);
						nbdestroyers3 += view1(name, scriptinfo4.save_destroyer, 1);
						count++;// et compter directement l'equivalent évolué de trois pièces
			}
			forces0 = scriptinfo1.force;
			reshunters0 = scriptinfo1.reshunter;
			resraiders0 = scriptinfo1.resraider;
			ressoldiers0 = scriptinfo1.ressoldier;
			rescruisers0 = scriptinfo1.rescruiser;
			resfighters0 = scriptinfo1.resfighter;
			resbombers0 = scriptinfo1.resbomber;
			rescommandos0 = scriptinfo1.rescommando;
			resdestroyers0 = scriptinfo1.resdestroyer;
			reshunters1 = scriptinfo2.reshunter;
			resraiders1 = scriptinfo2.resraider;
			ressoldiers1 = scriptinfo2.ressoldier;
			rescruisers1 = scriptinfo2.rescruiser;
			resfighters1 = scriptinfo2.resfighter;
			resbombers1 = scriptinfo2.resbomber;
			rescommandos1 = scriptinfo2.rescommando;
			resdestroyers1 = scriptinfo2.resdestroyer;
			reshunters2 = scriptinfo3.reshunter;
			resraiders2 = scriptinfo3.resraider;
			ressoldiers2 = scriptinfo3.ressoldier;
			rescruisers2 = scriptinfo3.rescruiser;
			resfighters2 = scriptinfo3.resfighter;
			resbombers2 = scriptinfo3.resbomber;
			rescommandos2 = scriptinfo3.rescommando;
			resdestroyers2 = scriptinfo3.resdestroyer;
			reshunters3 = scriptinfo4.reshunter;
			resraiders3 = scriptinfo4.resraider;
			ressoldiers3 = scriptinfo4.ressoldier;
			rescruisers3 = scriptinfo4.rescruiser;
			resfighters3 = scriptinfo4.resfighter;
			resbombers3 = scriptinfo4.resbomber;
			rescommandos3 = scriptinfo4.rescommando;
			resdestroyers3 = scriptinfo4.resdestroyer;
			if (reshunters1 >= 3)
			{
				reshunters1 -= reshunters1 / 3 * 3;
				resfighters1 += reshunters1 / 3;
			}
			if (reshunters2 >= 3)
			{
				reshunters2 -= reshunters2 / 3 * 3;
				resfighters2 += reshunters2 / 3;
			}
			if (reshunters3 >= 3)
			{
				reshunters3 -= reshunters3 / 3 * 3;
				resfighters3 += reshunters3 / 3;
			}
			if (resraiders1 >= 3)
			{
				resraiders1 -= resraiders1 / 3 * 3;
				resbombers1 += resraiders1 / 3;
			}
			if (resraiders2 >= 3)
			{
				reshunters2 -= reshunters2 / 3 * 3;
				resbombers2 += reshunters2 / 3;
			}
			if (resraiders3 >= 3)
			{
				reshunters3 -= reshunters3 / 3 * 3;
				resbombers3 += reshunters3 / 3;
			}
			if (ressoldiers1 >= 3)
			{
				reshunters1 -= reshunters1 / 3 * 3;
				rescommandos1 += reshunters1 / 3;
			}
			if (ressoldiers2 >= 3)
			{
				reshunters2 -= reshunters2 / 3 * 3;
				rescommandos2 += reshunters2 / 3;
			}
			if (ressoldiers3 >= 3)
			{
				reshunters3 -= reshunters3 / 3 * 3;
				rescommandos3 += reshunters3 / 3;
			}
			if (rescruisers1 >= 3)
			{
				reshunters1 -= reshunters1 / 3 * 3;
				resdestroyers1 += reshunters1 / 3;
			}
			if (rescruisers2 >= 3)
			{
				reshunters2 -= reshunters2 / 3 * 3;
				resdestroyers2 += reshunters2 / 3;
			}
			if (rescruisers3 >= 3)
			{
				reshunters3 -= reshunters3 / 3 * 3;
				resdestroyers3 += reshunters3 / 3;
			}
			res0 = reshunters0 * hunterforce + resraiders0 * raiderforce + ressoldiers0 * soldierforce + rescruisers0 * cruiserforce
					+ resfighters0 * fighterforce + resbombers0 * bomberforce + rescommandos0 * commandoforce + resdestroyers0 * destroyerforce;
			res1 = reshunters1 * hunterforce + resraiders1 * raiderforce + ressoldiers1 * soldierforce + rescruisers1 * cruiserforce
					+ resfighters1 * fighterforce + resbombers1 * bomberforce + rescommandos1 * commandoforce + resdestroyers1 * destroyerforce;
			res2 = reshunters2 * hunterforce + resraiders2 * raiderforce + ressoldiers2 * soldierforce + rescruisers2 * cruiserforce
					+ resfighters2 * fighterforce + resbombers2 * bomberforce + rescommandos2 * commandoforce + resdestroyers2 * destroyerforce;
			res3 = reshunters3 * hunterforce + resraiders3 * raiderforce + ressoldiers3 * soldierforce + rescruisers3 * cruiserforce
					+ resfighters3 * fighterforce + resbombers3 * bomberforce + rescommandos3 * commandoforce + resdestroyers3 * destroyerforce;
			// A Rajouter zau forces présentes dans la réserve // Conditions de ponte: 2 3 5 forces ou plus et/ou deux pieces identiques sur le plateau
			/*nbhunters0 = scriptinfo1.save_hunter.length; // toutes les forces presentes sur le plateau
			nbraiders0 = scriptinfo1.save_raider.length;
			nbsoldiers0 = scriptinfo1.save_soldier.length;
			nbcruisers0 = scriptinfo1.save_cruiser.length;
			nbfighters0 = scriptinfo1.save_fighter.length;
			nbbombers0 = scriptinfo1.save_bomber.length;
			nbcommandos0 = scriptinfo1.save_commando.length;
			nbdestroyers0 = scriptinfo1.save_destroyer.length;
			nbhunters1 = scriptinfo2.save_hunter.length;
			nbraiders1 = scriptinfo2.save_raider.length;
			nbsoldiers1 = scriptinfo2.save_soldier.length;
			nbcruisers1 = scriptinfo2.save_cruiser.length;
			nbfighters1 = scriptinfo2.save_fighter.length;
			nbbombers1 = scriptinfo2.save_bomber.length;
			nbcommandos1 = scriptinfo2.save_commando.length;
			nbdestroyers1 = scriptinfo2.save_destroyer.length;
			nbhunters2 = scriptinfo3.save_hunter.length;
			nbraiders2 = scriptinfo3.save_raider.length;
			nbsoldiers2 = scriptinfo3.save_soldier.length;
			nbcruisers2 = scriptinfo3.save_cruiser.length;
			nbfighters2 = scriptinfo3.save_fighter.length;
			nbbombers2 = scriptinfo3.save_bomber.length;
			nbcommandos2 = scriptinfo3.save_commando.length;
			nbdestroyers2 = scriptinfo3.save_destroyer.length;
			nbhunters3 = scriptinfo4.save_hunter.length;
			nbraiders3 = scriptinfo4.save_raider.length;
			nbsoldiers3 = scriptinfo4.save_soldier.length;// Si deux soldats en plateau ET char d'assaut deja existant
			nbcruisers3 = scriptinfo4.save_cruiser.length;//compte reserves//Si power >= 2 et 2 soldats en plateau alors tel chance den faire, si >= 3 etc
			nbfighters3 = scriptinfo4.save_fighter.length;
			nbbombers3 = scriptinfo4.save_bomber.length;
			nbcommandos3 = scriptinfo4.save_commando.length;
			nbdestroyers3 = scriptinfo4.save_destroyer.length;*/
			totalforces0 = nbhunters0 * hunterforce + nbraiders0 * raiderforce + nbsoldiers0 * soldierforce + nbcruisers0 * cruiserforce
							+ nbfighters0 * fighterforce + nbbombers0 * bomberforce + nbcommandos0 * commandoforce + nbdestroyers0 * destroyerforce;
			totalforces1 = nbhunters1 * hunterforce + nbraiders1 * raiderforce + nbsoldiers1 * soldierforce + nbcruisers1 * cruiserforce
							+ nbfighters1 * fighterforce + nbbombers1 * bomberforce + nbcommandos1 * commandoforce + nbdestroyers1 * destroyerforce;
			totalforces2 = nbhunters2 * hunterforce + nbraiders2 * raiderforce + nbsoldiers2 * soldierforce + nbcruisers2 * cruiserforce
							+ nbfighters2 * fighterforce + nbbombers2 * bomberforce + nbcommandos2 * commandoforce + nbdestroyers2 * destroyerforce;
			totalforces3 = nbhunters3 * hunterforce + nbraiders3 * raiderforce + nbsoldiers3 * soldierforce + nbcruisers3 * cruiserforce
							+ nbfighters3 * fighterforce + nbbombers3 * bomberforce + nbcommandos3 * commandoforce + nbdestroyers3 * destroyerforce;
			if ((totalforces0 >= totalforces1 * diff && totalforces1 != 0) || (totalforces0 >= totalforces2 * diff && totalforces2 != 0) || (totalforces0 >= totalforces3 * diff && totalforces3 != 0))// diff a retravailler par
			{// rapport au LevelSTrenght mais aussi parceque plus bas un adversaire avec moins de différence peut-être attaqué.
				random = Random.Range(0, 11);
				if (random <= LevelStrenght)// l autre condition est en plus probablement la présence d'un char d'assault dans le HQ
					iamode = 2;
			}
			count = 0;
			noennemies = 0;
			while (count < 57) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			{
				for (var dec : GameObject in decor) {
					if (dec.name == scripttest.biblidecor2[count])
						name = dec;
				}
				if ((view1(name, scriptinfo2.save_soldier, 0) > -1 || view1(name, scriptinfo2.save_commando, 0) > -1) && (count < 10 || (count >= 40 && count <= 42)))
				{
					noennemies--;
				}
				if ((view1(name, scriptinfo3.save_soldier, 0) > -1 || view1(name, scriptinfo3.save_commando, 0) > -1) && (count < 10 || (count >= 40 && count <= 42)))
				{
					noennemies--;
				}
				if ((view1(name, scriptinfo4.save_soldier, 0) > -1 || view1(name, scriptinfo4.save_commando, 0) > -1) && (count < 10 || (count >= 40 && count <= 42)))
				{
					noennemies--;
				}
				if (noennemies < 0 || nbhunters0 >= 3 || nbraiders0 >= 3 || nbsoldiers0 >= 3 || nbcruisers0 >= 3) // Gerer une priorite du mode 0 ou mode 2 selon le LevelStrength
				{
					random = Random.Range(0, 11);
					if (random <= LevelStrenght)
						iamode = 0;
				}
				count++;
			}
	//		 coords = 0;
	//		 LevelStrenght = 9; // 2 - easy 6 - medium 9 - hard
	//		 playerzone = Random.Range(0, 4);
	//		 reverse = 10 - LevelStrenght;
	//		 random = Random.Range(0, 11);
			// 1 - Neutral 0 - Defensive 2 - Offensive
			/* Vérification du total des powers de chaque equipe dans hq, reserve et plateau
			Je dois donc pouvoir savoir , par ex bool qui repond true ou false si telle piece est sur le plateau ou en reserve ou sur le hq
			Soit 4 variables pour hq, 4 variables pour reserve puis les comparer entr elles   // etude du round 2

			en clair : priorité : si j'ai 2 hunter dans mon hq et un sur le plateau je cree un bombardier sur le hq
			option de moindre probabilite: j envoie mes deux chasseurs ailleurs
			option de moindre probabilite j envoie chaque chasseur continuer de recolter des powers
			Ceci est valable pour toutes les pieces
			pour les powers : minimum 3 ou 5 // medium pour augmenter ses chances de les echanger, sinon a 2
			une faible chance d amener ses raiders sur l ile du milieu
			// pas obligé de changer des powers en pièces et d amener ca au HQ de suite

			Si Bombardier dans le Hq le deplacer chez l'adversaire  // etude du round 3
			Une chance de bouger le croiseur ou de le laisser sur place
			une faible chance de bouger ses raiders de l ile du milieu vers les autres camps

			Premiere condition de déplacement des soldats: Un char d'assaut dans le HQ  // etude du round 4
			deplacement au centre de l'île char d'assault + soldats

			  // etude du round 5
			aleas de deplacement des troupes + char dassaut entre les deux cases qui permettent d aller sur l une des deux iles mitoyennes
			du camp a prendre d assaut, celui dont la somme de"s forces sur le plateau est incapable d assurer une defense equivalente a celle
			de l'attaquant .
			C'est donc tres clair qu il y a ici une condition de mode " attaque " ou, des qu un char d assaut est present dans le hq et les forces
			en mesure d envahir l adversaire, la priorite est d abord l avancee du char et des autres pieces.

			//etude du round 6
			Ne donner l assaut que si l on est sur que nos forces surpassent l adversaire, autre probabilité: continuer des déplacements normaux

			//etude du round 7
			Escorte du char d assaut par un destroyer en plus, bouger le bombardier mais rester a portee du hq.
			La presence d un soldat adverse sur une des 3 iles mitoyyennes va augmenter les chances de repli.
			En cas de repli la priorite des ordres va etre ici, contrairement au mode attaque, le retour des unités à la base.
			//etude du round 8
			avance d une case par une case pour suivre l escorte avec le destroyer // prioritaire
			//etude du round 9


			Se détache ici une facon de coder, verification de certaines cases else toutes les autres. Si cette case est occupée par un
			adversaire avec tel soldat mode defensif. Si cette case est occupée par moi tel vaisseau mode offensif.
			Réglage des priorités.


			je pense que le cas de figures de forces a portée d autre forces va quand meme devoir etre étudié.

			//etude round 10
			Laisser les gros croiseurs sur le hq au debut

			IL EST IMPORTANT de mettre le flag d une zone dont le joueur a perdu à 0.

			//etude round 11
			L'ia est definitivement une succession de conditions de cas généraux.

			//etude round 12
			S il n y est a plusque 3 joueurs la probabilité d amener toute la reserve dans le HQ est maximale

			//round 13
			Diminuer les probabilités d occuper une case accessible par des forces supérieures
			//round 14
			Prise de risque sur des probabilités peut etre un tout petit peu plus faibles
			Quand il ne reste que 3 joueurs augmenter les chances de porter l assaut par l ile du milieu pour semer le doute dans 
			l esprit des joueurs

			A ce stade: des conditions sont prealablement verifiees pour creer une priorite d ordres :
			pouvoir valider la nature d une unite presente sur une case, le nombre total de forces cumulees presentes sur la-dîte case,
			savoir si ce sont des pieces a soi ou adverses et savoir les forces potentiellement capables d atteindre cette case AU PROCHAIN TOUR//

			Je pense vérification du mode offensif ou défensif dans certains déplacements par rapport aux cases exemple : case centre ile, retour ou offensive

			//round 15 - 16 - 17 - 18 - 19 - 20 

			//round 21

			Important : si le joueur est en mode attaque, il va declencher une bombe sur le qg que s il joue en dernier et que le soldat est a deux cases du hq
			Ou bien il la joue dans tous les cas si l armee adverse est deja sur le hq.
			S'il est en mode défense, il ne cree une bombe que s'il joue en premier forte chance, faible chance s il joue en dernier, sachant que s'il joue premier
			le choix d atterrissage de la bombe n est pas random: c sur le gros paquet qui se trouve a deux cases ou moins du hq a defendre.

			//round 22 - 23 - 24 - 25 - 26 - 27

			

			*/
			// Rappel : priorite sur le compte des reserves pour rameuter le matériel au HQ
			
			var orders = 0;// Compter au début les réserves le hq etle plateau pour chaque force
			if (forces0 >= 10)//début des forces
			{
				random = Random.Range(0, 11);
				if (random < LevelStrenght)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, -1, "cruiser");
					forces0 -= 10;
					orders++;
					rescruisers0 += 1;
				}
			}
			if (forces0 >= 5)
			{
				random = Random.Range(0, 11);
				if (random < LevelStrenght)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, -1, "hunter");
					forces0 -= 5;
					orders++;
					reshunters0 += 1;
				}
			}
			if (forces0 >= 3)
			{
				random = Random.Range(0, 11);
				if (random < LevelStrenght)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, -1, "raider");
					forces0 -= 3;
					orders++;
					resraiders0 += 1;
				}
			}
			if (forces0 >= 2)
			{
				random = Random.Range(0, 11);
				if (random > LevelStrenght)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, -1, "soldier");
					forces0 -= 2;
					orders++;
					ressoldiers0 += 1;
				}
			}
			if (resraiders0 >= 3)// Evolutions
			{
				yield WaitForSeconds(0.1);
				resraiders0 -= 3;
				resbombers0 += 1;
				feuille_ordre1(57, -1, "bomber");
				orders++;
			}
			else
			{
				if (resraiders0 == 2)
				{
					if (nbraiders0 == 1 || nbraiders0 == 2)
					{
						while (resraiders0 > 0)
						{
							yield WaitForSeconds(0.1);
							resraiders0--;
							feuille_ordre1(58, 0, "raider");
							orders++;
						}
					}
				}
				if (resraiders0 == 1)
				{
					if (nbraiders0 == 2)
					{
						while (resraiders0 > 0)
						{
							yield WaitForSeconds(0.1);
							resraiders0--;
							feuille_ordre1(58, 0, "raider");
							orders++;
						}
					}
				}
			}
			if (reshunters0 >= 3)
			{
				yield WaitForSeconds(0.1);
				reshunters0 -= 3;
				resfighters0 += 1;
				feuille_ordre1(57, -1, "fighter");
				orders++;
			}
			else
			{
				if (reshunters0 == 2)
				{
					if (nbhunters0 == 1 || nbhunters0 == 2)
					{
						while (reshunters0 > 0)
						{
							yield WaitForSeconds(0.1);
							reshunters0--;
							feuille_ordre1(58, 0, "hunter");
							orders++;
						}
					}
				}
				if (reshunters0 == 1)
				{
					if (nbhunters0 == 2)
					{
						while (reshunters0 > 0)
						{
							yield WaitForSeconds(0.1);
							reshunters0--;
							feuille_ordre1(58, 0, "hunter");
							orders++;
						}
					}
				}
			}
			if (ressoldiers0 >= 3)
			{
				yield WaitForSeconds(0.1);
				ressoldiers0 -= 3;
				rescommandos0 += 1;
				feuille_ordre1(57, -1, "commando");
				orders++;
			}
			else
			{
				if (ressoldiers0 == 2)
				{
					if (nbsoldiers0 == 1 || nbsoldiers0 == 2)
					{
						while (ressoldiers0 > 0)
						{
							yield WaitForSeconds(0.1);
							ressoldiers0--;
							feuille_ordre1(58, 0, "soldier");
							orders++;
						}
					}
				}
				if (ressoldiers0 == 1)
				{
					if (nbsoldiers0 == 2)
					{
						while (ressoldiers0 > 0)
						{
							yield WaitForSeconds(0.1);
							ressoldiers0--;
							feuille_ordre1(58, 0, "soldier");
							orders++;
						}
					}
				}
			}
			if (rescruisers0 >= 3)
			{
				yield WaitForSeconds(0.1);
				rescruisers0 -= 3;
				resdestroyers0 += 1;
				feuille_ordre1(57, -1, "destroyer");
				orders++;
			}
			else
			{
				if (rescruisers0 == 2)
				{
					if (nbcruisers0 == 1 || nbcruisers0 == 2)
					{
						while (rescruisers0 > 0)
						{
							yield WaitForSeconds(0.1);
							rescruisers0--;
							feuille_ordre1(58, 0, "cruiser");
							orders++;
						}
					}
				}
				if (rescruisers0 == 1)
				{
					if (nbcruisers0 == 2)
					{
						while (rescruisers0 > 0)
						{
							yield WaitForSeconds(0.1);
							rescruisers0--;
							feuille_ordre1(58, 0, "cruiser");
							orders++;
						}
					}
				}
			}
			while (resbombers0 >= 1)
			{
				yield WaitForSeconds(0.1);
				resbombers0--;
				feuille_ordre1(58, 0, "bomber");
				orders++;
			}
			while (resfighters0 >= 1)
			{
				yield WaitForSeconds(0.1);
				resfighters0--;
				feuille_ordre1(58, 0, "fighter");
				orders++;
			}
			while (rescommandos0 >= 1)
			{
				yield WaitForSeconds(0.1);
				rescommandos0--;
				feuille_ordre1(58, 0, "commando");
				orders++;
			}
			while (resdestroyers0 >= 1)
			{
				yield WaitForSeconds(0.1);
				resdestroyers0--;
				feuille_ordre1(58, 0, "destroyer");
				orders++;
			}
			count = 0;
			while (count < 57 && orders < 5){
				for (var dec : GameObject in decor){
					if (dec.name == scripttest.biblidecor2[count])
						name = dec;
				}
				if (view1(name, scriptinfo1.save_cruiser, 1) >= 3)
				{
					yield WaitForSeconds(0.1);// Apparemment indispensable
					feuille_ordre1(57, count, "cruiser");
					orders++;
				}
				if (view1(name, scriptinfo1.save_hunter, 1) >= 3)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, count, "hunter");
					orders++;
				}
				if (view1(name, scriptinfo1.save_raider, 1) >= 3)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, count, "raider");
					orders++;
				}
				if (view1(name, scriptinfo1.save_soldier, 1) >= 3)
				{
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, count, "soldier");
					orders++;
				}
				count++;
			}
			
			var bomb = 0;
			var combopieces : String;
			var tempfighter = 0;
			var tempbomber = 0;
			var tempcommando = 0;
			var tempdestroyer = 0;
			var conteure = 0;
			count = 0;
			while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20
			{
				bomb = 0;
				for (var dec : GameObject in decor) {
					if (dec.name == scripttest.biblidecor2[count])
						name = dec;
				}
				bomb = view1(name, scriptinfo1.save_hunter, 1) * hunterforce + view1(name, scriptinfo1.save_raider, 1) * raiderforce +
						view1(name, scriptinfo1.save_soldier, 1) * soldierforce + view1(name, scriptinfo1.save_cruiser, 1) * cruiserforce +
						view1(name, scriptinfo1.save_fighter, 1) * fighterforce + view1(name, scriptinfo1.save_bomber, 1) * bomberforce +
						view1(name, scriptinfo1.save_commando, 1) * commandoforce + view1(name, scriptinfo1.save_destroyer, 1) * destroyerforce;
				if (bomb >= 100)
				{
					tempfighter = view1(name, scriptinfo1.save_fighter, 1);
					tempbomber = view1(name, scriptinfo1.save_bomber, 1);
					tempcommando = view1(name, scriptinfo1.save_commando, 1);
					tempdestroyer = view1(name, scriptinfo1.save_destroyer, 1);
					while (tempdestroyer > 0){
						combopieces += "destroyer-";
						tempdestroyer--;
						conteure++;
					}
					while (tempbomber > 0){
						combopieces += "bomber-";
						tempbomber--;
						conteure++;
					}
					while (tempfighter > 0){
						combopieces += "fighter-";
						tempfighter--;
						conteure++;
					}
					while (tempcommando > 0){
						combopieces += "commando-";
						tempcommando--;
						conteure++;
					}
					yield WaitForSeconds(0.1);
					feuille_ordre1(57, count, combopieces);
					hbombready = 1;
					orders++;
					break;
				}
				count++; 
			}
			count = 0;
			while (count < 57 && orders < 5)
			{
				for (var dec : GameObject in decor) {
					if (dec.name == scripttest.biblidecor2[count])
							name = dec;
				}
				if (view1(name, scriptinfo1.save_hbomb, 0) > -1){
					yield WaitForSeconds(0.1);
					feuille_ordre1(count, Random.Range(0, 7), "boumdantaggle");
					orders++;
					break ;
				}
				count++;
			}
			coords = 0;//Truc supermassif mais en fait : 3 modes, et 3 ia dans chaque mode dont le seul changement est le tableau biblidecor2 utilise
			random = 0;
			if (iamode == 0){// Bases: LevelStrenght influence les probabilités de déplacement, iamode est influencé par la détection des forces.
					count = 0;
					while (count < 51)
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (count < 10 || count == 11 || count == 17 || count == 31 || count == 23 || count == 21){
						nbhunters0 += view1(name, scriptinfo1.save_hunter, 1); // toutes les forces qui menacent le hq 0 celles qui peuvent proteger ++ Réserves
						nbhunters1 += view1(name, scriptinfo2.save_hunter, 1);
						nbhunters2 += view1(name, scriptinfo3.save_hunter, 1);
						nbhunters3 += view1(name, scriptinfo4.save_hunter, 1);
						nbfighters0 += view1(name, scriptinfo1.save_fighter, 1);
						nbfighters1 += view1(name, scriptinfo2.save_fighter, 1);
						nbfighters2 += view1(name, scriptinfo3.save_fighter, 1);
						nbfighters3 += view1(name, scriptinfo4.save_fighter, 1);
						}
						if (count < 10){
						nbraiders0 += view1(name, scriptinfo1.save_raider, 1);
						nbraiders1 += view1(name, scriptinfo2.save_raider, 1);
						nbraiders2 += view1(name, scriptinfo3.save_raider, 1);
						nbraiders3 += view1(name, scriptinfo4.save_raider, 1);
						nbbombers0 += view1(name, scriptinfo1.save_bomber, 1);
						nbbombers1 += view1(name, scriptinfo2.save_bomber, 1);
						nbbombers2 += view1(name, scriptinfo3.save_bomber, 1);
						nbbombers3 += view1(name, scriptinfo4.save_bomber, 1);
						}
						if (count < 3 || count == 4 || count == 5){
						nbsoldiers0 += view1(name, scriptinfo1.save_soldier, 1);
						nbsoldiers1 += view1(name, scriptinfo2.save_soldier, 1);
						nbsoldiers2 += view1(name, scriptinfo3.save_soldier, 1);
						nbsoldiers3 += view1(name, scriptinfo4.save_soldier, 1);
						nbcommandos0 += view1(name, scriptinfo1.save_commando, 1);
						nbcommandos1 += view1(name, scriptinfo2.save_commando, 1);
						nbcommandos2 += view1(name, scriptinfo3.save_commando, 1);
						nbcommandos3 += view1(name, scriptinfo4.save_commando, 1);
						}
						if (count == 1 || count == 49 || count == 50){
						nbcruisers0 += view1(name, scriptinfo1.save_cruiser, 1);
						nbcruisers1 += view1(name, scriptinfo2.save_cruiser, 1);
						nbcruisers2 += view1(name, scriptinfo3.save_cruiser, 1);
						nbcruisers3 += view1(name, scriptinfo4.save_cruiser, 1);
						nbdestroyers0 += view1(name, scriptinfo1.save_destroyer, 1);
						nbdestroyers1 += view1(name, scriptinfo2.save_destroyer, 1);
						nbdestroyers2 += view1(name, scriptinfo3.save_destroyer, 1);
						nbdestroyers3 += view1(name, scriptinfo4.save_destroyer, 1);
						}
						count++;
					}
					totalforces0 = nbhunters0 * hunterforce + nbraiders0 * raiderforce + nbsoldiers0 * soldierforce + nbcruisers0 * cruiserforce
									+ nbfighters0 * fighterforce + nbbombers0 * bomberforce + nbcommandos0 * commandoforce + nbdestroyers0 * destroyerforce;
					totalforces1 = nbhunters1 * hunterforce + nbraiders1 * raiderforce + nbsoldiers1 * soldierforce + nbcruisers1 * cruiserforce
									+ nbfighters1 * fighterforce + nbbombers1 * bomberforce + nbcommandos1 * commandoforce + nbdestroyers1 * destroyerforce;
					totalforces2 = nbhunters2 * hunterforce + nbraiders2 * raiderforce + nbsoldiers2 * soldierforce + nbcruisers2 * cruiserforce
									+ nbfighters2 * fighterforce + nbbombers2 * bomberforce + nbcommandos2 * commandoforce + nbdestroyers2 * destroyerforce;
					totalforces3 = nbhunters3 * hunterforce + nbraiders3 * raiderforce + nbsoldiers3 * soldierforce + nbcruisers3 * cruiserforce
									+ nbfighters3 * fighterforce + nbbombers3 * bomberforce + nbcommandos3 * commandoforce + nbdestroyers3 * destroyerforce;
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
					/*	if (view1(name, scriptinfo2.save_soldier, 0) == -1 && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies++;// On englobe pas tte la condition sinon signifie que si count > 10 && view1 existe est aussi vrai
						}
						if (view1(name, scriptinfo3.save_soldier, 0) == -1 && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies++;
						}
						if (view1(name, scriptinfo4.save_soldier, 0) == -1 && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies++;
						}
						if (noennemies == 39)
							iamode = 1;*/
						if (view1(name, scriptinfo1.save_bomber, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									//if (count == 10)   // A voir si le cas est ce mon unite ou non est traité
									coords = 41;
								}
								else if (count >= 20 && count < 30)
								{
									//if (count == 20)
									coords = 41;
								}
								else if (count >= 30 && count < 40)
								{
									//if (count == 30)
									coords = 41;
								}
									
							}
							else if (count >= 40)
							{
								if (count == 41 || count == 40 || count == 42)
									coords = 1;
								else if (count == 43 || count == 44)
								{
									if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
								}
							}
							else
							{
								coords = 0;
							}
							if (count != 0){
							yield WaitForSeconds(0.1);														
							feuille_ordre1(count, coords, "bomber");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_fighter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11 || count == 17)
									{
										random = Random.Range(0, 7);
										coords = random;
									}									// Mouvement de repli car on est en zero
									else if (count == 14 || count == 12 || count == 15 || count == 18)
									{
										random = Random.Range(1, 7);
										coords = random;
									}
									else if (count == 16 || count == 19 || count == 13)
									{
										random = Random.Range(5, 7);
										coords = random;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21 || count == 23)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(0, 7);
										coords = random;
									}
									else if (count == 22 || count == 24 || count == 25 || count == 26)
									{
										random = Random.Range(1, 7);
										coords = random;
									}
									else if (count == 27 || count == 28 || count == 29)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 5;
										else
											coords = 8;
									}

								}
								else if (count >= 30 && count < 40)
								{
									if (count == 35 || count == 32 || count == 34)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(1, 7);
										coords = random;
									}
									else if (count == 31)
									{
										coords = 0;
									}
									else if (count == 33 || count == 36 || count == 37 || count == 38 || count == 39)
									{
										random = Random.Range(5, 9);
										if (random == 7)
											coords = 9;
										else
											coords = random;
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count == 1 || count == 2 || count == 4 || count == 5)
									coords = 0;
								else if (count == 3 || count == 6)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
								}
								else if (count == 7 || count == 8)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
									else if (random == 2)
										coords = 5;
								}
								else if (count == 9)
									coords = 5;
							}
							if (count != 0){
							yield WaitForSeconds(0.1);												
							feuille_ordre1(count, coords, "fighter");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_commando, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 15)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(0, 2);
										coords = random + 40;
									}
									else if (count == 11 || count == 14 || count == 12)
									{
										coords = 40;
									}
									else if (count == 13 || count == 16)
									{
										random = Random.Range(0, 3);
										if (random == 0)
											coords = 11;
										if (random == 1)
											coords = 14;
										else
											coords = 17;
									}
									else // A revoir
									{
										coords = 11;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 25 || count == 22)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(1, 3);
										coords = random + 40;
									}
									else if (count == 21 || count == 24)
									{
										coords = 42;
									}
									else if (count == 23 || count == 26)
									{
										coords = 41;
									}
									else
									{
										random = Random.Range(0, 3);
										if (random == 0)
											coords = 21;
										if (random == 1)
											coords = 22;
										else
											coords = 23;
									}

								}
								else if (count >= 30 && count < 40)
								{
									if (count == 35 || count == 32)									// Mouvement de repli car on est en zero
									{
										coords = 41;
									}
									else if (count == 31 || count == 34)
									{
										coords = 41;
									}
									else if (count == 33 || count == 36)
									{
										random = Random.Range(0, 3);
										if (random == 0)
											coords = 31;
										if (random == 1)
											coords = 32;
										else
											coords = 34;
									}
									else
									{
										coords = 31;
									}

								}
							}
							else if (count >= 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}
							else
							{
								if (count == 1 || count == 2 || count == 4 || count == 5)
									coords = 0;
								else if (count == 3 || count == 6)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
								}
								else if (count == 7 || count == 8)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
									else if (random == 2)
										coords = 5;
								}
								else if (count == 9)
									coords = 5;
							}
							if (count != 0){
							yield WaitForSeconds(0.1);
							feuille_ordre1(count, coords, "commando");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_destroyer, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 40;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 46;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 50;
								}
								else if (count == 41)
								{
									coords = 9;
								}
								else if (count == 42)
								{
									coords = 49;
								}
								else if (count == 43)

								{
									coords = 53;// donc on va en 53 et pas 46 le bateau est le seul qui va falloir modifier pour les couleurs
								}
								else if (count == 44)
								{
									coords = 47;	
								}
								else if (count == 45)
								{
									coords = 40;
								}
								else if (count == 46)
								{
									coords = 41;
								}
								else if (count == 47)
								{
									coords = 41;
								}
								else if (count == 48)
								{
									coords = 43;// bien reconnaitre ce type derreur: ici on etait emmené en 41 par 48 qui nous amenait en 9 qui nous
								}// rrramenait en 48 car il ne faut pas oublier qu'en position relative, le 48 du bleu est le 45 du vert.
								else if (count == 49)
								{
									coords = 0;
								}
								else if (count == 50)
								{
									coords = 0;
								}
								else if (count == 51)
								{
									coords = 40;
								}
								else if (count == 52)
								{
									coords = 13;
								}
								else if (count == 53)
								{
									coords = 43;
								}
								else if (count == 54)
								{
									coords = 47;
								}
								else if (count == 55)
								{
									coords = 27;
								}
								else if (count == 56)
								{
									coords = 49;
								}
								
							}
							else
							{
								if (count == 1)
								{
									coords = 0;
								}
								else if (count == 2)
								{
									coords = 1;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 49;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 49;
								}
								else if (count == 8)
								{
									coords = 7;
								}
								else if (count == 9)
								{
									coords = 48;
								}
							}
							if (count != 0){
							yield WaitForSeconds(0.1);												
							feuille_ordre1(count, coords, "destroyer");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_hunter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11 || count == 17)
									{
										random = Random.Range(0, 7);
										coords = random;
									}									// Mouvement de repli car on est en zero
									else if (count == 14 || count == 12 || count == 15 || count == 18)
									{
										random = Random.Range(1, 7);
										coords = random;
									}
									else if (count == 16 || count == 19 || count == 13)
									{
										random = Random.Range(5, 7);
										coords = random;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21 || count == 23)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(0, 7);
										coords = random;
									}
									else if (count == 22 || count == 24 || count == 25 || count == 26)
									{
										random = Random.Range(1, 7);
										coords = random;
									}
									else if (count == 27 || count == 28 || count == 29)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 5;
										else
											coords = 8;
									}

								}
								else if (count >= 30 && count < 40)
								{
									if (count == 35 || count == 32 || count == 34)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(1, 7);
										coords = random;
									}
									else if (count == 31)
									{
										coords = 0;
									}
									else if (count == 33 || count == 36 || count == 37 || count == 38 || count == 39)
									{
										random = Random.Range(5, 9);
										if (random == 7)
											coords = 9;
										else
											coords = random;
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count == 1 || count == 2 || count == 4 || count == 5)
									coords = 0;
								else if (count == 3 || count == 6)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
								}
								else if (count == 7 || count == 8)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
									else if (random == 2)
										coords = 5;
								}
								else if (count == 9)
									coords = 5;
							}
							if (count != 0){
							yield WaitForSeconds(0.1);												
							feuille_ordre1(count, coords, "hunter");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_raider, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									//if (count == 10)   // A voir si le cas est ce mon unite ou non est traité
									coords = 41;
								}
								else if (count >= 20 && count < 30)
								{
									//if (count == 20)
									coords = 41;
								}
								else if (count >= 30 && count < 40)
								{
									//if (count == 30)
									coords = 41;
								}
									
							}
							else if (count >= 40)
							{
								if (count == 41 || count == 40 || count == 42)
									coords = 1;
								else if (count == 43 || count == 44)
								{
									if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
								}
							}
							else
							{
								coords = 0;
							}
							if (count != 0){
							yield WaitForSeconds(0.1);														
							feuille_ordre1(count, coords, "raider");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_soldier, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 15)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(0, 2);
										coords = random + 40;
									}
									else if (count == 11 || count == 14 || count == 12)
									{
										coords = 40;
									}
									else if (count == 13 || count == 16)
									{
										random = Random.Range(0, 3);
										if (random == 0)
											coords = 11;
										if (random == 1)
											coords = 14;
										else
											coords = 17;
									}
									else // A revoir
									{
										coords = 11;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 25 || count == 22)									// Mouvement de repli car on est en zero
									{
										random = Random.Range(1, 3);
										coords = random + 40;
									}
									else if (count == 21 || count == 24)
									{
										coords = 42;
									}
									else if (count == 23 || count == 26)
									{
										coords = 41;
									}
									else
									{
										random = Random.Range(0, 3);
										if (random == 0)
											coords = 21;
										if (random == 1)
											coords = 22;
										else
											coords = 23;
									}

								}
								else if (count >= 30 && count < 40)
								{
									if (count == 35 || count == 32)									// Mouvement de repli car on est en zero
									{
										coords = 41;
									}
									else if (count == 31 || count == 34)
									{
										coords = 41;
									}
									else if (count == 33 || count == 36)
									{
										random = Random.Range(0, 3);
										if (random == 0)
											coords = 31;
										if (random == 1)
											coords = 32;
										else
											coords = 34;
									}
									else
									{
										coords = 31;
									}

								}
							}
							else if (count >= 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}
							else
							{
								if (count == 1 || count == 2 || count == 4 || count == 5)
									coords = 0;
								else if (count == 3 || count == 6)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
								}
								else if (count == 7 || count == 8)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										coords = 4;
									else if (random == 2)
										coords = 5;
								}
								else if (count == 9)
									coords = 5;
							}
							if (count != 0){
							yield WaitForSeconds(0.1);												
							feuille_ordre1(count, coords, "soldier");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_cruiser, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 40;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 46;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 50;
								}
								else if (count == 41)
								{
									coords = 9;
								}
								else if (count == 42)
								{
									coords = 49;
								}
								else if (count == 43)
								{
									coords = 46;
								}
								else if (count == 44)
								{
									coords = 47;	
								}
								else if (count == 45)
								{
									coords = 40;
								}
								else if (count == 46)
								{
									coords = 41;
								}
								else if (count == 47)
								{
									coords = 41;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									coords = 0;
								}
								else if (count == 50)
								{
									coords = 0;
								}
								else if (count == 51)
								{
									coords = 40;
								}
								else if (count == 52)
								{
									coords = 13;
								}
								else if (count == 53)
								{
									coords = 43;
								}
								else if (count == 54)
								{
									coords = 47;
								}
								else if (count == 55)
								{
									coords = 27;
								}
								else if (count == 56)
								{
									coords = 49;
								}
								
							}
							else
							{
								if (count == 1)
								{
									coords = 0;
								}
								else if (count == 2)
								{
									coords = 1;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 49;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 49;
								}
								else if (count == 8)
								{
									coords = 7;
								}
								else if (count == 9)
								{
									coords = 48;
								}
							}
							if (count != 0){
							yield WaitForSeconds(0.1);														
							feuille_ordre1(count, coords, "cruiser");
							orders++;
							}
						}
						count++;
					}

			} // Ordre de deroulement : compte des armees ennemies, verification de passage en mode 1 ou 2, reserve puis ordres
			// si le random conduit a la case identique a celle de depart orders--  
			else if (iamode == 1){ // Si l'on veut bouger plusieurs pieces d'un meme type peut etre rappeler la fonction en fin de condition au lieu dune boucle while
					count = 0;
			/*		noennemies = 0;
					nbhunters0 = scriptinfo1.save_hunter.length; // toutes les forces presentes sur le plateau
					nbraiders0 = scriptinfo1.save_raider.length;
					nbsoldiers0 = scriptinfo1.save_soldier.length;
					nbcruisers0 = scriptinfo1.save_cruiser.length;
					nbhunters1 = scriptinfo2.save_hunter.length;
					nbraiders1 = scriptinfo2.save_raider.length;
					nbsoldiers1 = scriptinfo2.save_soldier.length;
					nbcruisers1 = scriptinfo2.save_cruiser.length;
					nbhunters2 = scriptinfo3.save_hunter.length;
					nbraiders2 = scriptinfo3.save_raider.length;
					nbsoldiers2 = scriptinfo3.save_soldier.length;
					nbcruisers2 = scriptinfo3.save_cruiser.length;
					nbhunters3 = scriptinfo4.save_hunter.length;
					nbraiders3 = scriptinfo4.save_raider.length;
					nbsoldiers3 = scriptinfo4.save_soldier.length;
					nbcruisers3 = scriptinfo4.save_cruiser.length;
					totalforces0 = nbhunters0 * hunterforce + nbraiders0 * raiderforce + nbsoldiers0 * soldierforce + nbcruisers0 * cruiserforce;
					totalforces1 = nbhunters1 * hunterforce + nbraiders1 * raiderforce + nbsoldiers1 * soldierforce + nbcruisers1 * cruiserforce;
					totalforces2 = nbhunters2 * hunterforce + nbraiders2 * raiderforce + nbsoldiers2 * soldierforce + nbcruisers2 * cruiserforce;
					totalforces3 = nbhunters3 * hunterforce + nbraiders3 * raiderforce + nbsoldiers3 * soldierforce + nbcruisers3 * cruiserforce;
					if (totalforces0 > totalforces1 || totalforces0 > totalforces2 || totalforces0 > totalforces3)
						iamode = 2;*/
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}/*
						if (view1(name, scriptinfo2.save_soldier, 0) > -1 && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies--;
						}
						if (view1(name, scriptinfo3.save_soldier, 0) > -1 && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies--;
						}
						if (view1(name, scriptinfo4.save_soldier, 0) > -1 && (count < 10 || (count >= 40 && count <= 42)))
						{
							noennemies--;
						}
						if (noennemies < 0) // Gerer une priorite du mode 0 ou mode 2 selon le LevelStrength
							iamode = 0;*/
						if (view1(name, scriptinfo1.save_bomber, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									random = Random.Range(10, 20);
									if (random == count || random == 10)
									{
										coords = count;
										orders--;
									}
									else
										coords = random;
								}
								else if (count >= 20 && count < 30)
								{
									random = Random.Range(20, 30);
									if (random == count || random == 20)
									{
										coords = count;
										orders--;
									}
									else
										coords = random;
								}
								else if (count >= 30 && count < 40)
								{
									random = Random.Range(30, 40);
									if (random == count || random == 30)
									{
										coords = count;
										orders--;// de placement sur les iles fonction des rapports de force des bases ennemies
									}
									else
										coords = random;
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(10, 40);
									if (random == 10 || random == 20 || random == 30)
									{
										coords = count;
										orders--;// de placement sur les iles fonction des rapports de force des bases ennemies
									}
									else
										coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 1)
										random = Random.Range(21, 30);
									else
										random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(21, 40);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
								{
									random = Random.Range(40, 43);
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);														
							feuille_ordre1(count, coords, "bomber");
							orders++;
						}
						if (view1(name, scriptinfo1.save_fighter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 37 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 12)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 || 
											(random >= 27 && random <= 29) || random == 33 || (random >= 37 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 13)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 37 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 14)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 15)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 16)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 17)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 18)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 19)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19 ||	random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 22)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 23)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 24)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19 ||	random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 25)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 26)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 27)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19 ||	random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 28)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 29)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}

								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 32)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 33)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 || random == 27)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 34)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 35)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 36)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 || random == 27)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 37)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 38)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 39)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 21 || 
											random == 24 || random == 27)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count == 1)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 13 || random == 16 || random == 19 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 2)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 3)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 4)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 13 || random == 16 || random == 19 ||
											random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 5)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
								else if (count == 6)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 7)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 13 || random == 16 || random == 19 ||
											random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 8)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 9)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 0)
								{
									random = Random.Range(0, 5);
									if (random == 0)
										coords = 11;
									else if (random == 1)
										coords = 17;
									else if (random == 2)
										coords = 31;
									else if (random == 3)
										coords = 21;
									else if (random == 4)
										coords = 23;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "fighter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_commando, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11 || count == 14 || (count >= 17 && count <= 19))
									{
										random = Random.Range(12, 16);
										if (random == 14)
											random = 16;
										coords = random;
									}
									else if (count == 12 || count == 13 || count == 15 || count == 16)
									{
										coords = 10;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 26 || count == 29 || (count >= 21 && count <= 23))
									{
										random = Random.Range(24, 28);
										if (random == 26)
											random = 28;
										coords = random;
									}
									else if (count == 24 || count == 25 || count == 27 || count == 28)
									{
										coords = 20;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 34 || count == 37 || (count >= 31 && count <= 33))
									{
										random = Random.Range(35, 39);
										if (random == 37)
											random = 39;
										coords = random;
									}
									else if (count == 35 || count == 36 || count == 38 || count == 39)
									{
										coords = 30;// Aleas à travailler ici dans la même vue
									}

								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 16);
									coords = random;
									if (random == 13)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 41)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										random = Random.Range(14, 19);
									else if (random == 1)
										random = Random.Range(22, 27);
									else
										random = Random.Range(31, 36);
									coords = random;
									if (random == 16 || random == 24 || random == 33)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 42)
								{
									random = Random.Range(21, 26);
									coords = random;
									if (random == 23)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(15, 20);
									else
										random = Random.Range(32, 37);
									coords = random;
									if (random == 17 || random == 34)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 44)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(25, 30);
									else
										random = Random.Range(34, 39);
									coords = random;
									if (random == 27 || random == 36)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
							}
							else
							{
								/*if (count == 0)// Soldats ne bougent pas en mode neutre
								{
									coords = 0;
									orders--;
								}*/
								if (count == 1)
								{
									random = Random.Range(2, 10);
									coords = random;
								}
								else if (count == 5)
								{
									random = Random.Range(40, 43);
									coords = random;
								}
								else if (count == 2 || count == 3)
								{
									coords = 40;
								}
								else if (count == 4 || count == 7)
								{
									coords = 42;
								}
								else if (count == 6 || count == 8 || count == 9) // contenu de la parenthese innecessaire
								{
									coords = 41;
								}
							}
							if (count != 0){
							yield WaitForSeconds(0.1);												
							feuille_ordre1(count, coords, "commando");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_destroyer, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 40;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 46;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 51;
								}
								else if (count == 41)
								{
									coords = 9;
								}
								else if (count == 42)
								{
									coords = 49;
								}
								else if (count == 43)
								{
									coords = 46;
								}
								else if (count == 44)
								{
									coords = 47;	
								}
								else if (count == 45)
								{
									coords = 40;
								}
								else if (count == 46)
								{
									coords = 41;
								}
								else if (count == 47)
								{
									coords = 41;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									random = Random.Range(0, 4);
									if (random == 0)
										coords = 42;
									else if (random == 1)
										coords = random;
									else if (random == 2)
										coords = 4;
									else
										coords = 7;
								}
								else if (count == 50)
								{
									random = Random.Range(0, 4);
									if (random == 0)
										random += 40;
									coords = random;
								}
								else if (count == 51)
								{
									coords = 40;
								}
								else if (count == 52)
								{
									coords = 13;
								}
								else if (count == 53)
								{
									coords = 43;
								}
								else if (count == 54)
								{
									coords = 47;
								}
								else if (count == 55)
								{
									coords = 27;
								}
								else if (count == 56)
								{
									coords = 49;
								}
								
							}
							else
							{
							//	if (count == 0) mode neutre un croiseur laisse au temple
							//	{
							//		random = Random.Range(49, 51);
							//		coords = random;
							//	}
								if (count == 1)
								{
									random = Random.Range(49, 51);
									coords = random;
								}
								else if (count == 2)
								{
									coords = 50;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 49;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 49;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 48;
								}
								else if (count == 0)
								{
									if (view1(name, scriptinfo1.save_destroyer, 1) > 1)
									{
										random = Random.Range(49,52);
										if (random == 51)
											random -= 50;
										coords = random;
									}
									else
									{
										orders--;
										coords = 0;
									}
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "destroyer");
							orders++;
						}
						if (view1(name, scriptinfo1.save_hunter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 37 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 12)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 || 
											(random >= 27 && random <= 29) || random == 33 || (random >= 37 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 13)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 37 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 14)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 15)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 16)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 17)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 18)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 19)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 ||
											(random >= 27 && random <= 29))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19 ||	random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 22)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 23)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 24)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19 ||	random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 25)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 26)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 27)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19 ||	random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 28)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 29)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 16 || 
											random == 19)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}

								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 32)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 33)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 || random == 27)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 34)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 35)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 36)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 21 || random == 24 || random == 27)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 37)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 38)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
									else if (count == 39)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || (random >= 11 && random <= 13) || random == 21 || 
											random == 24 || random == 27)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count == 1)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 13 || random == 16 || random == 19 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 2)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 3)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 ||
											(random >= 27 && random <= 29) || random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 4)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 13 || random == 16 || random == 19 ||
											random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 5)
									{
										random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
									}
								else if (count == 6)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 7)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30 || random == 13 || random == 16 || random == 19 ||
											random == 33 || (random >= 36 && random <= 39))
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 8)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 9)
								{
									random = Random.Range(10, 40);
										coords = random;
										if (random == 10 || random == 20 || random == 30)
										{
											coords = count;
											orders--; // Compenser le ++ en fin de boucle
										}
								}
								else if (count == 0)
								{
									random = Random.Range(0, 5);
									if (random == 0)
										coords = 11;
									else if (random == 1)
										coords = 17;
									else if (random == 2)
										coords = 31;
									else if (random == 3)
										coords = 21;
									else if (random == 4)
										coords = 23;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "hunter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_raider, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									random = Random.Range(10, 20);
									if (random == count || random == 10)
									{
										coords = count;
										orders--;
									}
									else
										coords = random;
								}
								else if (count >= 20 && count < 30)
								{
									random = Random.Range(20, 30);
									if (random == count || random == 20)
									{
										coords = count;
										orders--;
									}
									else
										coords = random;
								}
								else if (count >= 30 && count < 40)
								{
									random = Random.Range(30, 40);
									if (random == count || random == 30)
									{
										coords = count;
										orders--;// de placement sur les iles fonction des rapports de force des bases ennemies
									}
									else
										coords = random;
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(10, 40);
									if (random == 10 || random == 20 || random == 30)
									{
										coords = count;
										orders--;// de placement sur les iles fonction des rapports de force des bases ennemies
									}
									else
										coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 1)
										random = Random.Range(21, 30);
									else
										random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(21, 40);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
								{
									random = Random.Range(40, 43);
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "raider");
							orders++;
						}
						if (view1(name, scriptinfo1.save_soldier, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11 || count == 14 || (count >= 17 && count <= 19))
									{
										random = Random.Range(12, 16);
										if (random == 14)
											random = 16;
										coords = random;
									}
									else if (count == 12 || count == 13 || count == 15 || count == 16)
									{
										coords = 10;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 26 || count == 29 || (count >= 21 && count <= 23))
									{
										random = Random.Range(24, 28);
										if (random == 26)
											random = 28;
										coords = random;
									}
									else if (count == 24 || count == 25 || count == 27 || count == 28)
									{
										coords = 20;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 34 || count == 37 || (count >= 31 && count <= 33))
									{
										random = Random.Range(35, 39);
										if (random == 37)
											random = 39;
										coords = random;
									}
									else if (count == 35 || count == 36 || count == 38 || count == 39)
									{
										coords = 30;// Aleas à travailler ici dans la même vue
									}

								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 16);
									coords = random;
									if (random == 13)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 41)
								{
									random = Random.Range(0, 3);
									if (random == 0)
										random = Random.Range(14, 19);
									else if (random == 1)
										random = Random.Range(22, 27);
									else
										random = Random.Range(31, 36);
									coords = random;
									if (random == 16 || random == 24 || random == 33)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 42)
								{
									random = Random.Range(21, 26);
									coords = random;
									if (random == 23)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(15, 20);
									else
										random = Random.Range(32, 37);
									coords = random;
									if (random == 17 || random == 34)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 44)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(25, 30);
									else
										random = Random.Range(34, 39);
									coords = random;
									if (random == 27 || random == 36)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
							}
							else
							{
								/*if (count == 0)// Soldats ne bougent pas en mode neutre
								{
									coords = 0;
									orders--;
								}*/
								if (count == 1)
								{
									random = Random.Range(2, 10);
									coords = random;
								}
								else if (count == 5)
								{
									random = Random.Range(40, 43);
									coords = random;
								}
								else if (count == 2 || count == 3)
								{
									coords = 40;
								}
								else if (count == 4 || count == 7)
								{
									coords = 42;
								}
								else if (count == 6 || count == 8 || count == 9) // contenu de la parenthese innecessaire
								{
									coords = 41;
								}
							}
							if (count != 0){
							yield WaitForSeconds(0.1);												
							feuille_ordre1(count, coords, "soldier");
							orders++;
							}
						}
						if (view1(name, scriptinfo1.save_cruiser, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 40;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 46;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 51;
								}
								else if (count == 41)
								{
									coords = 9;
								}
								else if (count == 42)
								{
									coords = 49;
								}
								else if (count == 43)
								{
									coords = 46;
								}
								else if (count == 44)
								{
									coords = 47;	
								}
								else if (count == 45)
								{
									coords = 40;
								}
								else if (count == 46)
								{
									coords = 41;
								}
								else if (count == 47)
								{
									coords = 41;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									random = Random.Range(0, 4);
									if (random == 0)
										coords = 42;
									else if (random == 1)
										coords = random;
									else if (random == 2)
										coords = 4;
									else
										coords = 7;
								}
								else if (count == 50)
								{
									random = Random.Range(0, 4);
									if (random == 0)
										random += 40;
									coords = random;
								}
								else if (count == 51)
								{
									coords = 40;
								}
								else if (count == 52)
								{
									coords = 13;
								}
								else if (count == 53)
								{
									coords = 43;
								}
								else if (count == 54)
								{
									coords = 47;
								}
								else if (count == 55)
								{
									coords = 27;
								}
								else if (count == 56)
								{
									coords = 49;
								}
								
							}
							else
							{
							//	if (count == 0) mode neutre un croiseur laisse au temple
							//	{
							//		random = Random.Range(49, 51);
							//		coords = random;
							//	}
								if (count == 1)
								{
									random = Random.Range(49, 51);
									coords = random;
								}
								else if (count == 2)
								{
									coords = 50;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 49;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 49;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 48;
								}
								else if (count == 0)
								{
									if (view1(name, scriptinfo1.save_cruiser, 1) > 1)
									{
										random = Random.Range(49,52);
										if (random == 51)
											random -= 50;
										coords = random;
									}
									else
									{
										orders--;
										coords = 0;
									}
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "cruiser");
							orders++;
						}
						count++;
					}
				}

	// Condition spéciale a prevoir pour l'assault final
			else if (iamode == 2){// 3 options d attaques une par adversaire, une sur 3 directions a prendre // Ne pas oublier marquer les territoires neutres
					count = 0; // Conditionner l arret du mode 2 probablement a une presence dans le HQ adverse
					var attack : int = 0;
					var soldierpresent1 : int = 0;
					var soldierpresent2 : int = 0;
					var soldierpresent3 : int = 0;
					if (totalforces0 > totalforces1 && totalforces1 != 0)//= totalforces1 * 3/2) // Qui attaquer suivant le rapport de forces
						attack = 21;
					else if (totalforces0 > totalforces2 && totalforces2 != 0)//= totalforces2 * 3/2) // 3/2 depend du LevelStrength
						attack = 22;
					else if (totalforces0 > totalforces3 && totalforces3 != 0)//= totalforces3 * 3/2)
						attack = 23;
					if (attack == 22 && totalforces0 > totalforces3 && totalforces3 != 0)
					{
						attack = Random.Range(22, 24);
					}
					else if (attack == 21 && totalforces0 > totalforces2 && totalforces0 > totalforces3 && totalforces2 != 0 && totalforces3 != 0)
					{
						attack = Random.Range(21, 24);
					}
					else if (attack == 21 && totalforces0 > totalforces2 && totalforces2 != 0)
					{
						attack = Random.Range(21, 23);
					}
					else if (attack == 21 && totalforces0 > totalforces3 && totalforces3 != 0)
					{
						attack = Random.Range(21, 23);
						if (attack == 22)
							attack = 23;
					}
					count = 11;
					while (count < 40)
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (view1(name, scriptinfo1.save_soldier, 0) > -1){
							if (count == 12 || count == 13 || count == 15 || count == 16)
								soldierpresent1 = 1;
							if (count == 24 || count == 25 || count == 27 || count == 28)
								soldierpresent2 = 1;
							if (count == 35 || count == 36 || count == 38 || count == 39)
								soldierpresent3 = 1;
						}
						if (view1(name, scriptinfo1.save_commando, 0) > -1){
							if (count == 12 || count == 13 || count == 15 || count == 16)
								soldierpresent1 = 1;
							if (count == 24 || count == 25 || count == 27 || count == 28)
								soldierpresent2 = 1;
							if (count == 35 || count == 36 || count == 38 || count == 39)
								soldierpresent3 = 1;
						}
						count ++;
					}
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (attack == 21){
						if (view1(name, scriptinfo1.save_bomber, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (soldierpresent1 != 1 || count == 10)
									{
										random = Random.Range(11, 20);
										coords = random;
									}
									else
										coords = 10;
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 20)
										coords = 23;
									else
										coords = 41;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 30)
										coords = 35;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 43;
									}
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(1, 10);
									else
										random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
								{
									random = Random.Range(40, 42);
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "bomber");
							orders++;
						}
						if (view1(name, scriptinfo1.save_fighter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (soldierpresent1 != 1 || count == 10)
									{
										random = Random.Range(11, 20);
										coords = random;
									}
									else
										coords = 10;	
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23 || count == 25 || count == 26)
									{
										random = Random.Range(11, 20);
										coords = random;
									}
									else if (count == 21 || count == 24 || (count >= 27 && count <= 29))
									{
										random = Random.Range(14, 19);
										if (random == 16)
											random = 17;
										coords = random;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count >= 31 && count <= 36)
									{
										random = Random.Range(11, 20);
										coords = random;
									}
									else if (count >= 37 && count <= 39)
									{
										random = Random.Range(14, 20);
										coords = random;
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count == 2 || count == 3 || count == 5 || count == 6 || count == 8 || count == 9)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 1 || count == 4 || count == 7)
								{
									random = Random.Range(11, 20);
									if (random == 13 || random == 16 || random == 19)
										random = 15;
									coords = random;
								}
								else if (count == 0)
								{
									random = Random.Range(11, 18);
									if (random != 11 && random != 14 && random != 17)
									{
										random = 17;
									}
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "fighter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_commando, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11 || count == 14 || (count >= 17 && count <= 19))
									{
										random = Random.Range(12, 16);
										if (random == 14)
											random = 16;
										coords = random;
									}
									else if (count == 12 || count == 13 || count == 15 || count == 16)
									{
										coords = 10;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23 || count == 25 || count == 26)
									{
										coords = 41;
									}
									else if (count == 21 || count == 24 || (count >= 27 && count <= 29))
									{
										coords = 23;// Aleas à travailler ici dans la même vue
									}
									else if (count == 20)
										coords = 25;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 34 || count == 31)
									{
										coords = 41;
									}
									else if (count == 33 || count == 36)
									{
										coords = 43;// Aleas  àtravailler ici dans la même vue
									}
									else if (count == 32 || count == 35)
									{
										random = Random.Range(41, 44);
										if (random == 42)
											random = 44;
										coords = random;
									}
									else if (count >= 37 && count <= 39)
									{
										coords = 35;
									}
									else if (coords == 30)
										coords = 35;
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 16);
									coords = random;
									if (random == 13)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 41)
								{
									random = Random.Range(14, 19);
									coords = random;
									if (random == 16)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										coords = 5;
									else
										coords = 25;
								}
								else if (count == 43)
								{
									random = Random.Range(15, 20);
									if (random == 17)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 44)
								{
									coords = 35;
								}
							}
							else
							{
								if (count == 1)
								{
									random = Random.Range(2, 10);
									coords = random;
								}
								else if (count == 5)
								{
									random = Random.Range(40, 42);
									coords = random;
								}
								else if (count == 2 || count == 3)
								{
									coords = 40;
								}
								else if (count == 4 || count == 7)
								{
									coords = 5;
								}
								else if (count == 6 || count == 8 || count == 9) 
								{
									coords = 41;
								}
								else if (count == 0)
									coords = 5;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "commando");
							orders++;
						}
						if (view1(name, scriptinfo1.save_destroyer, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 51;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										if (soldierpresent1 != 1)
											coords = 51;
										else
											coords = 10;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 43;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 51;
								}
								else if (count == 41)
								{
									random = Random.Range(45, 47);
									coords = random;
								}
								else if (count == 42)
								{
									coords = 48;
								}
								else if (count == 43)
								{
									coords = 52;
								}
								else if (count == 44)
								{
									coords = 54;	
								}
								else if (count == 45)
								{
									coords = 40;
								}
								else if (count == 46)
								{
									coords = 43;
								}
								else if (count == 47)
								{
									coords = 44;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									coords = 0;
								}
								else if (count == 50)
								{
									coords = 40;
								}
								else if (count == 51)
								{
									if (soldierpresent1 != 1)
										coords = 12;
									else
										coords = 10;
								}
								else if (count == 52)
								{
									if (soldierpresent1 != 1)
										coords = 16;
									else
										coords = 10;
								}
								else if (count == 53)
								{
									coords = 43;
								}
								else if (count == 54)
								{
									coords = 39;
								}
								else if (count == 55)
								{
									coords = 44;
								}
								else if (count == 56)
								{
									coords = 27;
								}
								
							}
							else
							{
								if (count == 0)
								{
									coords = 50;
								}
								else if (count == 1)
								{
									coords = 50;
								}
								else if (count == 2)
								{
									coords = 50;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 1;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 8;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 41;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "destroyer");
							orders++;
						}
						}
						count++;
					}
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (attack == 21){
						if (view1(name, scriptinfo1.save_hunter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									random = Random.Range(11, 20);
									coords = random;	
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23 || count == 25 || count == 26)
									{
										random = Random.Range(11, 20);
										coords = random;
									}
									else if (count == 21 || count == 24 || (count >= 27 && count <= 29))
									{
										random = Random.Range(14, 19);
										if (random == 16)
											random = 17;
										coords = random;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count >= 31 && count <= 36)
									{
										random = Random.Range(11, 20);
										coords = random;
									}
									else if (count >= 37 && count <= 39)
									{
										random = Random.Range(14, 20);
										coords = random;
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count == 2 || count == 3 || count == 5 || count == 6 || count == 8 || count == 9)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 1 || count == 4 || count == 7)
								{
									random = Random.Range(11, 20);
									if (random == 13 || random == 16 || random == 19)
										random = 15;
									coords = random;
								}
								else if (count == 0)
								{
									random = Random.Range(11, 18);
									if (random != 11 && random != 14 && random != 17)
									{
										random = 17;
									}
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "hunter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_raider, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 20)
										coords = 23;
									else
										coords = 41;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 30)
										coords = 35;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 43;
									}
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(1, 10);
									else
										random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
								{
									random = Random.Range(40, 42);
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "raider");
							orders++;
						}
						if (view1(name, scriptinfo1.save_soldier, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11 || count == 14 || (count >= 17 && count <= 19))
									{
										random = Random.Range(12, 16);
										if (random == 14)
											random = 16;
										coords = random;
									}
									else if (count == 12 || count == 13 || count == 15 || count == 16)
									{
										coords = 10;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23 || count == 25 || count == 26)
									{
										coords = 41;
									}
									else if (count == 21 || count == 24 || (count >= 27 && count <= 29))
									{
										coords = 23;// Aleas à travailler ici dans la même vue
									}
									else if (count == 20)
										coords = 25;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 34 || count == 31)
									{
										coords = 41;
									}
									else if (count == 33 || count == 36)
									{
										coords = 43;// Aleas  àtravailler ici dans la même vue
									}
									else if (count == 32 || count == 35)
									{
										random = Random.Range(41, 44);
										if (random == 42)
											random = 44;
										coords = random;
									}
									else if (count >= 37 && count <= 39)
									{
										coords = 35;
									}
									else if (coords == 30)
										coords = 35;
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 16);
									coords = random;
									if (random == 13)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 41)
								{
									random = Random.Range(14, 19);
									coords = random;
									if (random == 16)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										coords = 5;
									else
										coords = 25;
								}
								else if (count == 43)
								{
									random = Random.Range(15, 20);
									if (random == 17)
									{
										coords = count;
										orders--;   // le fameux sur place
									}
								}
								else if (count == 44)
								{
									coords = 35;
								}
							}
							else
							{
								if (count == 1)
								{
									random = Random.Range(2, 10);
									coords = random;
								}
								else if (count == 5)
								{
									random = Random.Range(40, 42);
									coords = random;
								}
								else if (count == 2 || count == 3)
								{
									coords = 40;
								}
								else if (count == 4 || count == 7)
								{
									coords = 5;
								}
								else if (count == 6 || count == 8 || count == 9) 
								{
									coords = 41;
								}
								else if (count == 0)
									coords = 5;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "soldier");
							orders++;
						}
						if (view1(name, scriptinfo1.save_cruiser, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 51;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 43;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 51;
								}
								else if (count == 41)
								{
									random = Random.Range(45, 47);
									coords = random;
								}
								else if (count == 42)
								{
									coords = 48;
								}
								else if (count == 43)
								{
									coords = 52;
								}
								else if (count == 44)
								{
									coords = 54;	
								}
								else if (count == 45)
								{
									coords = 40;
								}
								else if (count == 46)
								{
									coords = 43;
								}
								else if (count == 47)
								{
									coords = 44;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									coords = 0;
								}
								else if (count == 50)
								{
									coords = 40;
								}
								else if (count == 51)
								{
									coords = 12;
								}
								else if (count == 52)
								{
									coords = 16;
								}
								else if (count == 53)
								{
									coords = 43;
								}
								else if (count == 54)
								{
									coords = 39;
								}
								else if (count == 55)
								{
									coords = 44;
								}
								else if (count == 56)
								{
									coords = 27;
								}
								
							}
							else
							{
								if (count == 0)
								{
									coords = 50;
								}
								else if (count == 1)
								{
									coords = 50;
								}
								else if (count == 2)
								{
									coords = 50;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 1;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 8;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 41;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "cruiser");
							orders++;
						}
						}
						count++;
					}
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (attack == 22){					
							if (view1(name, scriptinfo1.save_bomber, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (coords != 10)
										coords = 41;
									else
									{
										random = Random.Range(25, 28);
										if (random == 26)
											random = 25;
										coords = random;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (soldierpresent2 != 1 || count == 20)
									{
										random = Random.Range(21, 30);
										coords = random;
									}
									else
										coords = 20;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 30)
										coords = 35;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 44;
									}
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(1, 20);
									if (random == 10)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											random = 5;
										else
											random = 15;
									}
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(11, 20);
									else
										random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
								{
									random = Random.Range(41, 43);
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "bomber");
							orders++;
							}
							if (view1(name, scriptinfo1.save_fighter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 14 || count == 15 || count == 17 || count == 18)
									{
										random = Random.Range(21, 30);
										coords = random;
									}
									else if (count == 16 || count == 19 || (count >= 11 && count <= 13))
									{
										random = Random.Range(22, 27);
										if (random == 24)
										{
											random = Random.Range(0, 2);
											if (random == 0)
												random = 23;
											else
												random = 25;
										}
										coords = random;
									}	
								}
								else if (count >= 20 && count < 30)
								{
									if (soldierpresent2 != 1 || count == 20)
									{
										random = Random.Range(21, 30);
										coords = random;
									}
									else
										coords = 20;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31 || count == 32 || count == 34 || count == 35 || count == 37 || count == 38)
									{
										random = Random.Range(21, 30);
										coords = random;
									}
									else if (count == 33 || count == 36 || count == 39)
									{
										random = Random.Range(22, 30);
										if (random == 24 || random == 27)
											random = 25;
										coords = random;
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count >= 1 && count <= 3)
								{
									random = Random.Range(21, 27);
									coords = random;
								}
								else if (count >= 4 && count <= 9)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 0)
								{
									random = Random.Range(21, 24);
									if (random == 22)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											random = 21;
										else
											random = 23;
									}
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "fighter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_commando, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 16 || count == 19 || (count >= 11 && count <= 13))
									{
										random = Random.Range(14, 18);
										if (random == 16)
											random = 18;
										coords = random;
									}
									else if (count == 14 || count == 15 || count == 17 || count == 18)
									{
										coords = 41;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if ((count >= 21 && count <= 23) || count == 26 || count == 29)
									{
										random = Random.Range(24, 28);
										if (random == 26)
											random = 28;
										coords = random;
									}
									else if (count == 24 || count == 25 || count == 27 || count == 28)
									{
										coords = 20;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31 || count == 32)
									{
										coords = 41;
									}
									else if (count == 37 || count == 38)
									{
										coords = 44;
									}
									else if (count == 34 || count == 35)
									{
										random = Random.Range(41, 44);
										if (random == 42)
											random = 41;
										else if (random == 41)
											random = 44;
										coords = random;
									}
									else if (count == 33 || count == 36 || count == 39)
									{
										coords = 35;
									}
									else if (coords == 30)
										coords = 35;
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(2, 6);
									if (random == 4)
										random = 6;
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(22, 26);
									if (random == 24)
										random = 26;
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(21, 25);
									if (random == 23)
										random = 25;
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 0)
									{
										random = Random.Range(15, 19);
										if (random == 17)
											random = 19;
									}
									else
									{
										random = Random.Range(32, 36);
										if (random == 34)
											random = 36;
									}
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(25, 29);
									if (random == 27)
										random = 29;
									coords = random;
								}
							}
							else
							{
								if (count == 1)
								{
									random = Random.Range(2, 10);
									coords = random;
								}
								else if (count == 5 || count == 8)
								{
									random = Random.Range(41, 43);
									coords = random;
								}
								else if (count == 2 || count == 3)
								{
									coords = 5;
								}
								else if (count == 4 || count == 7)
								{
									coords = 42;
								}
								else if (count == 6 || count == 8 || count == 9) 
								{
									coords = 41;
								}
								else if (count == 0)
									coords = 5;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "commando");
							orders++;
						}
						if (view1(name, scriptinfo1.save_destroyer, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 51;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										if (soldierpresent2 != 1)
											coords = 56;
										else
											coords = 20;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 43;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 45;
								}
								else if (count == 41)
								{
									random = Random.Range(47, 49);
									coords = random;
								}
								else if (count == 42)
								{
									coords = 48;
								}
								else if (count == 43)
								{
									coords = 53;
								}
								else if (count == 44)
								{
									coords = 55;	
								}
								else if (count == 45)
								{
									coords = 41;
								}
								else if (count == 46)
								{
									coords = 41;
								}
								else if (count == 47)
								{
									coords = 44;
								}
								else if (count == 48)
								{
									coords = 42;
								}
								else if (count == 49)
								{
									coords = 42;
								}
								else if (count == 50)
								{
									coords = 1;
								}
								else if (count == 51)
								{
									coords = 40;
								}
								else if (count == 52)
								{
									coords = 13;
								}
								else if (count == 53)
								{
									coords = 39;
								}
								else if (count == 54)
								{
									coords = 44;
								}
								else if (count == 55)
								{
									coords = 20;
								}
								else if (count == 56)
								{
									if (soldierpresent2 != 1)
										coords = 27;
									else
										coords = 20;
								}
								
							}
							else
							{
								if (count == 0)
								{
									coords = 49;
								}
								else if (count == 1)
								{
									coords = 49;
								}
								else if (count == 2)
								{
									coords = 1;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 49;
								}
								else if (count == 6)
								{
									coords = 45;
								}
								else if (count == 7)
								{
									coords = 49;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 41;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "destroyer");
							orders++;
						}
						}
						count++;
					}
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (attack == 22){
							if (view1(name, scriptinfo1.save_hunter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 14 || count == 15 || count == 17 || count == 18)
									{
										random = Random.Range(21, 30);
										coords = random;
									}
									else if (count == 16 || count == 19 || (count >= 11 && count <= 13))
									{
										random = Random.Range(22, 27);
										if (random == 24)
										{
											random = Random.Range(0, 2);
											if (random == 0)
												random = 23;
											else
												random = 25;
										}
										coords = random;
									}	
								}
								else if (count >= 20 && count < 30)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31 || count == 32 || count == 34 || count == 35 || count == 37 || count == 38)
									{
										random = Random.Range(21, 30);
										coords = random;
									}
									else if (count == 33 || count == 36 || count == 39)
									{
										random = Random.Range(22, 30);
										if (random == 24 || random == 27)
											random = 25;
										coords = random;
									}
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if (count >= 1 && count <= 3)
								{
									random = Random.Range(21, 27);
									coords = random;
								}
								else if (count >= 4 && count <= 9)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 0)
								{
									random = Random.Range(21, 24);
									if (random == 22)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											random = 21;
										else
											random = 23;
									}
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "hunter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_raider, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (coords != 10)
										coords = 41;
									else
									{
										random = Random.Range(25, 28);
										if (random == 26)
											random = 25;
										coords = random;
									}
								}
								else if (count >= 20 && count < 30)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 30)
										coords = 35;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 44;
									}
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(1, 20);
									if (random == 10)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											random = 5;
										else
											random = 15;
									}
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(11, 20);
									else
										random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(21, 30);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
								{
									random = Random.Range(41, 43);
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "raider");
							orders++;
						}
						if (view1(name, scriptinfo1.save_soldier, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 16 || count == 19 || (count >= 11 && count <= 13))
									{
										random = Random.Range(14, 18);
										if (random == 16)
											random = 18;
										coords = random;
									}
									else if (count == 14 || count == 15 || count == 17 || count == 18)
									{
										coords = 41;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if ((count >= 21 && count <= 23) || count == 26 || count == 29)
									{
										random = Random.Range(24, 28);
										if (random == 26)
											random = 28;
										coords = random;
									}
									else if (count == 24 || count == 25 || count == 27 || count == 28)
									{
										coords = 20;// Aleas à travailler ici dans la même vue
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31 || count == 32)
									{
										coords = 41;
									}
									else if (count == 37 || count == 38)
									{
										coords = 44;
									}
									else if (count == 34 || count == 35)
									{
										random = Random.Range(41, 44);
										if (random == 42)
											random = 41;
										else if (random == 41)
											random = 44;
										coords = random;
									}
									else if (count == 33 || count == 36 || count == 39)
									{
										coords = 35;
									}
									else if (coords == 30)
										coords = 35;
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(2, 6);
									if (random == 4)
										random = 6;
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(22, 26);
									if (random == 24)
										random = 26;
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(21, 25);
									if (random == 23)
										random = 25;
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(0, 2);
									if (random == 0)
									{
										random = Random.Range(15, 19);
										if (random == 17)
											random = 19;
									}
									else
									{
										random = Random.Range(32, 36);
										if (random == 34)
											random = 36;
									}
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(25, 29);
									if (random == 27)
										random = 29;
									coords = random;
								}
							}
							else
							{
								if (count == 1)
								{
									random = Random.Range(2, 10);
									coords = random;
								}
								else if (count == 5 || count == 8)
								{
									random = Random.Range(41, 43);
									coords = random;
								}
								else if (count == 2 || count == 3)
								{
									coords = 5;
								}
								else if (count == 4 || count == 7)
								{
									coords = 42;
								}
								else if (count == 6 || count == 8 || count == 9) 
								{
									coords = 41;
								}
								else if (count == 0)
									coords = 5;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "soldier");
							orders++;
						}
						if (view1(name, scriptinfo1.save_cruiser, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 51;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 43;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 45;
								}
								else if (count == 41)
								{
									random = Random.Range(47, 49);
									coords = random;
								}
								else if (count == 42)
								{
									coords = 48;
								}
								else if (count == 43)
								{
									coords = 53;
								}
								else if (count == 44)
								{
									coords = 55;	
								}
								else if (count == 45)
								{
									coords = 41;
								}
								else if (count == 46)
								{
									coords = 41;
								}
								else if (count == 47)
								{
									coords = 44;
								}
								else if (count == 48)
								{
									coords = 42;
								}
								else if (count == 49)
								{
									coords = 42;
								}
								else if (count == 50)
								{
									coords = 1;
								}
								else if (count == 51)
								{
									coords = 40;
								}
								else if (count == 52)
								{
									coords = 13;
								}
								else if (count == 53)
								{
									coords = 39;
								}
								else if (count == 54)
								{
									coords = 44;
								}
								else if (count == 55)
								{
									coords = 20;
								}
								else if (count == 56)
								{
									coords = 27;
								}
								
							}
							else
							{
								if (count == 0)
								{
									coords = 49;
								}
								else if (count == 1)
								{
									coords = 49;
								}
								else if (count == 2)
								{
									coords = 1;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 49;
								}
								else if (count == 6)
								{
									coords = 45;
								}
								else if (count == 7)
								{
									coords = 49;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 41;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "cruiser");
							orders++;
						}

						}
						count++;
					}
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (attack == 23){
							if (view1(name, scriptinfo1.save_bomber, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 10)
										coords = 15;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 43;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 20)
										coords = 25;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 44;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (soldierpresent3 != 1 || count == 30)
									{
										random = Random.Range(31, 40);
										coords = random;
									}
									else
										coords = 30;
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(1, 10);
									else
										random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
									coords = 41;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "bomber");
							orders++;
							}
							if (view1(name, scriptinfo1.save_fighter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count >= 11 && count <= 13)
									{
										random = Random.Range(31, 37);
										coords = random;
									}
									else if (count == 14 && count <= 19)
									{
										random = Random.Range(31, 40);
										coords = random;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23 || count == 25 || count == 26 || count == 28 || count == 29)
									{
										random = Random.Range(31, 40);
										coords = random;
									}
									else if (count == 21 || count == 24 || count == 27)
									{
										random = Random.Range(31, 37);
										if (random == 33)
											random = 37;
										else if (random == 36)
											random = 38;
										coords = random;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (soldierpresent3 != 1 || count == 30)
									{
										random = Random.Range(31, 40);
										coords = random;
									}
									else
										coords = 30;
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if ((count >= 1 && count <= 3) || count == 4 || count == 7)
								{
									random = Random.Range(31, 35);
									if (random == 33)
										random = 35;
									coords = random;
								}
								else if (count == 5 || count == 6 || count == 8 || count == 9)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 0)
								{
									random = Random.Range(5, 9);
									if (random == 7)
									{
										random = 9;
									}
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "fighter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_commando, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 14 || count == 17)
									{
										coords = 41;
									}
									else if (count == 16 || count == 19)
									{
										coords = 43;
									}
									else if (count == 15 || count == 18)
									{
										random = Random.Range(41, 43);
										if (random == 42)
											random = 43;
										coords = random;
									}
									else if (count >= 11 && count <= 13)
									{
										coords = 15;
									}
									else if (coords == 10)
										coords = 15;
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23)
									{
										coords = 41;
									}
									else if (count == 28 || count == 29)
									{
										coords = 44;
									}
									else if (count == 25 || count == 26)
									{
										random = Random.Range(41, 43);
										if (random == 42)
											random = 44;
										coords = random;
									}
									else if (count == 21 || count == 24 || count == 27)
									{
										coords = 25;
									}
									else if (coords == 20)
										coords = 25;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 34 || count == 37 || (count >= 31 && count <= 33))
									{
										random = Random.Range(35, 39);
										if (random == 37)
											random = 39;
										coords = random;
									}
									else if (count == 35 || count == 36 || count == 38 || count == 39)
									{
										coords = 30;// Aleas à travailler ici dans la même vue
									}
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(4, 6);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(31, 35);
									if (random == 33)
										random = 35;
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										coords = 5;
									else
										coords = 25;
								}
								else if (count == 43)
								{
									random = Random.Range(32, 36);
									if (random == 34)
										random = 36;
								}
								else if (count == 44)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										coords = 35;
									else
										coords = 38;
								}
							}
							else
							{
								if ((count >= 1 && count <= 3) || count == 4 || count == 7)
								{
									random = Random.Range(5, 9);
									if (random == 7)
										random = 9;
									coords = random;
								}
								else if (count == 5 || count == 6 || count == 8 || count == 9)
								{
									coords = 41;
								}
								else if (count == 0)
									coords = 5;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "commando");
							orders++;
						}
						if (view1(name, scriptinfo1.save_destroyer, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 51;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 43;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										if (soldierpresent3 != 1)
											coords = 54;
										else
											coords = 30;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 45;
								}
								else if (count == 41)
								{
									random = Random.Range(46, 48);
									coords = random;
								}
								else if (count == 42)
								{
									coords = 48;
								}
								else if (count == 43)
								{
									coords = 53;
								}
								else if (count == 44)
								{
									coords = 54;	
								}
								else if (count == 45)
								{
									coords = 41;
								}
								else if (count == 46)
								{
									coords = 43;
								}
								else if (count == 47)
								{
									coords = 44;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									coords = 42;
								}
								else if (count == 50)
								{
									coords = 40;
								}
								else if (count == 51)
								{
									random = Random.Range(0, 2);
									if (random == 1)
										coords = 13;
									else
										coords = 40;
								}
								else if (count == 52)
								{
									coords = 43;
								}
								else if (count == 53)
								{
									coords = 30;
								}
								else if (count == 54)
								{
									coords = 30;
								}
								else if (count == 55)
								{
									coords = 44;
								}
								else if (count == 56)
								{
									coords = 27; //Condition pour prendre un autre chemin comme 42
								}
								
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(49, 51);
									coords = random;
								}
								else if (count == 1)
								{
									coords = 50;
								}
								else if (count == 2)
								{
									coords = 50;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 1;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 8;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 41;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "destroyer");
							orders++;
							}
						}
						count++;
					}
					count = 0;
					while (count < 57 && orders < 5) // Ne surtout pas oublier count == 0 count == 10  count == 20  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					{
						for (var dec : GameObject in decor) {
							if (dec.name == scripttest.biblidecor2[count])
								name = dec;
						}
						if (attack == 23){
							if (view1(name, scriptinfo1.save_hunter, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count >= 11 && count <= 13)
									{
										random = Random.Range(31, 37);
										coords = random;
									}
									else if (count == 14 && count <= 19)
									{
										random = Random.Range(31, 40);
										coords = random;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23 || count == 25 || count == 26 || count == 28 || count == 29)
									{
										random = Random.Range(31, 40);
										coords = random;
									}
									else if (count == 21 || count == 24 || count == 27)
									{
										random = Random.Range(31, 37);
										if (random == 33)
											random = 37;
										else if (random == 36)
											random = 38;
										coords = random;
									}
								}
								else if (count >= 30 && count < 40)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
							}
						/*	else if (count > 40)
							{
								if (count == 40 || count == 41 || count == 42)
									coords = 5;
								else if (count == 43 || count == 44)
								{
									if (count == 43)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 15;
										else
											coords = 35;
									}
									else if (count == 44)
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 25;
										else
											coords = 35;
									}

								}
							}*/
							else
							{
								if ((count >= 1 && count <= 3) || count == 4 || count == 7)
								{
									random = Random.Range(31, 35);
									if (random == 33)
										random = 35;
									coords = random;
								}
								else if (count == 5 || count == 6 || count == 8 || count == 9)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 0)
								{
									random = Random.Range(5, 9);
									if (random == 7)
									{
										random = 9;
									}
									coords = random;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "hunter");
							orders++;
						}
						if (view1(name, scriptinfo1.save_raider, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 10)
										coords = 15;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 43;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 20)
										coords = 25;
									else
									{
										random = Random.Range(0, 2);
										if (random == 0)
											coords = 41;
										else
											coords = 44;
									}
								}
								else if (count >= 30 && count < 40)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
									
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(11, 20);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										random = Random.Range(1, 10);
									else
										random = Random.Range(21, 30);
									coords = random;
								}
								else if (count == 43)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
								else if (count == 44)
								{
									random = Random.Range(31, 40);
									coords = random;
								}
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(1, 10);
									coords = random;
								}
								else
									coords = 41;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "raider");
							orders++;
						}
						if (view1(name, scriptinfo1.save_soldier, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 14 || count == 17)
									{
										coords = 41;
									}
									else if (count == 16 || count == 19)
									{
										coords = 43;
									}
									else if (count == 15 || count == 18)
									{
										random = Random.Range(41, 43);
										if (random == 42)
											random = 43;
										coords = random;
									}
									else if (count >= 11 && count <= 13)
									{
										coords = 15;
									}
									else if (coords == 10)
										coords = 15;
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 22 || count == 23)
									{
										coords = 41;
									}
									else if (count == 28 || count == 29)
									{
										coords = 44;
									}
									else if (count == 25 || count == 26)
									{
										random = Random.Range(41, 43);
										if (random == 42)
											random = 44;
										coords = random;
									}
									else if (count == 21 || count == 24 || count == 27)
									{
										coords = 25;
									}
									else if (coords == 20)
										coords = 25;
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 34 || count == 37 || (count >= 31 && count <= 33))
									{
										random = Random.Range(35, 39);
										if (random == 37)
											random = 39;
										coords = random;
									}
									else if (count == 35 || count == 36 || count == 38 || count == 39)
									{
										coords = 30;// Aleas à travailler ici dans la même vue
									}
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									random = Random.Range(4, 6);
									coords = random;
								}
								else if (count == 41)
								{
									random = Random.Range(31, 35);
									if (random == 33)
										random = 35;
									coords = random;
								}
								else if (count == 42)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										coords = 5;
									else
										coords = 25;
								}
								else if (count == 43)
								{
									random = Random.Range(32, 36);
									if (random == 34)
										random = 36;
								}
								else if (count == 44)
								{
									random = Random.Range(0, 2);
									if (random == 0)
										coords = 35;
									else
										coords = 38;
								}
							}
							else
							{
								if ((count >= 1 && count <= 3) || count == 4 || count == 7)
								{
									random = Random.Range(5, 9);
									if (random == 7)
										random = 9;
									coords = random;
								}
								else if (count == 5 || count == 6 || count == 8 || count == 9)
								{
									coords = 41;
								}
								else if (count == 0)
									coords = 5;
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "soldier");
							orders++;
						}
						if (view1(name, scriptinfo1.save_cruiser, 0) > -1){
							if (count >= 10 && count < 40)							// On verifie qu'on est pas dans sa zone
							{								// Il faut un tableau qui standardise les coordonnées ennemies juste pour pouvoir se servir de modulo ?
								if (count < 20)
								{
									if (count == 11)
									{
										coords = 51;
									}
									else if (count == 12)
									{
										coords = 51;
									}
									else if (count == 13)
									{
										coords = 51;
									}
									else if (count == 14)
									{
										coords = 45;
									}
									else if (count == 16)
									{
										coords = 52;
									}
									else if (count == 17)
									{
										coords = 45;
									}
									else if (count == 18)
									{
										coords = 46;
									}
									else if (count == 19)
									{
										coords = 52;
									}
								}
								else if (count >= 20 && count < 30)
								{
									if (count == 21)
									{
										coords = 42;
									}
									else if (count == 22)
									{
										coords = 48;
									}
									else if (count == 23)
									{
										coords = 41;
									}
									else if (count == 24)
									{
										coords = 56;
									}
									else if (count == 26)
									{
										coords = 47;
									}
									else if (count == 27)
									{
										coords = 56;
									}
									else if (count == 28)
									{
										coords = 55;
									}
									else if (count == 29)
									{
										coords = 55;
									}
								}
								else if (count >= 30 && count < 40)
								{
									if (count == 31)
									{
										coords = 41;
									}
									else if (count == 32)
									{
										coords = 46;
									}
									else if (count == 33)
									{
										coords = 43;
									}
									else if (count == 34)
									{
										coords = 47;
									}
									else if (count == 36)
									{
										coords = 53;
									}
									else if (count == 37)
									{
										coords = 47;
									}
									else if (count == 38)
									{
										coords = 54;
									}
									else if (count == 39)
									{
										coords = 54;
									}
									
								}
							}
							else if (count >= 40)
							{
								if (count == 40)
								{
									coords = 45;
								}
								else if (count == 41)
								{
									random = Random.Range(46, 48);
									coords = random;
								}
								else if (count == 42)
								{
									coords = 48;
								}
								else if (count == 43)
								{
									coords = 53;
								}
								else if (count == 44)
								{
									coords = 54;	
								}
								else if (count == 45)
								{
									coords = 41;
								}
								else if (count == 46)
								{
									coords = 43;
								}
								else if (count == 47)
								{
									coords = 44;
								}
								else if (count == 48)
								{
									coords = 41;
								}
								else if (count == 49)
								{
									coords = 42;
								}
								else if (count == 50)
								{
									coords = 40;
								}
								else if (count == 51)
								{
									random = Random.Range(0, 2);
									if (random == 1)
										coords = 13;
									else
										coords = 40;
								}
								else if (count == 52)
								{
									coords = 43;
								}
								else if (count == 53)
								{
									coords = 30;
								}
								else if (count == 54)
								{
									coords = 30;
								}
								else if (count == 55)
								{
									coords = 44;
								}
								else if (count == 56)
								{
									coords = 27; //Condition pour prendre un autre chemin comme 42
								}
								
							}
							else
							{
								if (count == 0)
								{
									random = Random.Range(49, 51);
									coords = random;
								}
								else if (count == 1)
								{
									coords = 50;
								}
								else if (count == 2)
								{
									coords = 50;
								}
								else if (count == 3)
								{
									coords = 50;
								}
								else if (count == 4)
								{
									coords = 1;
								}
								else if (count == 6)
								{
									coords = 3;
								}
								else if (count == 7)
								{
									coords = 8;
								}
								else if (count == 8)
								{
									coords = 48;
								}
								else if (count == 9)
								{
									coords = 41;
								}
							}
							yield WaitForSeconds(0.1);								
							feuille_ordre1(count, coords, "cruiser");
							orders++;
						}

						}
						count++;
					}
			}
			scriptchoose.round2++;
		}
	}
}
