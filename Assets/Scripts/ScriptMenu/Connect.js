import LostPolygon.System.Net;

private var matchIP : String;
private var matchPort : int;
private var join : GameObject;
private var create : GameObject;
private var server_menu : GameObject;
private var server : boolean;
var cam : GameObject;
var maxClients : int;

var letsgo_obj : GameObject;
private var letsgo_inst : GameObject;

var obj_script : GameObject;
private var object_script : GameObject;

//multicast
private var startup_port : int = 8100;
private var group_address : IPAddress = IPAddress.Parse ("224.0.0.224");
private var udp_client : LostPolygon.System.Net.Sockets.UdpClient;
private var remote_end : IPEndPoint;

var ScriptsEffects : SoundEffectsHelper;

function Start () 
{
	ScriptsEffects = GameObject.Find("ScriptSF").GetComponent(SoundEffectsHelper);
	var script = GetComponent(GeneralMenu);
	matchPort = 8000;
	maxClients = 32;
	join = script.join;
	create = script.create;
	server_menu = script.server_menu;
}

function Update () 
{
	switch (Network.peerType)
	{
		//ce qui est affiché lorsqu'on démarre le jeu, ou lorsqu'on est déconnecté
		case NetworkPeerType.Disconnected :
			Disconnected();
			break;
			//ce qui est affiché lorsqu'on est connecté au serveur en tant que Client
		case NetworkPeerType.Client :
			Client();
			break;
			//ce qui est affiché lorsqu'on est celui qui a initialisé le serveur
		case NetworkPeerType.Server :
			Server();
			break;
			//ce qui est affiché lorsqu'on est entrain de se connecter au serveur.
		case NetworkPeerType.Connecting :
			Connecting();
			break;
	}
}

function Count_And_Go(second : int, txt : GameObject, str : String)
{
	var i = second;
	while (i != -1)
	{
		if (txt == null)
			break ;
		txt.GetComponent(TextMesh).text = str + i;
		yield WaitForSeconds(1);
		i--;
	}
	if (txt != null)
		Application.LoadLevel("Battleground");
	DontDestroyOnLoad(ScriptsEffects);
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
		&& pos.origin.y < (object.transform.position.y + height)
		&& (!GameObject.Find("Waiting_Room(Clone)") || !server_menu.activeInHierarchy))
		return (true);
	return (false);
}

function OnFailedToConnect(error : NetworkConnectionError)
{
	var error2 = "Could not connect to server: "+ error;
	var txt_error = GameObject.Find("Error");
	var script = GetComponent(GeneralMenu);
	
	if (error2 != "Could not connect to server: NoError")
	{
		//print(error2);
		txt_error.GetComponent(TextMesh).color = Color.red;
		txt_error.GetComponent(TextMesh).text = error2;
		if (script.server_menu.activeInHierarchy)
			script.server_menu.gameObject.SetActive(false);
		yield WaitForSeconds(3);
//		if (script.server_menu.activeInHierarchy)
//			script.server_menu.gameObject.SetActive(false);
		script.gnrl_menu.gameObject.SetActive(true);
		txt_error.GetComponent(TextMesh).text = "";
	}
}

function Destroy_all_clones(server : boolean)
{
	var letsgo_network = GameObject.Find("Letsgo(Clone)");
	var room_network = GameObject.Find("Waiting_Room(Clone)");
	var config_network = GameObject.Find("ConfigGame_Object(Clone)");
	var playerconfig_network = GameObject.Find("PlayersConfig(Clone)");
	var players = GameObject.FindGameObjectsWithTag("Player");
	
	Destroy(room_network, 0);
	if (letsgo_network != null)
		Network.Destroy(letsgo_network);
	if (playerconfig_network != null)
		Destroy(playerconfig_network, 0);
	if (config_network != null)
		Network.Destroy(config_network);
	if (server)
	{
		for (var player : GameObject in players)
			Network.Destroy(player);
	}
/*	else
	{
		
	}*/
}

function OnDisconnectedFromServer(info : NetworkDisconnection) 
{
	var txt_error = GameObject.Find("Error");
	var script = GetComponent(GeneralMenu);
	txt_error.GetComponent(TextMesh).color = Color.white;
	
	if (Network.isServer)
	{
		Destroy_all_clones(true);
		txt_error.GetComponent(TextMesh).text ="Local server connection disconnected";
	}
	else
	{
		Destroy_all_clones(false);
		if (info == NetworkDisconnection.LostConnection)
			txt_error.GetComponent(TextMesh).text = "Lost connection to the server";
		else
			txt_error.GetComponent(TextMesh).text = "Successfully disconnected from the server";
	}
	yield WaitForSeconds(3);
	script.gnrl_menu.gameObject.SetActive(true);
	txt_error.GetComponent(TextMesh).text = "";
}

function nbrClients()
{
	var grp_onglets = GameObject.FindGameObjectsWithTag("Onglet");
	var nbr_Clients = 0;
	
	for (var onglets : GameObject in grp_onglets)
	{
		if (onglets.renderer.enabled == true)
		{
			if (onglets.transform.name.IndexOf("player") != -1)
				nbr_Clients++;
		}
	}
	return (nbr_Clients);
}

