extends "res://content/map/generation/TileDataGenerator.gd"

const TILE_DETONATOR = 11
const TILE_DESTROYER = 12
const TILE_MEGA_IRON = 13
const TILE_BAD_RELIC = 14 #QLafitte Added

var data_mod

const detonator_rate_list = [0 , 0.1 , 0.5 , 1 , 5 , 10 , 25 , 50 , 75 ]
const destroyer_rate_list = [0 , 0.1 , 0.5 , 1 , 5 , 10 , 25 , 50 , 75 ]
const mega_iron_rate_list = [0 , 0.1 , 0.5 , 1 , 5 , 10 , 25 , 50 , 75 ]
const drop_bearer_rate_list = [0 , 0.001 , 0.005 , 0.01 , 0.05 , 0.10 , 0.25 , 0.50, 100 ]

func get_generation_data(a):
	## 4th decimal of max_tile_count_deviation for detonator rate
	print("raw data : ", a.max_tile_count_deviation)
	var detonator_rate_index = a.max_tile_count_deviation*10**3
	detonator_rate_index -= int(detonator_rate_index)
	detonator_rate_index *= 10
	detonator_rate_index = round(detonator_rate_index)
	
	## 5th decimal of max_tile_count_deviation decimals for destroyer_rate_index
	var destroyer_rate_index = a.max_tile_count_deviation*10**4
	destroyer_rate_index -= int(destroyer_rate_index)
	destroyer_rate_index *= 10
	destroyer_rate_index = round(destroyer_rate_index)
	
	## 6th decimalsof max_tile_count_deviation for mega_iron_rate_index
	var mega_iron_rate_index = a.max_tile_count_deviation*10**5
	mega_iron_rate_index -= int(mega_iron_rate_index)
	mega_iron_rate_index *= 10
	mega_iron_rate_index = round(mega_iron_rate_index)
	
	## 3rd decimal of viability_thin_top_width for bad_relics
	var bad_relics = a.viability_thin_top_width*10**2
	bad_relics -= int(bad_relics)
	bad_relics *= 10
	bad_relics = round(bad_relics)
	
	var detonator_rate = detonator_rate_list[detonator_rate_index]
	var destroyer_rate = destroyer_rate_list[destroyer_rate_index]
	var mega_iron_rate = mega_iron_rate_list[mega_iron_rate_index]
	
	print("raw max_tile_count_deviation : ", a.max_tile_count_deviation)
	print("computed detonator_rate " , detonator_rate)
	print("computed destroyer_rate " , destroyer_rate)
	print("computed mega_iron_rate " , mega_iron_rate)
	print("computed bad_relics " , bad_relics)
	
	return [detonator_rate , mega_iron_rate , mega_iron_rate, bad_relics]
	
func generate_resources(rand):
	var data_from_mod = get_generation_data(a)
	var detonator_rate = data_from_mod[0]
	var destroyer_rate = data_from_mod[1]
	var mega_iron_rate = data_from_mod[2]
	var bad_relics = data_from_mod[3]
	
	var original_cell_coords:Array = $MapData.get_used_biome_cells()
	var borderCells = findOutsideBorderCells()
	
	for cell in $MapData.get_used_biome_cells():
		if $MapData.get_resourcev(cell) < 0:
			$MapData.set_resourcev(cell, Data.TILE_DIRT_START)
	
	Utils.shuffle(original_cell_coords, rand)
	gen_stage = 4.1
	startTimer("generate_iron_clusters")
	generate_iron_clusters(original_cell_coords, borderCells)
	endTimer()
	gen_stage = 4.2
	startTimer("generate_gadget_chambers")
	generate_gadget_chambers()
	endTimer()
	gen_stage = 4.3
	startTimer("generate_power_cores")
	generate_power_cores()
	endTimer()
	gen_stage = 4.4
	if bad_relics == 0:
		startTimer("generate_relics")
		generate_relics()
	else :
		### Added vvvvvv
		startTimer("generate_bad_relics")
		generate_bad_relics(bad_relics)
		### Added ^^^^^^
		
	endTimer()
	gen_stage = 4.5
	startTimer("adjust_ore_amounts")
	adjust_ore_amounts()
	endTimer()
	gen_stage = 4.6
	startTimer("expand_iron_clusters")
	var ironClusterCenters = $MapData.get_resource_cells_by_id(Data.TILE_IRON).duplicate()
	expand_iron_clusters(ironClusterCenters)
	endTimer()
	gen_stage = 4.7
	startTimer("generate_water")
	generate_water(ironClusterCenters, original_cell_coords, borderCells)
	endTimer()
	gen_stage = 4.8
	startTimer("generate_cobalt")
	generate_cobalt(ironClusterCenters, original_cell_coords, borderCells)
	endTimer()
	gen_stage = 4.9
	startTimer("generate_holes")
	var averageCellCountInBiome = a.tileCount/(maxBiome+1)
	generate_holes(rand, averageCellCountInBiome)
	endTimer()
	
	### Added vvvvvv
	
	
	print('detonator(', TILE_DETONATOR, ') rate : ' , detonator_rate)
	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,detonator_rate, TILE_DETONATOR)
	
	print("detonator total 1 : ", $MapData.get_resource_cells_by_id(TILE_DETONATOR).size())
	print("destroyer total 1 : ", $MapData.get_resource_cells_by_id(TILE_DESTROYER).size())
	print("mega_iron total 1 : ", $MapData.get_resource_cells_by_id(TILE_MEGA_IRON).size())
	
	print('destroyer(', TILE_DESTROYER, ') rate : ' , destroyer_rate)
	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,destroyer_rate, TILE_DESTROYER)
	
	print("detonator total 2 : ", $MapData.get_resource_cells_by_id(TILE_DETONATOR).size())
	print("destroyer total 2 : ", $MapData.get_resource_cells_by_id(TILE_DESTROYER).size())
	print("mega_iron total 2 : ", $MapData.get_resource_cells_by_id(TILE_MEGA_IRON).size())
	
	print('mega_iron(', TILE_MEGA_IRON, ') rate : ' , mega_iron_rate)
	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,mega_iron_rate, TILE_MEGA_IRON)

	print("detonator total 3 : ", $MapData.get_resource_cells_by_id(TILE_DETONATOR).size())
	print("destroyer total 3 : ", $MapData.get_resource_cells_by_id(TILE_DESTROYER).size())
	print("mega_iron total 3 : ", $MapData.get_resource_cells_by_id(TILE_MEGA_IRON).size())
	
	
