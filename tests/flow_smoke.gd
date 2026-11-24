extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scripts/game.gd").new()
	root.add_child(game)
	await process_frame
	_check(game.screen == "title", "title screen starts")

	game._start_stage(1)
	_check(game.screen == "play" and game.stage == 1, "level one starts")
	game._step_move(75.0)
	game._step_move(75.0)
	_check(game.x == 240.0 and game.score == 10, "tap movement collects a star fruit")
	game.x = 825.0
	game._click(Vector2(640, 589))
	_check(game.question_open, "level one prompt opens")
	game._answer(0)
	_check(game.wrong and game.question_open and game.stage_score == 10, "wrong answer can retry without score")
	game._answer(1)
	_check(game.screen == "key1" and game.keys[0], "correct answer grants first key")
	_check(game.score == 110 and game.stage_score == 110, "level one score includes fruit and answer")

	game._start_stage(2)
	_check(game.screen == "play" and game.stage == 2, "level two starts")
	game.x = 1640.0
	game._open_quiz()
	game._answer(1)
	_check(game.wrong and game.question_open, "level two wrong answer can retry")
	game._answer(2)
	_check(game.screen == "results" and game.keys[1], "correct answer grants second key and results")
	_check(game.score == 210 and game.stage_score == 100, "final score includes both levels")
	print("FLOW TESTS PASSED: title, touch movement, fruit score, retry, keys, both levels, results")
	quit()

func _check(condition: bool, label: String) -> void:
	if not condition:
		push_error("FAILED: " + label)
		quit(1)
