class_name WeightTextureGeneratorPicker extends PanelContainer

signal params_updated()

@export var weight_texture_generator: OptionButton

var params : WeightTextureGeneratorParams

func _ready() -> void:
		# Weight texutre generator option ------------------------------------------
	for option in WeightTextureGenerator.Type.keys():
		weight_texture_generator.add_item(option)
		
	weight_texture_generator.item_selected.connect(
		func(index):
			params.weight_texture_generator_type = index
	)

func set_params(params: WeightTextureGeneratorParams):
	self.params = params
	params_updated.emit()
