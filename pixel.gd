extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Igralec": # Prilagodi ime glede na tvojega igralca
		pojdi_pikico()

func pojdi_pikico():
	queue_free() # Ta ukaz izbriše pikico iz igre
