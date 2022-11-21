#pragma strict

var display_calcul : boolean;
private var check : GameObject[];
private var check2 : GameObject[];

function Start () 
{
	check = FindObjectsOfType(GameObject);
	check2 = GameObject.FindGameObjectsWithTag("Button_Info");
}

function Update ()
{
	/*************************************************************/
	/**			Calcul des images en pixel actuel et futur 		**/
	/*************************************************************/
		if (display_calcul)
		{
			calcul();
			display_calcul = false;
		}
	/*************************************************************/
}/*
function Start () {
		var go = new GameObject.CreatePrimitive(PrimitiveType.Cube);
		go.renderer.material.mainTexture = Resources.Load("glass", Texture2D);
	}
	*/
function calcul()
{
	var sp_rend : SpriteRenderer;
	
	yield WaitForSeconds(3);
	for (var sp_obj : GameObject in check)
	{
		sp_rend = sp_obj.GetComponent(SpriteRenderer);
		
		if (sp_obj != null && sp_rend != null)
		{
			if (sp_rend.sprite.name != null)
			{
				print("Nom de l'image : " + sp_rend.sprite.name);
				print("Taille actuel en px (hauteur X largeur) : " + sp_rend.sprite.rect.height + " x " + sp_rend.sprite.rect.width);
				//print("Taille futur en px (hauteur X largeur) : " + sp_obj.transform.lossyScale.x * 200 + " x " + sp_obj.transform.lossyScale.y * 200);
				print("-----------------------------------");
				yield WaitForSeconds(0.1);
			}
		}
	}
}