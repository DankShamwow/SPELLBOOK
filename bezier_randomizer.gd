extends Control

@onready var p0 = %BezierStart.position
@onready var p1_one: Vector2
@onready var p2_one: Vector2
@onready var p1_two: Vector2
@onready var p2_two: Vector2
@onready var p3 = %BezierEnd.position

@onready var curve_one := Curve2D.new()
@onready var curve_two := Curve2D.new()
@onready var straight_curve_one := Curve2D.new()
@onready var straight_curve_two := Curve2D.new()

@onready var tile_count: int
@onready var tile_number: int
@onready var notch_number: int
@onready var timer_progress: float

func _process(delta: float) -> void:
	
	timer_progress = 1 - (%Timer.time_left / %Timer.wait_time)
	%PathFollowOne.set_progress_ratio(timer_progress * timer_progress)
	%PathFollowTwo.set_progress_ratio(timer_progress * timer_progress)

func _ready():
	
	tile_count = randi_range(3, 7)
	tile_number = randi_range(1, tile_count) - 1
	notch_number = randi_range(1, 3)
	
	_generate_place_tiles(tile_count)
	_update_curve()
	
	%PathOne.curve = curve_one
	%PathTwo.curve = curve_two

func _on_timer_timeout() -> void:
	%PathFollowOne.set_progress_ratio(0.0)
	%PathFollowTwo.set_progress_ratio(0.0)
	
	tile_count = randi_range(3, 7)
	tile_number = randi_range(1, tile_count) - 1
	notch_number = randi_range(1, 3)
	
	_generate_place_tiles(tile_count)
	_update_curve()

func _generate_place_tiles(tiles):
	for tile: ColorRect in %FauxTileParent.get_children():
		tile.free()
	
	for i in tiles:
		var faux_tile = ColorRect.new()
		%FauxTileParent.add_child(faux_tile)
		faux_tile.color = Color(1.0, 1.0, 0.65, 1.0)
		faux_tile.size = Vector2(32.0, 32.0)
		
	for i in %FauxTileParent.get_child_count():
		%FauxTileParent.get_child(0).position = Vector2(304.0 - (19.0 * float(%FauxTileParent.get_child_count()-1)), 120.0)
		%FauxTileParent.get_child(i).position = Vector2(%FauxTileParent.get_child(0).position.x + (38.0 * float(i)), 120.0)


func _update_curve():
	p0 = %FauxTileParent.get_child(tile_number).position
	
	match notch_number:
		1: 
			p0 += Vector2(16, 32)
		
			p1_one = Vector2(p0.x + randf_range(32.0, 48.0), p0.y + randf_range(32.0, 48.0))
			p2_one = Vector2(p1_one.x + randf_range(32.0, 48.0), p1_one.y + randf_range(48.0, 64.0))
			
			p1_two = Vector2(p0.x + randf_range(-48.0, -32.0), p0.y + randf_range(32.0, 48.0))
			p2_two = Vector2(p1_two.x + randf_range(32.0, 48.0), p1_two.y + randf_range(48.0, 64.0))
		
		
		2:
			p0 += Vector2(0, 16)
			
			p1_one = Vector2(p0.x + randf_range(-64.0, -48.0), p0.y + randf_range(48.0, 64.0))
			p2_one = Vector2(p1_one.x + randf_range(64.0, 72.0), p1_one.y + randf_range(32.0, 64.0))
			
			p1_two = Vector2(p0.x + randf_range(-64.0, -48.0), p0.y + randf_range(-48.0, -32.0))
			p2_two = Vector2(p1_two.x + randf_range(48.0, 64.0), p1_two.y + randf_range(-64.0, -32.0))
		
		3:
			p0 += Vector2(32, 16)
	
			p1_one = Vector2(p0.x + randf_range(32.0, 48.0), p0.y + randf_range(48.0, 64.0))
			p2_one = Vector2(p1_one.x + randf_range(32.0, 48.0), p1_one.y + randf_range(16.0, 32.0))
			
			p1_two = Vector2(p0.x + randf_range(32.0, 48.0), p0.y + randf_range(-48.0, -32.0))
			p2_two = Vector2(p1_two.x + randf_range(48.0, 64.0), p1_two.y + randf_range(-64.0, -32.0))
	
	%LineOnePointOne.position = p1_one
	%LineOnePointTwo.position = p2_one
	%LineTwoPointOne.position = p1_two
	%LineTwoPointTwo.position = p2_two
	
	curve_one.clear_points()
	curve_two.clear_points()
	straight_curve_one.clear_points()
	straight_curve_two.clear_points()
	
	
	curve_one.add_point(p0)
	curve_two.add_point(p0)
	
	for t in range(1, 30):
		var new_point_one = _cubic_bezier(p0, p1_one, p2_one, p3, (t / 30.0))
		curve_one.add_point(new_point_one)
		
		var new_point_two = _cubic_bezier(p0, p1_two, p2_two, p3, (t / 30.0))
		curve_two.add_point(new_point_two)
	
	curve_one.add_point(p3)
	curve_two.add_point(p3)
	
	%LineOne.set_points(curve_one.get_baked_points())
	%LineTwo.set_points(curve_two.get_baked_points())
	
	straight_curve_one.add_point(p0)
	straight_curve_one.add_point(p1_one)
	straight_curve_one.add_point(p2_one)
	straight_curve_one.add_point(p3)
	
	straight_curve_two.add_point(p0)
	straight_curve_two.add_point(p1_two)
	straight_curve_two.add_point(p2_two)
	straight_curve_two.add_point(p3)
	
	%StraightLineOne.set_points(straight_curve_one.get_baked_points())
	%StraightLineTwo.set_points(straight_curve_two.get_baked_points())

func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s
