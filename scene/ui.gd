extends CanvasLayer

class_name UI

@onready var center_container: CenterContainer = $MarginContainer/CenterContainer

func game_won():
	print("KLIK: Funkcija game_won() v UI se je uspešno zagnala!")
	
	self.show() 
	center_container.show()
