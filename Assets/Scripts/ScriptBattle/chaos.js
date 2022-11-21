private var script_orders : orders ;
private var script_allChoose : allChoose;
private var butt : infoButtons;

private var ia_blue : GameObject;
private var ia_red : GameObject;
private var ia_yellow : GameObject;
//private var banner : ADBannerView = null;

function Start()
{
//	banner = ADBannerView(ADBannerView.Type.Banner, ADBannerView.Layout.Top);
	script_orders = GameObject.Find("0 - Decor").GetComponent(orders);
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

function exe_all_ordre_color(script_info : allInfo, ia_color : GameObject, scriptname : String)
{
	if (scriptname == "blue")
		var script : ScriptIA_blue = ia_blue.GetComponent(ScriptIA_blue);
	else if (scriptname == "red")
		var scriptred : ScriptIA_red = ia_red.GetComponent(ScriptIA_red);
	else if (scriptname == "yellow")
		var scriptyellow : ScriptIA_yellow = ia_yellow.GetComponent(ScriptIA_yellow);
	if (script_info.isalive == 1) {
		if (ia_color) {
			if (scriptname == "blue") {
				script.exe_all_ordre();
				while (!script.wait_exe)
					yield WaitForSeconds(1);
			}
			else if (scriptname == "red") {
				scriptred.exe_all_ordre();
				while (!scriptred.wait_exe)
					yield WaitForSeconds(1);
			}
			else if (scriptname == "yellow") {
				scriptyellow.exe_all_ordre();
				while (!scriptyellow.wait_exe)
					yield WaitForSeconds(1);
			}
		}
	}
	script_allChoose.wait_exebis = 1;
}

function collect_force_color(script_info : allInfo, ia_color : GameObject, scriptname : String)
{
	if (scriptname == "blue")
		var script : ScriptIA_blue = ia_blue.GetComponent(ScriptIA_blue);
	else if (scriptname == "red")
		var scriptred : ScriptIA_red = ia_red.GetComponent(ScriptIA_red);
	else if (scriptname == "yellow")
		var scriptyellow : ScriptIA_yellow = ia_yellow.GetComponent(ScriptIA_yellow);
	if (script_info.isalive) {
		yield WaitForSeconds(0.1);
		if (ia_color) {
			if (scriptname == "blue") {
				script.collect_force();
				script.ordre = 1;
			}
			else if (scriptname == "red") {
				scriptred.collect_force();
				scriptred.ordre = 1;
			}
			else if (scriptname == "yellow") {
				scriptyellow.collect_force();
				scriptyellow.ordre = 1;
			}
		}
	}
}

function execution_all_ordre (script1 : allInfo, script2 : allInfo, script3 : allInfo, script4 : allInfo)
{
//	banner.visible = true;
	script_allChoose.ia++;
	if (ia_blue) {
		if (script_allChoose.iablue)
			script_allChoose.iablue.recup_ordre();
	}
	if (ia_red) {
		yield WaitForSeconds(0.1);
		if (script_allChoose.iared)
			script_allChoose.iared.recup_ordre();
	}
	if (ia_yellow) {
		yield WaitForSeconds(0.1);
		if (script_allChoose.iayellow)
			script_allChoose.iayellow.recup_ordre();
	}

	script_allChoose.wait_exe = 0;
	butt.exe_all_ordre();
	while (!script_allChoose.wait_exe)
		yield WaitForSeconds(1);
	if (ia_blue) {
		script_allChoose.wait_exebis = 0;
		exe_all_ordre_color(script2, ia_blue, "blue");
		while (!script_allChoose.wait_exebis)
			yield WaitForSeconds(1);
	}
	else {
		script_allChoose.wait_exe = 0;
		script_allChoose.wait_for_order_blue = 1;
		while (!script_allChoose.wait_exe)
			yield WaitForSeconds(1);
		script_allChoose.wait_for_order_blue = 0;
	}
	if (ia_red) {
		script_allChoose.wait_exebis = 0;
		exe_all_ordre_color(script3, ia_red, "red");
		while (!script_allChoose.wait_exebis)
			yield WaitForSeconds(1);
	}
	else {
		script_allChoose.wait_exe = 0;
		script_allChoose.wait_for_order_red = 1;
		while (!script_allChoose.wait_exe)
			yield WaitForSeconds(1);
		script_allChoose.wait_for_order_red = 0;
	}
	if (ia_yellow) {
		script_allChoose.wait_exebis = 0;
		exe_all_ordre_color(script4, ia_yellow, "yellow");
		while (!script_allChoose.wait_exebis)
			yield WaitForSeconds(1);
	}
	else {
		script_allChoose.wait_exe = 0;
		script_allChoose.wait_for_order_yellow = 1;
		while (!script_allChoose.wait_exe)
			yield WaitForSeconds(1);
		script_allChoose.wait_for_order_yellow = 0;
	}

	yield WaitForSeconds(1);
	script_allChoose.wait_fight = 0;
	script_orders.exe_fight(script1, script2, script3, script4);
	while (!script_allChoose.wait_fight)
		yield WaitForSeconds(1);

	script_allChoose.collect_force(script_allChoose.scriptinfo);
	if (ia_blue)
		collect_force_color(script2, ia_blue, "blue");
	if (ia_red)
		collect_force_color(script3, ia_red, "red");
	if (ia_yellow)
		collect_force_color(script4, ia_yellow, "yellow");
		
	yield WaitForSeconds(0.1);
	butt.ordre = 1;
	butt.nbcount = 1;
	butt.exe = 0;
	GameObject.Find("ScriptSF").GetComponent(AnimateGnrl).destroy();
	butt.reserve_button();
//	banner.visible = false;
}

function Uptdate () {
}