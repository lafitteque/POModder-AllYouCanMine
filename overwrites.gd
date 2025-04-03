func _init():
	### Excavator overwrites
	
	var excavator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Excavator/excavator_animation.tres")
	excavator.take_over_path("res://content/keeper/excavator/spriteframes-skin0.tres")
	excavator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Excavator/excavatorInputProcessor.gd")
	excavator.take_over_path("res://content/keeper/ExcavatorInputProcessor.gd")
	excavator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Excavator/crushCountHud.tscn")
	excavator.take_over_path("res://content/keeper/excavator/crushCountHud.tscn")
	
		## Excavator Icons
	var excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/excavator_icon.png")
	excavator_icon.take_over_path("res://content/icons/loadout_excavator-skin0.png")
	
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/boom_icon1.png")
	excavator_icon.take_over_path("res://content/icons/excavatordamage1.png")
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/boom_icon2.png")
	excavator_icon.take_over_path("res://content/icons/excavatordamage2.png")
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/boom_icon3.png")
	excavator_icon.take_over_path("res://content/icons/excavatordamage3.png")
	
	excavator_icon = preload("res://content/icons/keeper2movement1.png")
	excavator_icon.take_over_path("res://content/icons/excavatorspeedup1.png")
	excavator_icon = preload("res://content/icons/keeper2movement2.png")
	excavator_icon.take_over_path("res://content/icons/excavatorspeedup2.png")
	
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/excavatorlateral1.png")
	excavator_icon.take_over_path("res://content/icons/excavatorlateralspeed1.png")
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/excavatorlateral2.png")
	excavator_icon.take_over_path("res://content/icons/excavatorlateralspeed2.png")
	
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/iconCarry1.png")
	excavator_icon.take_over_path("res://content/icons/excavatorcarryspace1.png")
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/iconCarry2.png")
	excavator_icon.take_over_path("res://content/icons/excavatorcarryspace2.png")
	
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/icon_fall_indicator.png")
	excavator_icon.take_over_path("res://content/icons/excavatorfallindicator.png")
	
	excavator_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/excavator_icon_upgrade.png")
	excavator_icon.take_over_path("res://content/icons/excavator.png")
	
	
	### Adding new map archetypes for assignments
	
	var new_archetype_mineall = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-mineall.tres")
	new_archetype_mineall.take_over_path("res://content/map/generation/archetypes/assignment-mineall.tres")

	var new_archetype_detonators = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-detonators.tres")
	new_archetype_detonators.take_over_path("res://content/map/generation/archetypes/assignment-detonators.tres")

	var new_archetype_destroyer = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-destroyer.tres")
	new_archetype_destroyer.take_over_path("res://content/map/generation/archetypes/assignment-destroyer.tres")

	var new_archetype_aprilfools = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-aprilfools.tres")
	new_archetype_aprilfools.take_over_path("res://content/map/generation/archetypes/assignment-aprilfools.tres")
	
	var new_archetype_thieves = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-thieves.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/assignment-thieves.tres")
	
	var new_archetype_secrets = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-secrets.tres")
	new_archetype_secrets.take_over_path("res://content/map/generation/archetypes/assignment-secrets.tres")
	
	var new_archetype_megairon = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-megairon.tres")
	new_archetype_megairon.take_over_path("res://content/map/generation/archetypes/assignment-megairon.tres")
	
	var new_archetype_chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-chaos.tres")
	new_archetype_chaos.take_over_path("res://content/map/generation/archetypes/assignment-chaos.tres")
	
	var new_archetype_tiny = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-tinyplanet.tres")
	new_archetype_tiny.take_over_path("res://content/map/generation/archetypes/assignment-tinyplanet.tres")
	
	var new_archetype_pyromaniac = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-pyromaniac.tres")
	new_archetype_pyromaniac.take_over_path("res://content/map/generation/archetypes/assignment-pyromaniac.tres")
	
	var new_archetype_speleologist = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-speleologist.tres")
	new_archetype_speleologist.take_over_path("res://content/map/generation/archetypes/assignment-speleologist.tres")
	
	var new_archetype_autonomous = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-autonomous.tres")
	new_archetype_autonomous.take_over_path("res://content/map/generation/archetypes/assignment-autonomous.tres")
	
	var new_archetype_superhot = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-superhot.tres")
	new_archetype_superhot.take_over_path("res://content/map/generation/archetypes/assignment-superhot.tres")
	
	var new_archetype_debt = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-debt.tres")
	new_archetype_debt.take_over_path("res://content/map/generation/archetypes/assignment-debt.tres")
	
	### Adding new map archetypes for custom Game Mode
	
	var new_archetype_huge_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-huge.tres")
	new_archetype_huge_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-huge.tres")
	
	var new_archetype_large_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-large.tres")
	new_archetype_large_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-large.tres")
	
	var new_archetype_medium_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-medium.tres")
	new_archetype_medium_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-medium.tres")
	
	var new_archetype_small_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-small.tres")
	new_archetype_small_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-small.tres")



	### Custom Game Mode (simply a copy of relichunt) :
	
	var coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/gamemode.tscn")
	coresaver.take_over_path("res://content/gamemode/coresaver/Coresaver.tscn")
	
	### Coresaver Icon
	
	var coresaver_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/coresaver.png")
	coresaver_icon.take_over_path("res://content/icons/loadout_coresaver.png")
	
	
	### Blist Miner (pyromaniac) Icons (copy from vanilla game)
	
	var blastmining = preload("res://content/icons/blastmining.png")
	blastmining.take_over_path("res://content/icons/blastminingassignment.png")


	var blastminingblast1 = preload("res://content/icons/blastminingblast1.png")
	blastminingblast1.take_over_path("res://content/icons/blastminingblastassignment1.png")
	
	var blastminingblast2 = preload("res://content/icons/blastminingblast2.png")
	blastminingblast2.take_over_path("res://content/icons/blastminingblastassignment2.png")
	
	var blastminingblast3 = preload("res://content/icons/blastminingblast3.png")
	blastminingblast3.take_over_path("res://content/icons/blastminingblastassignment3.png")
	
	var blast_time = preload("res://content/icons/blastminingproductiontime1.png")
	blast_time.take_over_path("res://content/icons/blastminingproductiontimeassignment1.png")
	
	var blast_sticky = preload("res://content/icons/blastminingstickycharge.png")
	blast_sticky.take_over_path("res://content/icons/blastminingstickychargeassignment.png")		
		
	var blast_impact = preload("res://content/icons/blastminingimpactdetonation.png")
	blast_impact.take_over_path("res://content/icons/blastminingimpactdetonationassignment.png")		
		
		
	### Same for Suit Blaster (pyromaniac)
	var suitblaster = preload("res://content/icons/suitblaster.png")
	suitblaster.take_over_path("res://content/icons/suitblasterassignment.png")
	
	var suitblaster_radius = preload("res://content/icons/suitblasterradius1.png")
	suitblaster_radius.take_over_path("res://content/icons/suitblasterradiusassignment.png")
	
	var suitblaster_max_charge = preload("res://content/icons/suitblastermaxcharge.png")
	suitblaster_max_charge.take_over_path("res://content/icons/suitblastermaxchargeassignment.png")
	
	var suitblaster_speed = preload("res://content/icons/suitblasterspeed1.png")
	suitblaster_speed.take_over_path("res://content/icons/suitblasterspeedassignment1.png")
