private var move : GameObject[];
move = GameObject.FindGameObjectsWithTag("Move");

function deplacement_mer (case_name) {
	if (case_name == "HQ_Green") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_6" || mov.name == "Space_5" || mov.name == "Plains_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "HQ_Blue") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_7" || mov.name == "Space_8" || mov.name == "Ice_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "HQ_Red") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_12" || mov.name == "Space_11" || mov.name == "Jungle_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "HQ_Yellow") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_10" || mov.name == "Space_9" || mov.name == "Desert_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_5" || mov.name == "Space_6" || mov.name == "HQ_Green" || mov.name == "Plains_N"
				|| mov.name == "Plains_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_7" || mov.name == "Space_8" || mov.name == "HQ_Blue" || mov.name == "Ice_N" || mov.name == "Ice_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_11" || mov.name == "Space_12" || mov.name == "HQ_Red" || mov.name == "Jungle_S"
				|| mov.name == "Jungle_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_9" || mov.name == "Space_10" || mov.name == "HQ_Yellow" || mov.name == "Desert_S"
				|| mov.name == "Desert_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_6" || mov.name == "Plains_NE" || mov.name == "Plains_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_7" || mov.name == "Ice_NE" || mov.name == "Ice_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_11" || mov.name == "Jungle_SE" || mov.name == "Jungle_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_10" || mov.name == "Desert_SE" || mov.name == "Desert_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Space_6" || mov.name == "Moon_N" || mov.name == "Plains_N" || mov.name == "Plains_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Space_7" || mov.name == "Moon_N" || mov.name == "Ice_N" || mov.name == "Ice_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_3" || mov.name == "Space_11" || mov.name == "Moon_S" || mov.name == "Jungle_S" || mov.name == "Jungle_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_3" || mov.name == "Space_10" || mov.name == "Moon_S" || mov.name == "Desert_S" || mov.name == "Desert_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_5" || mov.name == "Plains_NW" || mov.name == "Plains_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_8" || mov.name == "Ice_SE" || mov.name == "Ice_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_12" || mov.name == "Jungle_SW" || mov.name == "Jungle_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_9" || mov.name == "Desert_SE" || mov.name == "Desert_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Plains_NE" || mov.name == "Plains_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Ice_SW" || mov.name == "Ice_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_3" || mov.name == "Jungle_SE" || mov.name == "Jungle_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_3" || mov.name == "Desert_SW" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_4" || mov.name == "Space_5" || mov.name == "Moon_W" || mov.name == "Plains_S" || mov.name == "Plains_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_2" || mov.name == "Space_8" || mov.name == "Moon_E" || mov.name == "Ice_S" || mov.name == "Ice_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_4" || mov.name == "Space_12" || mov.name == "Moon_W" || mov.name == "Jungle_N" || mov.name == "Jungle_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_2" || mov.name == "Space_9" || mov.name == "Moon_E" || mov.name == "Desert_N" || mov.name == "Desert_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_4" || mov.name == "Plains_SE" || mov.name == "Plains_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_2" || mov.name == "Ice_SE" || mov.name == "Ice_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_4" || mov.name == "Jungle_NE" || mov.name == "Jungle_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_2" || mov.name == "Desert_NE" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Plains_SE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Space_4" || mov.name == "Sun" || mov.name == "Plains_S" || mov.name == "Plains_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Ice_SW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Space_2" || mov.name == "Sun" || mov.name == "Ice_S" || mov.name == "Ice_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Jungle_NE") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_3" || mov.name == "Space_4" || mov.name == "Sun" || mov.name == "Jungle_N" || mov.name == "Jungle_E")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Desert_NW") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_2" || mov.name == "Space_3" || mov.name == "Sun" || mov.name == "Desert_N" || mov.name == "Desert_W")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Moon_N") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Space_6" || mov.name == "Space_7" || mov.name == "Plains_NE"
				|| mov.name == "Ice_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Moon_S") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_3" || mov.name == "Space_10" || mov.name == "Space_11" || mov.name == "Jungle_SE"
				|| mov.name == "Desert_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Moon_W") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_4" || mov.name == "Space_5" || mov.name == "Space_12" || mov.name == "Plains_SW"
				|| mov.name == "Jungle_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Moon_E") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_2" || mov.name == "Space_8" || mov.name == "Space_9" || mov.name == "Ice_SE"
				|| mov.name == "Desert_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Sun") {
		for (var mov : GameObject in move) {
			if (mov.name == "Space_1" || mov.name == "Space_2" || mov.name == "Space_3" || mov.name == "Space_4"
				|| mov.name == "Plains_SE" || mov.name == "Ice_SW" || mov.name == "Desert_NW" || mov.name == "Jungle_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_1") {
		for (var mov : GameObject in move) {
			if (mov.name == "Sun" || mov.name == "Moon_N" || mov.name == "Plains_E" || mov.name == "Plains_SE"
				|| mov.name == "Plains_NE" || mov.name == "Ice_W" || mov.name == "Ice_NW" || mov.name == "Ice_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_2") {
		for (var mov : GameObject in move) {
			if (mov.name == "Sun" || mov.name == "Moon_E" || mov.name == "Ice_S" || mov.name == "Ice_SE"
				|| mov.name == "Ice_SW" || mov.name == "Desert_N" || mov.name == "Desert_NE" || mov.name == "Desert_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_3") {
		for (var mov : GameObject in move) {
			if (mov.name == "Sun" || mov.name == "Moon_S" || mov.name == "Desert_W" || mov.name == "Desert_NW"
				|| mov.name == "Desert_SW" || mov.name == "Jungle_E" || mov.name == "Jungle_NE" || mov.name == "Jungle_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_4") {
		for (var mov : GameObject in move) {
			if (mov.name == "Sun" || mov.name == "Moon_W" || mov.name == "Jungle_N" || mov.name == "Jungle_NE"
				|| mov.name == "Jungle_NW" || mov.name == "Plains_S" || mov.name == "Plains_SE" || mov.name == "Plains_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_5") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Moon_W" || mov.name == "Plains_W" || mov.name == "Plains_NW"
				|| mov.name == "Plains_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_6") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Green" || mov.name == "Moon_N" || mov.name == "Plains_NW" || mov.name == "Plains_N"
				|| mov.name == "Plains_NE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_7") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Moon_N" || mov.name == "Ice_N" || mov.name == "Ice_NE" || mov.name == "Ice_NW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_8") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Blue" || mov.name == "Moon_E" || mov.name == "Ice_E" || mov.name == "Ice_NE" || mov.name == "Ice_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_9") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Moon_E" || mov.name == "Desert_E" || mov.name == "Desert_NE"
				|| mov.name == "Desert_SE")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_10") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Yellow" || mov.name == "Moon_S" || mov.name == "Desert_S" || mov.name == "Desert_SE"
				|| mov.name == "Desert_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_11") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Moon_S" || mov.name == "Jungle_S" || mov.name == "Jungle_SE"
				|| mov.name == "Jungle_SW")
				mov.renderer.enabled = true;
		}
	}
	else if (case_name == "Space_12") {
		for (var mov : GameObject in move) {
			if (mov.name == "HQ_Red" || mov.name == "Moon_W" || mov.name == "Jungle_W" || mov.name == "Jungle_NW"
				|| mov.name == "Jungle_SW")
				mov.renderer.enabled = true;
		}
	}
}
