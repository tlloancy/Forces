private var move : GameObject[];
move = GameObject.FindGameObjectsWithTag("Move");

function deplacement_air (case_name) {
	if (case_name == "HQ_Green") {
		for (var mov : GameObject in move) {
			if (mov.name == "Plains_NW" || mov.name == "Plains_N" || mov.name == "Plains_W" || mov.name == "Plains_C"
				||mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Ice_NW" || mov.name == "Ice_SW" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_NE" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "HQ_Blue") {
		for (var mov : GameObject in move) {
			if (mov.name == "Ice_NE" || mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Plains_NE"
				|| mov.name == "Plains_SE" || mov.name == "Desert_NE" || mov.name == "Desert_NW" || mov.name == "Jungle_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "HQ_Red") {
		for (var mov : GameObject in move) {
			if (mov.name == "Jungle_SW" || mov.name == "Jungle_S" || mov.name == "Jungle_W" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Jungle_SE" || mov.name == "Plains_SE" || mov.name == "Plains_SW" || mov.name == "Desert_NW"
				|| mov.name == "Desert_SW" || mov.name == "Ice_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "HQ_Yellow") {
		for (var mov : GameObject in move) {
			if (mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E" || mov.name == "Desert_C"
				|| mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Ice_SE" || mov.name == "Ice_SW" || mov.name == "Jungle_SE"
				|| mov.name == "Jungle_NE" || mov.name == "Plains_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_C"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_W" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Jungle_SW" || mov.name == "Jungle_S" || mov.name == "Jungle_W"
				|| mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_N" || mov.name == "Ice_C"
				|| mov.name == "Ice_NW" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "HQ_Red"
				|| mov.name == "Desert_C" || mov.name == "Desert_W" || mov.name == "Desert_N" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Ice_N" || mov.name == "Ice_NE" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_E" || mov.name == "Desert_SE"
				|| mov.name == "Desert_S" || mov.name == "Desert_E" || mov.name == "Desert_C" || mov.name == "Desert_NE"
				|| mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Desert_NW"
				|| mov.name == "Plains_N" || mov.name == "Plains_C" ||mov.name == "Plains_NE" || mov.name == "Plains_E"
				|| mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N" || mov.name == "HQ_Yellow")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Jungle_S" || mov.name == "Jungle_SW" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_W" || mov.name == "Jungle_N"
				|| mov.name == "Jungle_SE" || mov.name == "Plains_NW" || mov.name == "Plains_N" || mov.name == "Plains_W"
				|| mov.name == "Plains_C" ||mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW"
				|| mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "Desert_S" || mov.name == "Desert_C"
				|| mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Desert_NW"
				|| mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "HQ_Green")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Desert_S" || mov.name == "Desert_SE" || mov.name == "Desert_C"
				|| mov.name == "Desert_E" || mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Ice_NE" || mov.name == "Ice_N" || mov.name == "Ice_E"
				|| mov.name == "Ice_C" || mov.name == "Ice_NW" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S"
				|| mov.name == "Ice_SE" || mov.name == "Jungle_S" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Plains_C"
				|| mov.name == "Plains_E" || mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "HQ_Blue")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_C"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Jungle_SW" || mov.name == "Jungle_S" || mov.name == "Jungle_W"
				|| mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_N" || mov.name == "Ice_C"
				|| mov.name == "Ice_NW" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S"
				|| mov.name == "Desert_C" || mov.name == "Desert_W" || mov.name == "Desert_N" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Ice_N" || mov.name == "Ice_NE" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Desert_SE"
				|| mov.name == "Desert_S" || mov.name == "Desert_E" || mov.name == "Desert_C" || mov.name == "Desert_NE"
				|| mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Desert_NW"
				|| mov.name == "Plains_N" || mov.name == "Plains_C" ||mov.name == "Plains_NE" || mov.name == "Plains_E"
				|| mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Jungle_S" || mov.name == "Jungle_SW" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Jungle_SE" || mov.name == "Plains_NW" || mov.name == "Plains_N" || mov.name == "Plains_W"
				|| mov.name == "Plains_C" ||mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW"
				|| mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "Desert_S" || mov.name == "Desert_C"
				|| mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Desert_NW"
				|| mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Desert_S" || mov.name == "Desert_SE" || mov.name == "Desert_C"
				|| mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Ice_NE" || mov.name == "Ice_N" || mov.name == "Ice_E"
				|| mov.name == "Ice_C" || mov.name == "Ice_NW" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S"
				|| mov.name == "Ice_SE" || mov.name == "Jungle_S" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Plains_C"
				|| mov.name == "Plains_E" || mov.name == "Plains_S" || mov.name == "Plains_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_NW" || mov.name == "Plains_W" || mov.name == "Plains_C"
				|| mov.name == "Plains_N" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Ice_NE" || mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "HQ_Blue"
				|| mov.name == "Ice_C" || mov.name == "Ice_NW" || mov.name == "Ice_W" || mov.name == "Ice_SW"
				|| mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Jungle_W" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Desert_C" || mov.name == "Desert_W" || mov.name == "Desert_N" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Ice_NE" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_N"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Plains_NW"
				|| mov.name == "Plains_N" || mov.name == "Plains_W" || mov.name == "Plains_C" ||mov.name == "Plains_NE"
				|| mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S" || mov.name == "Plains_SE"
				|| mov.name == "Desert_E" || mov.name == "Desert_C" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_N" || mov.name == "Desert_NW" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N" || mov.name == "HQ_Green")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Jungle_SW" || mov.name == "Jungle_W" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Jungle_S" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_SW"
				|| mov.name == "Desert_N" || mov.name == "Desert_NW" || mov.name == "Plains_W" || mov.name == "Plains_C"
				|| mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S" || mov.name == "Plains_SE"
				|| mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "HQ_Yellow")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Desert_SE" || mov.name == "Desert_E" || mov.name == "Desert_C"
				|| mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_S" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Jungle_SW" || mov.name == "Jungle_S" || mov.name == "Jungle_W"
				|| mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_E" || mov.name == "Ice_C"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "HQ_Red"
				|| mov.name == "Plains_C" || mov.name == "Plains_E" || mov.name == "Plains_S" || mov.name == "Plains_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_NW" || mov.name == "Plains_W" || mov.name == "Plains_C"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Ice_NE" || mov.name == "Ice_N" || mov.name == "Ice_E"
				|| mov.name == "Ice_C" || mov.name == "Ice_NW" || mov.name == "Ice_W" || mov.name == "Ice_SW"
				|| mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Jungle_W" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Desert_C" || mov.name == "Desert_W" || mov.name == "Desert_N" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Ice_NE" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Plains_NW"
				|| mov.name == "Plains_N" || mov.name == "Plains_W" || mov.name == "Plains_C" ||mov.name == "Plains_NE"
				|| mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S" || mov.name == "Plains_SE"
				|| mov.name == "Desert_E" || mov.name == "Desert_C" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_N" || mov.name == "Desert_NW" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Jungle_SW" || mov.name == "Jungle_W" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Jungle_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_SW"
				|| mov.name == "Desert_N" || mov.name == "Desert_NW" || mov.name == "Plains_W" || mov.name == "Plains_C"
				|| mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S" || mov.name == "Plains_SE"
				|| mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Desert_SE" || mov.name == "Desert_E" || mov.name == "Desert_C"
				|| mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Jungle_SW" || mov.name == "Jungle_S" || mov.name == "Jungle_W"
				|| mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_E" || mov.name == "Ice_C"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE"
				|| mov.name == "Plains_C" || mov.name == "Plains_E" || mov.name == "Plains_S" || mov.name == "Plains_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_N" || mov.name == "Plains_W" || mov.name == "Plains_C"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Ice_N" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Jungle_W"
				|| mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_N" || mov.name == "Desert_C" || mov.name == "Desert_W" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE" || mov.name == "Plains_N"
				|| mov.name == "Plains_C" ||mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_N" || mov.name == "Desert_E" || mov.name == "Desert_C" || mov.name == "Desert_NE"
				|| mov.name == "Desert_W" || mov.name == "Desert_N" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Jungle_S" || mov.name == "Jungle_W" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NE" || mov.name == "Jungle_E" || mov.name == "Jungle_NW" || mov.name == "Jungle_N"
				|| mov.name == "Jungle_SE" || mov.name == "Plains_W" || mov.name == "Plains_C" || mov.name == "Plains_E"
				|| mov.name == "Plains_SW" || mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "Desert_S"
				|| mov.name == "Desert_C" || mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Desert_S" || mov.name == "Desert_E" || mov.name == "Desert_C"
				|| mov.name == "Desert_NE" || mov.name == "Desert_W" || mov.name == "Desert_SW" || mov.name == "Desert_N"
				|| mov.name == "Desert_NW" || mov.name == "Jungle_S" || mov.name == "Jungle_C" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_E" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_E"
				|| mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE"
				|| mov.name == "Plains_C" || mov.name == "Plains_E" || mov.name == "Plains_S" || mov.name == "Plains_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_C") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_C") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Plains_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_C") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Plains_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_C") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Plains_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_C" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Plains_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_C" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Plains_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Plains_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_C"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "HQ_Red" || mov.name == "HQ_Green" || mov.name == "HQ_Yellow"
				|| mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_C" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_E" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "HQ_Red" || mov.name == "HQ_Green" || mov.name == "HQ_Yellow"
				|| mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Plains_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_C" || mov.name == "Ice_W" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "HQ_Red" || mov.name == "HQ_Green" || mov.name == "HQ_Yellow"
				|| mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Plains_C" || mov.name == "Jungle_E" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "HQ_Red" || mov.name == "HQ_Green" || mov.name == "HQ_Yellow"
				|| mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Plains_C" || mov.name == "Desert_W" || mov.name == "Desert_NE" || mov.name == "Desert_C"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_C" || mov.name == "Plains_SW" || mov.name == "Plains_E"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Plains_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_C" || mov.name == "Ice_SW" || mov.name == "Ice_W" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Desert_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_W"
				|| mov.name == "Desert_SW" || mov.name == "Desert_N" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Plains_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_C"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_E" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Plains_N" || mov.name == "Plains_NW" || mov.name == "Plains_W"
				|| mov.name == "Plains_NE" || mov.name == "Plains_E" || mov.name == "Plains_SW" || mov.name == "Plains_S"
				|| mov.name == "Plains_SE" || mov.name == "Desert_SE" || mov.name == "Desert_S" || mov.name == "Desert_E"
				|| mov.name == "Plains_C" || mov.name == "Desert_NW" || mov.name == "Desert_NE" || mov.name == "Desert_C"
				|| mov.name == "Desert_SW" || mov.name == "Desert_W" || mov.name == "Jungle_SW" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W" || mov.name == "Jungle_C" || mov.name == "Jungle_NE" || mov.name == "Jungle_E"
				|| mov.name == "Jungle_NW" || mov.name == "Jungle_N" || mov.name == "Jungle_SE" || mov.name == "Ice_NE"
				|| mov.name == "Ice_N" || mov.name == "Ice_E" || mov.name == "Ice_C" || mov.name == "Ice_NW"
				|| mov.name == "Ice_W" || mov.name == "Ice_SW" || mov.name == "Ice_S" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
}
