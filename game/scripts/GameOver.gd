extends Node2D

func _on_ButtonRestart_pressed():
	Global.restart_level()

func _on_ButtonQuit_pressed():
	Global.quit_game()