function Disconnected()
{
//	var useNat : boolean;
	var script = GetComponent(GeneralMenu);
	var txt_error = GameObject.Find("Error");
	var error : NetworkConnectionError;
	//var ipadress : IPAddress = IPAddress.Parse("192.168.56.2");//"169.254.246.56");//;IPAddress.Parse(Network.player.ipAddress);print("ipc");
	//remote_end = null;
	
//					MODE BETA TEST CLIENT DESACTIVER
/*	if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(join)) //CLIENT
	{
		// multicast receive setup
		remote_end = IPEndPoint (IPAddress.Any, startup_port);
		// Pas de remote_end dans la fonction UdpClient() mais dans le Bind
		udp_client = LostPolygon.System.Net.Sockets.UdpClient ();
		udp_client.Client.SetSocketOption(LostPolygon.System.Net.Sockets.SocketOptionLevel.Socket, LostPolygon.System.Net.Sockets.SocketOptionName.ReuseAddress, true);
		udp_client.Client.Bind(remote_end);
		//async callback for multicast
		udp_client.BeginReceive (new System.AsyncCallback (ServerLookup), null);
		while (!matchIP)
			yield;
//		if (matchIP) {
			script.gnrl_menu.SetActive(false);
			error = Network.Connect(matchIP, matchPort);
			txt_error.GetComponent(TextMesh).color = Color.white;
			txt_error.GetComponent(TextMesh).text = "Connecting...";
			OnFailedToConnect(error);
//		}
	}*/
	if (script.server_menu.activeInHierarchy && Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(create)) //SERVEUR : Bouton d'initialisation du serveur
	{
		yield WaitForSeconds(0.07);
		//useNat = !Network.HavePublicAddress();
		maxClients = nbrClients();
		//print("MaxClients : " + maxClients);
		error = Network.InitializeServer(maxClients, matchPort, false);
		//var ipaddress = Network.player.ipAddress;
		OnFailedToConnect(error);
		StartBroadcast ();
	}
}

function color_player()
{
	if (object_script == null)
	{
		object_script = Network.Instantiate(obj_script, transform.position, Quaternion.identity, 0);
		var script = object_script.GetComponent(EveryoneColor);
		//print("cucu");
		script.whoiam();
	}
}

function Client()
{
	var txt_error = GameObject.Find("Error");
	var letsgo_network = GameObject.Find("Letsgo(Clone)");
	var wait = GameObject.Find("Waiting_Room(Clone)/Waiting...");
	var cancel = GameObject.Find("Waiting_Room(Clone)/Cancel");
	
	txt_error.GetComponent(TextMesh).text = "";
	color_player();
	if (letsgo_network != null && wait != null)
	{
		Count_And_Go(3, wait, "Get ready! ");	
	}
	if ((Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(cancel)) /*|| (fhbjsh)*/)
	{
		Network.Disconnect();
	}
	

}

function Server()
{
	var script = GetComponent(GeneralMenu);
	var letsgo_button = GameObject.Find("Waiting_Room(Clone)/LetsGo");
	var wait = GameObject.Find("Waiting_Room(Clone)/Waiting...");
	var cancel = GameObject.Find("Waiting_Room(Clone)/Cancel");
	
	color_player();
	//Joueurs présents
	if (script.players == Network.connections.Length)
	{
		if (wait && !letsgo_inst)									//par sécurite car parfois il lance une erreur
			wait.GetComponent(TextMesh).text = "Let's go ?";
		if (letsgo_button)							//par sécurite car parfois il lance une erreur
			letsgo_button.renderer.enabled = true;
		yield WaitForSeconds(1);
		if (letsgo_button && Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(letsgo_button) && letsgo_inst == null && wait != null)
		{
			ScriptsEffects.Instance.sounds(1);	
			letsgo_inst = Network.Instantiate(letsgo_obj, transform.position, Quaternion.identity, 0);
			wait.transform.position.x = -2.76;
			Count_And_Go(3, wait, "Get ready! ");
		}
	}
	else //Joueurs absents
	{
		if (wait)									//par sécurite car parfois il lance une erreur
			wait.GetComponent(TextMesh).text = "Waiting ...";
		if (letsgo_button)							//par sécurite car parfois il lance une erreur
			letsgo_button.renderer.enabled = false;
	}
	
	//Arret de la salle d'attente et Deconnection du serveur
	if (Input.GetKeyDown(KeyCode.Mouse0) && Zone_Click(cancel))
	{
		Network.Disconnect();
	}
}

function Connecting()
{

}

/******* broadcast functions *******/
function ServerLookup (ar : System.IAsyncResult)//System.ComponentModel.ISynchronizeInvoke)
{
	// receivers package and identifies ip
	var receiveBytes = udp_client.EndReceive (ar, remote_end);

	matchIP = remote_end.Address.ToString ();
//	Debug.Log("Server :" + matchIP);
}

function StartBroadcast ()
{
	//multicast send setup
	//var ok : IPAddress = IPAddress.Parse("169.254.0.255");
	//var mine : IPAddress = IPAddress.Parse(Network.player.ipAddress);
	//var first = IPEndPoint(mine, startup_port);//ar
	udp_client = LostPolygon.System.Net.Sockets.UdpClient ();// first 
	////////////////////////////////////////udp_client.JoinMulticastGroup (group_address);
	remote_end = IPEndPoint (IPAddress.Broadcast/*group_address*/, startup_port);// En fait ici si l'on laisse group_address je ne comprends pas
	// ou ca part car le client ecoute son interface il n ecoute pas  d ip multicast UN TRUC M ECHAPPE VOILA POURQUOI JE BROADCAST COMME BROD LESN
	//sends multicast //surement une histoire de routage avec l'interface wifi qui de fait est sensée être atteinte directement en broadcast
	var cancel = GameObject.Find("Waiting_Room(Clone)/Cancel");
	while (true)
	{
		var buffer = System.Text.Encoding.ASCII.GetBytes ("GameServer");
		udp_client.Send (buffer, buffer.Length, remote_end);
//		print("" + remote_end);
		yield WaitForSeconds (1);
		if (Network.peerType == NetworkPeerType.Disconnected)
			break ;			
	}
}