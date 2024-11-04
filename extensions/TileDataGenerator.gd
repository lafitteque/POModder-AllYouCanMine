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
	
	#20th decimal is for bad relics number
	var bad_relics = mega_iron_rate*10**6
	bad_relics -= int(mega_iron_rate)
	bad_relics *= 10
	print("raw 4 " , bad_relics)
	
	detonator_rate = round(detonator_rate*100)/100
	destroyer_rate = round(destroyer_rate*100)/100
	mega_iron_rate = round(mega_iron_rate*100)/100
	bad_relics = round(bad_relics)
	
	
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
	startTimer("generate_relics")
	generate_relics()
	### Added vvvvvv
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
	
	
	print('detonator rate : ' , detonator_rate)
	generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells,detonator_rate, TILE_DETONATOR)
	
	print('destroyer rate : ' , destroyer_rate)
	generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells,destroyer_rate, TILE_DESTROYER)
	
	print('mega_iron rate : ' , mega_iron_rate)
	generate_cursom_tiles(ironClusterCenters, original_cell_coords, borderCells,mega_iron_rate, TILE_MEGA_IRON)

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
		
		var placed = tryPlace(4, [bestCell, 
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
			
			var remainingSwitches = a.relic_switches
			#reportLog("Placing %s switches" % a.relic_switches)
			var switchDirections:Array
			var distanceNormalization := 0.0
			failsafe = 50
			var averageDistance = 0.5 * (a.relic_switch_distance_range.x + a.relic_switch_distance_range.y)
			var minDistance = a.relic_switch_distance_range.x
			while remainingSwitches > 0:
				failsafe -= 1
				if failsafe < 0:
					reportError("Failsafe reached: Failed to generate relic switch chambers")
					break
				if rand.randf() < 0.2:
					if rand.randf() > 0.5:
						switchDirections = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]
					else:
						switchDirections = [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
				else:
					if rand.randf() > 0.5:
						switchDirections = [Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN, Vector2.UP]
					else:
						switchDirections = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
				
				var distance = rand.randf_range(a.relic_switch_distance_range.x, a.relic_switch_distance_range.y) + distanceNormalization
				distance = clamp(distance, a.relic_switch_distance_range.x, a.relic_switch_distance_range.y)
				while switchDirections.size() > 0:
					var direction = switchDirections.pop_front()
					var result:Vector2 = tryPlaceRelicSwitch(bestCell, direction, distance, minDistance)
					if result != Vector2.ZERO:
						var distanceToSwitch = (result - bestCell).length()
						distanceNormalization += averageDistance - distanceToSwitch
						remainingSwitches -= 1
						if remainingSwitches == 0:
							break
				minDistance -= 1
	
	if remainingBadRelics != 0:
		reportError("Relic generation failed. Failed to place %s relics" % remainingBadRelics)
		
		
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
