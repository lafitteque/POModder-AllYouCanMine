extends GPUParticles2D

@export var target_position: Vector2 = Vector2(0, 0)

func _process(_delta):
	var particles = get_process_material()
	if particles is ParticleProcessMaterial:
		# On récupère la position de l'émetteur
		var emitter_position = global_position  
		
		# On calcule la direction vers la cible
		var direction = (target_position - emitter_position).normalized()
		
		# On applique cette direction en tant que vélocité initiale
		particles.direction = direction
