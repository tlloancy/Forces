var nbsoldier : int = 2;
var soldier : GameObject;
var ressoldier : int = 0;
var save_soldier : GameObject[];
var coordsoldier : float[];

var nbraider : int = 2;
var raider : GameObject;
var resraider : int = 0;
var save_raider : GameObject[];
var coordraider : float[];

var nbcruiser : int = 2;
var cruiser : GameObject;
var rescruiser : int = 0;
var save_cruiser : GameObject[];
var coordcruiser : float[];

var nbhunter : int = 2;
var hunter : GameObject;
var reshunter : int = 0;
var save_hunter : GameObject[];
var coordhunter : float[];

var nbcommando : int = 0;
var commando : GameObject;
var rescommando : int = 0;
var save_commando : GameObject[];
var coordcommando : float[];

var nbbomber : int = 0;
var bomber : GameObject;
var resbomber : int = 0;
var save_bomber : GameObject[];
var coordbomber : float[];

var nbfighter : int = 0;
var fighter : GameObject;
var resfighter : int = 0;
var save_fighter : GameObject[];
var coordfighter : float[];

var nbdestroyer : int = 0;
var destroyer : GameObject;
var resdestroyer : int = 0;
var save_destroyer : GameObject[];
var coorddestroyer : float[];

var nbhbomb : int = 0;
var hbomb : GameObject;
var reshbomb : int = 0;
var save_hbomb : GameObject[];
var coordhbomb : float[];

private var decor : GameObject[];
private var green : GameObject;
private var blue : GameObject;
private var red : GameObject;
private var yellow : GameObject;
private var start : int = 0;
var isalive : int = 1;
var force : int = 0;

function Stop () {
	if (!networkView.isMine)
		this.enabled = false;
}

function pions_hbomb (val : GameObject) {
	var pos = val.transform.position;
	var rot = val.transform.rotation;

	pos.y -= 0.50;
	pos.z -= 0.1 * nbhbomb;

	save_hbomb[nbhbomb - 1] = Network.Instantiate(hbomb, pos, rot, 0);
}

function pions_soldier (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x -= 0.75;
	pos.y += 0.75;
	pos.z -= 0.1 * (i + 1);
	save_soldier[i] = Network.Instantiate(soldier, pos, rot, 0);
}

function pions_raider (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x += 0.75;
	pos.y += 0.75;
	pos.z -= 0.1 * (i + 1);
	save_raider[i] = Network.Instantiate(raider, pos, rot, 0);
}

function pions_cruiser (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x -= 0.25;
	pos.y += 0.25;
	pos.z -= 0.1 * (i + 1);
	save_cruiser[i] = Network.Instantiate(cruiser, pos, rot, 0);
}

function pions_hunter (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x -= 0.75;
	pos.y -= 0.75;
	pos.z -= 0.1 * (i + 1);
	save_hunter[i] = Network.Instantiate(hunter, pos, rot, 0);
}

function pions_commando (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x -= 0.25;
	pos.y += 0.75;
	pos.z -= 0.1 * (i + 1);
	save_commando[i] = Network.Instantiate(commando, pos, rot, 0);
}

function pions_bomber (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x += 0.25;
	pos.y += 0.75;
	pos.z -= 0.1 * (i + 1);
	save_bomber[i] = Network.Instantiate(bomber, pos, rot, 0);
}

function pions_fighter (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x += 0.75;
	pos.y -= 0.75;
	pos.z -= 0.1 * (i + 1);
	save_fighter[i] = Network.Instantiate(fighter, pos, rot, 0);
}

function pions_destroyer (i : int, val : GameObject) {
	if (val) {
		var pos = val.transform.position;
		var rot = val.transform.rotation;
	}
	else {
		if (name.IndexOf("blue") != -1) {
			pos = blue.transform.position;
			rot = blue.transform.rotation;
		}
		else if (name.IndexOf("red") != -1) {
			pos = red.transform.position;
			rot = red.transform.rotation;
		}
		else if (name.IndexOf("yellow") != -1) {
			pos = yellow.transform.position;
			rot = yellow.transform.rotation;
		}
		else if (name.IndexOf("green") != -1) {
			pos = green.transform.position;
			rot = green.transform.rotation;
		}
	}

	pos.x += 0.25;
	pos.y += 0.25;
	pos.z -= 0.1 * (i + 1);
	save_destroyer[i] = Network.Instantiate(destroyer, pos, rot, 0);
}

function Start () {
	if (Application.loadedLevelName == "Battleground") {
		start++;
		decor = GameObject.FindGameObjectsWithTag("Decor");
		for (var dec : GameObject in decor) {
			if (dec.name == "HQ_Green")
				green = dec;
			else if (dec.name == "HQ_Blue")
				blue = dec;
			else if (dec.name == "HQ_Red")
				red = dec;
			else if (dec.name == "HQ_Yellow")
				yellow = dec;
		}
		up_pion(null);
	}
}

function up_pion (val : GameObject) {
	var i : int;

	i = -1;
	while (++i < nbsoldier) {
		if (!save_soldier[i])
			pions_soldier(i, val);
	}
	i = -1;
	while (++i < nbraider) {
		if (!save_raider[i])
			pions_raider(i, val);
	}
	i = -1;
	while (++i < nbcruiser) {
		if (!save_cruiser[i])
			pions_cruiser(i, val);
	}
	i = -1;
	while (++i < nbhunter) {
		if (!save_hunter[i])
			pions_hunter(i, val);
	}
	i = -1;
	while (++i < nbcommando) {
		if (!save_commando[i])
			pions_commando(i, val);
	}
	i = -1;
	while (++i < nbbomber) {
		if (!save_bomber[i])
			pions_bomber(i, val);
	}
	i = -1;
	while (++i < nbfighter) {
		if (!save_fighter[i])
			pions_fighter(i, val);
	}
	i = -1;
	while (++i < nbdestroyer) {
		if (!save_destroyer[i])
			pions_destroyer(i, val);
	}
}

function Update () {
	if (Application.loadedLevelName == "Battleground") {
		if (start == 0)
			Start();
		if (!nbsoldier && !nbraider && !nbhunter && !nbcruiser && !nbcommando && !nbbomber && !nbfighter && !nbdestroyer
			&& !ressoldier && !resraider && !reshunter && !rescruiser && !rescommando && !resbomber && !resfighter && !resdestroyer
			&& force < 2 && isalive == 1)
			isalive = 2;
		if (isalive == 0)
			this.renderer.enabled = false;
	}
	else
		DontDestroyOnLoad(this);
}