func generate_bad_relics(badRelics):
# ADD RELIC CHAMBERS
	var remainingBadRelics = badRelics
	var failsafe = 100
	
	var currentRelicStep := 1
	while remainingBadRelics > 0:
		var xLeft = rand.randf_range(a.width * -0.5, a.width * -0.2)
		var xRight = rand.randf_range(a.width * 0.2, a.width * 0.5)
		var offsetY = currentRelicStep * a.relic_depth_step + 2 * max(currentRelicStep - 1, 0) * a.relic_depth_step
		var goalLeft = Vector2(resourceX + xLeft, a.depth - offsetY)
		var goalRight = Vector2(resourceX + xRight, a.depth - offsetY)
		
		failsafe -= 1
		if failsafe <= 0:
			reportError("Failsafe reached: failed to generate relic chamber")
			break
		var ironTiles = $MapData.get_resource_cells_by_id(Data.TILE_IRON)
		var bestCell:Vector2
		var bestD := 999999
		for cell in ironTiles:
			var left = goalLeft - Vector2(cell)
			var right = goalRight - Vector2(cell)
			var best = left if left.length() < right.length() else right
			var d = best.length()
			if d < bestD:
				bestD = d
				bestCell = cell
		
		var placed = tryPlace(TILE_BAD_RELIC, [bestCell, 
		bestCell + Vector2(-1,0),
		bestCell + Vector2(-1,1),
		bestCell + Vector2(0,-1),
		bestCell + Vector2(1,-1),
		bestCell + Vector2(0,1),
		bestCell + Vector2(1,0),
		bestCell + Vector2(1,1),
		bestCell + Vector2(2,0),
		bestCell + Vector2(2,1),
		bestCell + Vector2(0,2),
		bestCell + Vector2(1,2)])
		if placed:
			remainingBadRelics -= 1
			currentRelicStep += 1
			resourceMinY = resourceMinY + a.gadget_depth_step
			var deltaWidth = sign(bestCell.x) * a.width * 0.2 - bestCell.x
			resourceX = -bestCell.x - deltaWidth
			
	
	if remainingBadRelics != 0:
		reportError("Relic generation failed. Failed to place %s relics" % remainingBadRelics)
		
		
func generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells, type_rate,typeId):
	var typeAmount = round(type_rate * 0.001 * original_cell_coords.size())
	var availableCells = $MapData.get_resource_cells_by_id(Data.TILE_DIRT_START)
	Utils.shuffle(availableCells,rand)
	var freeTileIndex = 0
	for _j in typeAmount:
		$MapData.set_resourcev(availableCells[freeTileIndex], typeId)
		freeTileIndex += 1
	var iterations = 100
	var totalMove = Vector2()
	var averagedLastTotalMoves = Vector2()
	var zeroMoves = 0
	
