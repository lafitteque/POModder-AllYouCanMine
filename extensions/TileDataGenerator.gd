extends "res://content/map/generation/TileDataGenerator.gd"

const TILE_DETONATOR = 11
const TILE_DESTROYER = 12
const TILE_MEGA_IRON = 13

var data_mod



func get_generation_data(a):
	## 4th to 7th decimals are for detonator rate
	print("raw data : ", a.max_tile_count_deviation)
	var detonator_rate = a.max_tile_count_deviation*10**(4-1) 
	detonator_rate -= int(detonator_rate)
	detonator_rate *= 100
	print("raw 1 " , detonator_rate)
	## 8th to 11th decimals are for destroyer rate
	var destroyer_rate = detonator_rate*100
	destroyer_rate -= int(destroyer_rate)
	destroyer_rate *= 100
	print("raw 2 " , destroyer_rate)
	## 12th to 15th decimals are for mega iron rate
	var mega_iron_rate = destroyer_rate*100
	mega_iron_rate -= int(mega_iron_rate)
	mega_iron_rate *= 100
	print("raw 3 " , mega_iron_rate)
	detonator_rate = round(detonator_rate*100)/100
	destroyer_rate = round(destroyer_rate*100)/100
	mega_iron_rate = round(mega_iron_rate*100)/100
	
	return [detonator_rate , mega_iron_rate , mega_iron_rate]
	
func generate_resources(rand):
	super.generate_resources(rand)
	
	
	var original_cell_coords:Array = $MapData.get_used_biome_cells()
	var borderCells = findOutsideBorderCells()
	var ironClusterCenters = $MapData.get_resource_cells_by_id(Data.TILE_IRON).duplicate()
	
	var rates = get_generation_data(a)
	var detonator_rate = rates[0]
	var destroyer_rate = rates[1]
	var mega_iron_rate = rates[2]
	
	print('detonator rate : ' , detonator_rate)
	generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells,detonator_rate, TILE_DETONATOR)
	
	print('destroyer rate : ' , destroyer_rate)
	generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells,destroyer_rate, TILE_DESTROYER)
	
	print('mega_iron rate : ' , mega_iron_rate)
	generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells,mega_iron_rate, TILE_MEGA_IRON)

func generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells, type_rate,typeId):
	 # encode detonator_rate in digits 4 , 5 , 6 , 7 after the comma. reads as 45.67
	var typeAmount = round(type_rate * 0.001 * original_cell_coords.size())
	var availableCells = $MapData.get_resource_cells_by_id(Data.TILE_DIRT_START)
	Utils.shuffle(availableCells,rand)
	var freeTileIndex = 0
	for _j in typeAmount:
		$MapData.set_resourcev(availableCells[freeTileIndex], typeId)
		print("reussi à générer : " , typeId)
		freeTileIndex += 1
	var iterations = 100
	var totalMove = Vector2()
	var averagedLastTotalMoves = Vector2()
	var zeroMoves = 0
	
	for iteration in iterations:
		var typeTiles = $MapData.get_resource_cells_by_id(typeId)
		Utils.shuffle(ironClusterCenters,rand)
		for tileCoord in typeTiles:
			var sum := Vector2()
			for otherCoord in typeTiles:
				if otherCoord == tileCoord:
					continue
				var strength = 100 + round(otherCoord.y * 2.0)
				var delta = tileCoord - otherCoord
				var mod = strength / pow(delta.length(), 2)
				if mod < 0.01:
					continue
				sum += (Vector2(delta).normalized()) * mod
			for otherCoord in ironClusterCenters:
				var strength = 10
				var delta = tileCoord - otherCoord
				var mod = strength / pow(delta.length(), 2)
				if mod < 0.001:
					continue
				sum += (Vector2(delta).normalized()) * mod
			for borderCell in borderCells:
				var strength = 20
				var delta = tileCoord - borderCell
				var mod = strength / pow(delta.length(), 3)
				if mod < 0.001:
					continue
				sum += (Vector2(delta).normalized()) * mod
			if sum.length() > 0.2:
				sum = sum.normalized()
			sum.x = round(sum.x)
			sum.y = round(sum.y)
			if $MapData.get_resourcev(Vector2(tileCoord) + sum) == Data.TILE_DIRT_START:
				totalMove += sum
				moveResource(tileCoord, sum.x, sum.y, 2)
		
		averagedLastTotalMoves = averagedLastTotalMoves * 0.5 + totalMove * 0.5
		if (totalMove - averagedLastTotalMoves).length() < 1.0:
			zeroMoves += 1
			if zeroMoves >= 5:
				break
