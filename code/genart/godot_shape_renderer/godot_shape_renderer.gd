extends SubViewport

@export var clear_color: Color
@export var color_rect: ColorRect
@export var shapes_container: Control
@export var shapes: Array[Shape]

var _gd_shape = load("res://godot_shape_renderer/gd_shape_texture_rect.tscn")

## Maps shapes textures RID to godot Texture2D
var _texture_map: Dictionary

var shape_count: int:
	get:
		return shapes_container.get_child_count()

func _ready() -> void:
	Globals.settings.color_post_processing_pipeline_params.changed.connect(post_process_updated)

func clear():
	shapes.clear()
	color_rect.color = clear_color
	
	for child in shapes_container.get_children():
		shapes_container.remove_child(child)
		child.queue_free()
		
	for texture: Texture2DRD in _texture_map.values():
		var texture_rd_rid = texture.texture_rd_rid
		texture.texture_rd_rid = RID()
		var global_rd = RenderingServer.get_rendering_device()
		global_rd.free_rid(texture_rd_rid)

	_texture_map.clear()


func add_shape(shape: Shape):
	shapes.append(shape)

	var post_process_pipeline := ShapeColorPostProcessingPipeline.new()
	var processed_shape = post_process_pipeline.execute_pipeline_on_one_shape(
		shape,
		shape_count,
		0.0,
		Globals.settings.color_post_processing_pipeline_params.shader_params)

	if not _texture_map.has(processed_shape.texture.rd_rid):
		_texture_map[processed_shape.texture.rd_rid] = RenderingCommon.create_texture_from_rd_rid(
				processed_shape.texture.rd_rid
			)
			
	var gd_shape = _gd_shape.instantiate()
	gd_shape.from_shape(processed_shape, _texture_map[processed_shape.texture.rd_rid])
	shapes_container.call_deferred("add_child", gd_shape)


func post_process_updated():
	
	# Process
	var post_process_pipeline := ShapeColorPostProcessingPipeline.new()
	var processed_shapes: Array[Shape] = post_process_pipeline.execute_pipeline(
		shapes,
		0.0,
		Globals.settings.color_post_processing_pipeline_params.shader_params
	)
	
	# Applies to gdshapes
	for i in range(shapes_container.get_child_count()):
		var gd_shape = shapes_container.get_child(i)
		var shape = processed_shapes[i]
		gd_shape.from_shape(shape, _texture_map[shape.texture.rd_rid])

func _exit_tree() -> void:
	clear()
