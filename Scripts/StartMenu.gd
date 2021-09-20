extends Control

func _on_StartButon_pressed():
	get_tree().change_scene("res://Levels/Level_1.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
