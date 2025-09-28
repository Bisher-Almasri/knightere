extends Label

var instructions = [
	[
		"Welcome to The Cloned Knight",
		"You are the Cloned Knight, a warrior with the power to summon parts of your soul to aid you on your journey.",
		"The main rule you must always remember is:",
		"Equal exchange.",
		"To move forward, you must sacrifice.",
		"Press C to summon a clone.",
		"",
		"Each clone only lasts 60 seconds.",
		"",
		"You can only have one clone active at a time, so use it wisely.",
		"",
		"Some jumps may look impossible, but don’t worry—your magic lets you change gravity.",
		"Press G to flip gravity and reach new paths.",
		"",
		#"You will also face monsters along the way.",
		#"Press E or click your mouse to attack.",
		#"",
		"To complete a level, you must press the exit button.",
		"But remember: every action comes at a cost.",
		"",
		"Now go forth…",
		"Be careful not to lose too much of your soul."
	],
	[
		"Advanced Tip:",
		"If you change direction at the exact moment your clone disappears...",
		"...you may skip a directional input.",
		"",
		"This can be used to bypass certain traps or timing-based obstacles.",
		"But be warned:",
		"Timing this maneuver is risky.",
		"",
		"Use it wisely, or not at all.",
		"Sometimes, the path forward isn't the straightest one.",
	]
]

@export var scene1: bool = true

var typing_speed := 0.05
var current_line := 0
var current_char := 0
var is_typing := false
var lines = []

func _ready() -> void:
	lines =  instructions[0] if scene1 else instructions[1]
	_show_next_line()

func _show_next_line() -> void:
	if current_line >= lines.size():
		return
	
	text = ""
	current_char = 0
	is_typing = true
	
	_type_next_char()

func _type_next_char() -> void:
	if current_char < lines[current_line].length():
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		text += lines[current_line][current_char]
		current_char += 1
		get_tree().create_timer(typing_speed).connect("timeout", Callable(self, "_type_next_char"))
	else:
		is_typing = false
		$AudioStreamPlayer.stop()
		current_line += 1
		get_tree().create_timer(1.5).connect("timeout", Callable(self, "_show_next_line"))
