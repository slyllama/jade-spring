@tool
extends HBoxContainer

@export var title_left = "":
	get: return(title_left)
	set(_v):
		title_left = _v
		$L/TitleL.text = _v
@export var amount_left = -1:
	get: return(amount_left)
	set(_v):
		_v = int(_v)
		amount_left = _v
		if _v >= 0: $L/AmountL.text = str(_v)
		else: $L/AmountL.text = ""

@export var title_right = "":
	get: return(title_right)
	set(_v):
		title_right = _v
		$R/TitleR.text = _v
@export var amount_right = -1:
	get: return(amount_right)
	set(_v):
		_v = int(_v)
		amount_right = _v
		if _v >= 0: $R/AmountR.text = str(_v)
		else: $R/AmountR.text = ""
