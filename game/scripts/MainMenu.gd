extends Node

func _ready():
	SFX_Manager.music("tryne-loopable")

func _on_Quit_pressed():
	print("Quit")
	Global.quit_game()

func _on_NewGame_pressed():
	print("Newgame")
	SFX_Manager.music("honkeytonk-loopable")
	Global.load_scene("Test-Level")
