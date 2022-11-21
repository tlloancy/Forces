#pragma strict

private var spriteRenderer : SpriteRenderer;

var destinationColor : Color;
private var tmpColor : Color;
var speedColor : float;

var destScaleX : float;
var destScaleY : float;
private var destScale : Vector3;
private var tmpScale : Vector3;
var speed : float;

function Start ()
{
	destScale.x = destScaleX;
	destScale.y = destScaleY;
	destScale.z = 0;
	tmpColor = destinationColor;
	tmpScale = destScale;
	spriteRenderer = GetComponent(SpriteRenderer);
}

function Update ()
{
	spriteRenderer.color = Color.Lerp(spriteRenderer.color, tmpColor, speedColor * Time.deltaTime);
	transform.localScale = Vector3.Lerp(transform.localScale, tmpScale, speed * Time.deltaTime);
}