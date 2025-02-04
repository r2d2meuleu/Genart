extends VBoxContainer

@export var max_age: SpinBox
@export var fitness_option: OptionButton
@export var random_restart_count: SpinBox
@export var initial_random_sample_count: SpinBox

var _params : HillClimbingShapeGeneratorParams:
	get:
		return Globals \
				.settings \
				.image_generator_params \
				.shape_generator_params \
				.hill_climbing_params
	
func _ready() -> void:
	
	# Generations spin ---------------------------------------------------------
	max_age.value_changed.connect(
		func(v):
			_params.max_age = v
	)
	
	# Fitness option -----------------------------------------------------------
	for option in FitnessCalculator.Type.keys():
		fitness_option.add_item(option)
		
	fitness_option.item_selected.connect(
		func(index):
			_params.fitness_calculator = index as FitnessCalculator.Type
	)
	
	# Random restart count spin box --------------------------------------------
	random_restart_count.value_changed.connect(
		func(value):
			_params.random_restart_count = value
	)
	
	# Initial random sample count ----------------------------------------------
	initial_random_sample_count.value_changed.connect(
		func(value):
			_params.initial_random_samples = value
	)

	Globals.image_generator_params_updated.connect(_update)
	_update()
	
func _update():
	max_age.value = _params.max_age
	fitness_option.select(_params.fitness_calculator)
	random_restart_count.value = _params.random_restart_count
	initial_random_sample_count.value = _params.initial_random_samples

func _process(dt) -> void:
	visible = Globals \
				.settings \
				.image_generator_params \
				.shape_generator_type == ShapeGenerator.Type.HillClimb
