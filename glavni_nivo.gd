extends TileMap

# Ta vrstica ustvari polje v Inspectorju
@export var pixel_scena: PackedScene 

func _ready() -> void:
	generiraj_pikice()

func generiraj_pikice() -> void:
	var vse_celice = get_used_cells(0)
	
	for celica in vse_celice:
		var tile_data = get_cell_tile_data(0, celica)
		
		if tile_data:
			var je_pot = tile_data.get_custom_data("je_pot")
			
			if je_pot:
				var nova_pika = pixel_scena.instantiate()
				
				nova_pika.position = map_to_local(celica)
				
				add_child(nova_pika)
