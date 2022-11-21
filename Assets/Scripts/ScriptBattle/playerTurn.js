var cam : GameObject;

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
