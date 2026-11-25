extends Control

const W := 1280.0
const H := 720.0
const GROUND := 594.0
const END_X := 1760.0
const CREAM := Color("fff5dc")
const GOLD := Color("ffd166")
const TEAL := Color("65dec1")
const INK := Color("202642")

var screen := "title"
var stage := 1
var x := 90.0
var y := 570.0
var vy := 0.0
var grounded := true
var camera_x := 0.0
var score := 0
var stage_score := 0
var coins := [false, false, false, false, false, false]
var keys := [false, false]
var question_open := false
var wrong := false
var first_try := [false, false]
var left_down := false
var right_down := false
var jump_now := false
var answer_rects: Array[Rect2] = []
var font: Font

var quizzes := [
	{"title":"月光市集・零用錢分配", "story":"你有 100 元零用錢，想買點心，也想存下來。哪個做法最能幫未來的自己？", "answers":["全部花掉，今天最開心", "先存一部分，再安排想買的東西", "跟朋友借更多來買"]},
	{"title":"星星果園・投資小隊", "story":"果園有不同種果樹，天氣變化可能影響收成。怎麼做比較能分散風險？", "answers":["把所有資源放在一棵樹", "相信一定賺，借錢買更多", "分散到不同果樹，並了解風險"]}
]

func _ready() -> void:
	custom_minimum_size = Vector2(W, H)
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Microsoft JhengHei UI", "Microsoft JhengHei", "Noto Sans CJK TC", "Arial"])
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	_sync_web_shell()

func _process(delta: float) -> void:
	if screen == "play" and not question_open:
		var dir := float(left_down or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)) * -1.0
		dir += float(right_down or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
		var limit := 900.0 if stage == 1 and not keys[0] else END_X
		x = clampf(x + dir * 300.0 * delta, 30, limit)
		if (jump_now or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) and grounded:
			vy = -590.0
			grounded = false
		jump_now = false
		vy += 1500.0 * delta
		y += vy * delta
		if y >= GROUND - 25:
			y = GROUND - 25
			vy = 0
			grounded = true
		camera_x = clampf(x - 430.0, 0, END_X - W)
		_collect_coins()
		var station := 825.0 if stage == 1 else 1640.0
		if absf(x - station) < 88 and Input.is_key_pressed(KEY_E): _open_quiz()
	queue_redraw()

func _collect_coins() -> void:
	var places := [255.0, 478.0, 715.0, 1055.0, 1275.0, 1500.0]
	var collected := false
	for i in range(places.size()):
		if not coins[i] and absf(x - places[i]) < 38:
			coins[i] = true
			score += 10
			stage_score += 10
			collected = true
	if collected:
		_sync_web_shell()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			if screen == "title": _start_stage(1)
			elif screen == "key1": _start_stage(2)
			elif screen == "results":
				screen = "title"
				_sync_web_shell("準備好了，再玩一次吧！")
		if event.keycode == KEY_E and screen == "play":
			var station := 825.0 if stage == 1 else 1640.0
			if absf(x - station) < 140: _open_quiz()
	if event is InputEventMouseButton:
		if event.pressed: _click(event.position)
		else:
			left_down = false
			right_down = false

func _click(p: Vector2) -> void:
	if screen == "title":
		if Rect2(465, 530, 350, 78).has_point(p): _start_stage(1)
	elif screen == "play" and not question_open:
		if Rect2(65, 625, 96, 66).has_point(p): _step_move(-75.0)
		elif Rect2(175, 625, 96, 66).has_point(p): _step_move(75.0)
		elif Rect2(1082, 612, 132, 78).has_point(p): jump_now = true
		elif Rect2(424, 565, 432, 48).has_point(p):
			var station := 825.0 if stage == 1 else 1640.0
			if absf(x - station) < 175: _open_quiz()
	elif question_open:
		for i in range(answer_rects.size()):
			if answer_rects[i].has_point(p): _answer(i)
	elif screen == "key1" and Rect2(425, 520, 430, 75).has_point(p): _start_stage(2)
	elif screen == "results" and Rect2(425, 566, 430, 74).has_point(p):
		screen = "title"
		_sync_web_shell("準備好了，再玩一次吧！")

func _step_move(amount: float) -> void:
	var limit := 900.0 if stage == 1 and not keys[0] else END_X
	x = clampf(x + amount, 30.0, limit)
	camera_x = clampf(x - 430.0, 0.0, END_X - W)
	_collect_coins()

func _start_stage(n: int) -> void:
	if n == 1:
		score = 0
		coins = [false, false, false, false, false, false]
		keys = [false, false]
		first_try = [false, false]
	stage = n
	stage_score = 0
	x = 90.0 if n == 1 else 950.0
	y = GROUND - 25
	vy = 0
	grounded = true
	camera_x = clampf(x - 430.0, 0, END_X - W)
	question_open = false
	wrong = false
	screen = "play"
	grab_focus()
	_sync_web_shell("尋找互動站，答對題目就能取得 KEY。")

func _open_quiz() -> void:
	question_open = true
	wrong = false
	answer_rects.clear()
	_sync_web_shell("選出最好的做法，答對才能取得 KEY。")

func _answer(index: int) -> void:
	var correct := 1 if stage == 1 else 2
	if index != correct:
		wrong = true
		_sync_web_shell("再想想：哪個選擇最能照顧未來的自己？")
		return
	if not wrong: first_try[stage - 1] = true
	stage_score += 100
	score += 100
	keys[stage - 1] = true
	question_open = false
	screen = "key1" if stage == 1 else "results"
	_sync_web_shell("拿到鑰匙了！準備前往下一關。" if stage == 1 else "兩把鑰匙都點亮了，冒險完成！")

func _draw() -> void:
	if screen == "title":
		_draw_title()
	else:
		_draw_world()
		_draw_hud()
		if question_open: _draw_quiz()
		elif screen == "key1": _draw_key_card()
		elif screen == "results": _draw_results()

func _draw_title() -> void:
	_draw_background(0)
	_draw_terrain()
	_draw_tree(245, 585, 1.4)
	_draw_tree(1030, 585, 1.8)
	_draw_room_backdrop(0.0)
	_draw_room_furniture(0.0)
	_draw_room_floor(0.0)
	_draw_room_door(0.0)
	_draw_hero(Vector2(365, 541))
	_panel(Rect2(315, 58, 650, 590), Color(0.035, 0.055, 0.12, 0.88), Color("8a83be"))
	_text("DREAM ISLAND  /  小小夢魔", Vector2(398, 123), 17, Color("a8f0dd"))
	_text("星光理財島", Vector2(421, 207), 58, CREAM)
	_text("把聰明選擇，變成發光的冒險", Vector2(415, 254), 24, Color("d1d8f4"))
	_coin(Vector2(482, 327), 1.1)
	_coin(Vector2(802, 327), 1.1)
	_text("兩段旅程　·　兩把鑰匙　·　一起學會理財", Vector2(392, 402), 21, GOLD)
	_text("方向鍵移動　空白鍵跳躍　靠近光門按 E 挑戰", Vector2(389, 457), 18, Color("d6def7"))
	_button(Rect2(465, 530, 350, 78), "開始冒險　▶", TEAL, INK, 28)
	_text("適合小學生｜存錢、規劃與認識投資風險", Vector2(408, 628), 17, Color("b4bbd4"))

func _draw_background(offset: float) -> void:
	draw_rect(Rect2(0, 0, W, H), Color("263a68") if stage > 0 else Color("3987c9"))
	for i in range(7): draw_rect(Rect2(0, 210 + i * 54, W, 55), Color(0.3, 0.49, 0.65, 0.08 + i * 0.015))
	for i in range(40):
		var sx := fposmod(float(i * 173 + 57) - offset * 0.12, W + 50)
		var sy := float((i * 83 + 21) % 425)
		draw_circle(Vector2(sx, sy), 1.2 + float(i % 3) * 0.4, Color(0.92, 0.9, 1, 0.38 + float(i % 4) * 0.11))
	for i in range(5):
		var sx := fposmod(float(i * 308 + 120) - offset * 0.23, W + 220) - 110
		_cloud(Vector2(sx, 118 + (i % 3) * 46), 0.8 + float(i % 2) * 0.25)
	for i in range(6):
		var hx := float(i * 286) - fposmod(camera_x * 0.16, 286) - 100
		var h := 125.0 + float((i * 39) % 70)
		draw_colored_polygon(PackedVector2Array([Vector2(hx - 120, GROUND), Vector2(hx + 30, GROUND - h), Vector2(hx + 195, GROUND)]), Color("31496a") if stage > 0 else Color("51926e"))

func _cloud(p: Vector2, s: float) -> void:
	var c := Color(0.93, 0.97, 1, 0.72)
	for b in [Vector2(-30, 5), Vector2(-9, -10), Vector2(15, -7), Vector2(34, 6)]: draw_circle(p + b * s, 21 * s, c)
	draw_rect(Rect2(p.x - 32 * s, p.y, 67 * s, 16 * s), c)

func _draw_terrain() -> void:
	draw_rect(Rect2(0, GROUND, W, H - GROUND), Color("392e46") if stage > 0 else Color("9a674e"))
	draw_rect(Rect2(0, GROUND, W, 18), Color("42644f") if stage > 0 else Color("76a85a"))
	for px in range(-20, 1320, 38):
		var c := Color("42644f") if stage > 0 else Color("76a85a")
		draw_colored_polygon(PackedVector2Array([Vector2(px, GROUND), Vector2(px + 23, GROUND), Vector2(px + 16, GROUND + 13), Vector2(px + 6, GROUND + 13)]), c.lightened(0.12))

func _draw_world() -> void:
	_draw_background(camera_x)
	for i in range(5):
		var tx := float(i * 390 + 190) - camera_x
		if tx > -80 and tx < W + 80: _draw_tree(tx, GROUND - 5, 0.6)
	for i in range(6):
		var bx: float = [400.0, 505.0, 610.0, 1210.0, 1315.0, 1420.0][i] - camera_x
		if bx > -70 and bx < W + 70:
			_panel(Rect2(bx - 31, 374 - (i % 2) * 42, 62, 54), Color("895d4e"), Color("f0b761"))
			_text("?", Vector2(bx - 10, 412 - (i % 2) * 42), 30, CREAM)
	for i in range(5):
		var px := float(i * 300 + 170) - fposmod(camera_x * 0.85, 1800)
		if px > -120 and px < W + 120:
			_panel(Rect2(px, 490 - (i % 2) * 25, 115, 22), Color("655575"), Color("c6a7e4"))
	_draw_terrain()
	_draw_room_backdrop(camera_x)
	_draw_room_furniture(camera_x)
	_draw_room_floor(camera_x)
	var places := [255.0, 478.0, 715.0, 1055.0, 1275.0, 1500.0]
	for i in range(places.size()):
		if not coins[i]:
			var cx: float = places[i] - camera_x
			if cx > -40 and cx < W + 40: _coin(Vector2(cx, 433 - (i % 2) * 33 + sin(Time.get_ticks_msec() * 0.002 + i) * 4), 0.8)
	_draw_station()
	_draw_gate()
	_draw_room_door(camera_x)
	_draw_hero(Vector2(x - camera_x, y))
	_draw_touch_buttons()
	var station := 825.0 if stage == 1 else 1640.0
	if screen == "play" and absf(x - station) < 190:
		_pill(Rect2(424, 565, 432, 48), "靠近光門　按 E 開始互動挑戰！", Color("fff5dc"), INK)

func _draw_tree(tx: float, ground_y: float, s: float) -> void:
	draw_line(Vector2(tx, ground_y), Vector2(tx, ground_y - 54 * s), Color("675273"), 8 * s)
	for i in range(3):
		var p := Vector2(tx + (i - 1) * 20 * s, ground_y - (55 + (i % 2) * 17) * s)
		draw_circle(p, 19 * s, Color("397f77") if stage > 0 else Color("3c9d70"))
		draw_circle(p + Vector2(-5 * s, -5 * s), 6 * s, Color(0.82, 0.95, 0.77, 0.5))
	if stage > 0: draw_circle(Vector2(tx, ground_y - 54 * s), 5 * s, Color("ffd98a"))

func _draw_station() -> void:
	var sx := (825.0 if stage == 1 else 1640.0) - camera_x
	if sx < -120 or sx > W + 120: return
	draw_rect(Rect2(sx - 53, 430, 106, 164), Color(0.2, 0.23, 0.4, 0.58))
	draw_arc(Vector2(sx, 430), 53, PI, TAU, 32, Color("a18bff"), 8)
	draw_arc(Vector2(sx, 430), 43, PI, TAU, 32, Color("f8da8d"), 3)
	draw_circle(Vector2(sx, 430), 18, Color("f2ddaa"))
	draw_circle(Vector2(sx, 430), 10, Color("927fcf"))
	_text("?", Vector2(sx - 7, 438), 24, CREAM)
	_text("挑戰站" if stage == 1 else "投資站", Vector2(sx - 33, 481), 15, CREAM)

func _draw_gate() -> void:
	var gx := (928.0 if stage == 1 else 1730.0) - camera_x
	if gx < -100 or gx > W + 100: return
	_panel(Rect2(gx - 39, 400, 78, 194), Color("292d4b"), Color("e6c375") if keys[stage - 1] else Color("747895"))
	draw_rect(Rect2(gx - 27, 420, 54, 154), Color("20233e"))
	draw_arc(Vector2(gx, 420), 27, PI, TAU, 24, Color("e6c375") if keys[stage - 1] else Color("8e91ac"), 5)
	if keys[stage - 1]: _key(Vector2(gx, 480), 0.8)
	else: _text("×", Vector2(gx - 9, 496), 25, Color("d0cde1"))
	_text("光門", Vector2(gx - 16, 615), 14, CREAM)

func _draw_hero(p: Vector2) -> void:
	var bob := sin(Time.get_ticks_msec() * 0.005) * 2
	_ellipse(Vector2(p.x, p.y + 25 + bob), Vector2(28, 7), Color(0.01, 0.02, 0.06, 0.32))
	draw_colored_polygon(PackedVector2Array([Vector2(p.x - 17, p.y + 10 + bob), Vector2(p.x + 16, p.y + 10 + bob), Vector2(p.x + 25, p.y + 34), Vector2(p.x + 8, p.y + 28), Vector2(p.x - 3, p.y + 37), Vector2(p.x - 22, p.y + 30)]), Color("453e70"))
	draw_circle(Vector2(p.x, p.y - 3 + bob), 22, Color("303254"))
	draw_circle(Vector2(p.x, p.y - 9 + bob), 20, Color("44436d"))
	for eye_x in [-6, 6]:
		draw_circle(Vector2(p.x + eye_x, p.y - 8 + bob), 3.3, Color("ffe7aa"))
		draw_circle(Vector2(p.x + eye_x, p.y - 8 + bob), 1.2, INK)
	draw_line(Vector2(p.x + 16, p.y + 4), Vector2(p.x + 28, p.y + 18), Color("d6b27a"), 2)
	draw_circle(Vector2(p.x + 30, p.y + 21), 7, Color("ecad53"))
	draw_circle(Vector2(p.x + 30, p.y + 21), 4, Color("fff0b5"))
	draw_circle(Vector2(p.x - 2, p.y - 31 + bob), 3, Color("ffe2a0"))

func _draw_touch_buttons() -> void:
	_button(Rect2(65, 625, 96, 66), "◀", Color("323955"), CREAM, 27)
	_button(Rect2(175, 625, 96, 66), "▶", Color("323955"), CREAM, 27)
	_button(Rect2(1082, 612, 132, 78), "跳躍", Color("323955"), CREAM, 22)

func _draw_hud() -> void:
	if OS.has_feature("web"):
		return
	_panel(Rect2(28, 22, 412, 98), Color(0.04, 0.06, 0.13, 0.9), Color(0.68, 0.72, 0.9))
	_text("第 %d 關　%s" % [stage, "月光市集" if stage == 1 else "星星果園"], Vector2(49, 60), 22, CREAM)
	_text("本關 %d 分　｜　總分 %d" % [stage_score, score], Vector2(49, 97), 17, GOLD)
	_panel(Rect2(956, 22, 296, 98), Color(0.04, 0.06, 0.13, 0.9), Color(0.68, 0.72, 0.9))
	_text("星星果實　%d / 6" % coins.count(true), Vector2(979, 59), 18, CREAM)
	_key(Vector2(1000, 93), 0.48)
	_text("鑰匙 %d / 2" % (int(keys[0]) + int(keys[1])), Vector2(1028, 98), 16, TEAL)

func _sync_web_shell(message: String = "") -> void:
	if not OS.has_feature("web"):
		return
	var keys_collected := int(keys[0]) + int(keys[1])
	var level_name := "月光市集" if stage == 1 else "星星果園"
	var status_message := message
	if status_message.is_empty():
		status_message = "走進夢境，開始兩關理財冒險。" if screen == "title" else "方向鍵移動，靠近光門按 E 互動。"
	var state := {
		"screen": screen,
		"stage": stage,
		"level": level_name,
		"score": score,
		"stage_score": stage_score,
		"keys": keys_collected,
		"message": status_message
	}
	JavaScriptBridge.eval("if (typeof window.setGameHud === 'function') { window.setGameHud(%s); }" % JSON.stringify(state))

func _draw_quiz() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.025, 0.04, 0.11, 0.8))
	_panel(Rect2(278, 79, 724, 570), Color("f4efdf"), Color("e4c37a"))
	var q: Dictionary = quizzes[stage - 1]
	_text("互動挑戰  /  答對才能取得鑰匙", Vector2(337, 134), 17, Color("77728c"))
	_text(q.title, Vector2(337, 186), 30, INK)
	_text(q.story, Vector2(337, 232), 19, Color("4b526b"))
	answer_rects.clear()
	for i in range(3):
		var r := Rect2(337, 274 + i * 82, 606, 66)
		answer_rects.append(r)
		_panel(r, Color("fffaf0"), Color("b7b1cb"))
		draw_circle(Vector2(372, r.position.y + 33), 17, Color("9b8cff"))
		_text(str(i + 1), Vector2(367, r.position.y + 39), 17, Color.WHITE)
		_text(q.answers[i], Vector2(407, r.position.y + 41), 19, INK)
	if wrong: _pill(Rect2(347, 531, 586, 50), "再想一想：好選擇會照顧未來，也會先看風險。", Color("ffe1c5"), Color("744837"))
	else: _text("點選一個答案。答錯也沒關係，可以再想一想！", Vector2(365, 603), 17, Color("77728c"))

func _draw_key_card() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.025, 0.04, 0.11, 0.78))
	_panel(Rect2(333, 120, 614, 490), Color("f4efdf"), Color("e4c37a"))
	_text("第一關完成！", Vector2(520, 193), 35, INK)
	_key(Vector2(635, 291), 2.1)
	_text("月光鑰匙到手", Vector2(535, 374), 27, Color("5b5184"))
	_text("本關得分　%d" % stage_score, Vector2(552, 418), 20, Color("555b70"))
	_text("先存一部分，再安排想買的東西，", Vector2(435, 459), 18, Color("555b70"))
	_text("讓未來的自己也有選擇。", Vector2(503, 489), 18, Color("555b70"))
	_button(Rect2(425, 520, 430, 75), "帶著鑰匙前往第二關　→", TEAL, INK, 22)

func _draw_results() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.025, 0.04, 0.11, 0.84))
	_panel(Rect2(266, 35, 748, 650), Color("f4efdf"), Color("e4c37a"))
	_text("星光理財島　冒險完成！", Vector2(406, 99), 35, INK)
	_text("兩把鑰匙都點亮了你的理財地圖。", Vector2(426, 138), 19, Color("646980"))
	_panel(Rect2(337, 166, 606, 108), Color("fffaf0"), Color("d5c8a7"))
	_text("總得分", Vector2(383, 212), 19, Color("73768b"))
	_text(str(score), Vector2(523, 239), 42, Color("9b6c25"))
	_text("分", Vector2(595, 239), 20, Color("73768b"))
	_text("每關得分", Vector2(691, 210), 16, Color("73768b"))
	_text("%d　＋　%d" % [100 + _coin_points(0, 3), 100 + _coin_points(3, 6)], Vector2(682, 244), 21, INK)
	_text("我的進步成果", Vector2(379, 319), 23, INK)
	_text("出發時　0/2", Vector2(380, 365), 17, Color("72768c"))
	_bar(Rect2(500, 345, 400, 28), 0.1, Color("c9c6d4"))
	_text("開始", Vector2(910, 365), 14, Color("72768c"))
	_text("完成後　2/2", Vector2(375, 415), 17, Color("72768c"))
	_bar(Rect2(500, 395, 400, 28), 1.0, TEAL)
	_text("完成", Vector2(910, 415), 16, Color("317c67"))
	_text("✓ 能規劃零用錢，理解先存後花", Vector2(412, 469), 18, Color("43546b"))
	_text("✓ 知道分散投資，也要先了解風險", Vector2(412, 505), 18, Color("43546b"))
	_text("記住：投資有風險，沒有保證獲利。", Vector2(440, 541), 16, Color("856249"))
	_button(Rect2(425, 566, 430, 74), "再玩一次　↻", Color("b3a4ff"), Color("201e3d"), 22)

func _coin_points(start: int, end: int) -> int:
	var total := 0
	for i in range(start, end):
		if coins[i]: total += 10
	return total

func _bar(r: Rect2, amount: float, color: Color) -> void:
	draw_rect(r, Color("dfdce7"))
	draw_rect(Rect2(r.position + Vector2(4, 4), Vector2((r.size.x - 8) * amount, r.size.y - 8)), color)

func _key(p: Vector2, s: float) -> void:
	draw_circle(p, 11 * s, GOLD)
	draw_circle(p, 5 * s, Color("483d67"))
	draw_rect(Rect2(p.x + 8 * s, p.y - 3 * s, 29 * s, 6 * s), GOLD)
	draw_rect(Rect2(p.x + 25 * s, p.y + 1 * s, 6 * s, 8 * s), GOLD)
	draw_rect(Rect2(p.x + 34 * s, p.y + 1 * s, 6 * s, 6 * s), GOLD)

func _coin(p: Vector2, s: float) -> void:
	draw_circle(p + Vector2(2, 4) * s, 16 * s, Color(0, 0, 0, 0.23))
	draw_circle(p, 15 * s, Color("d89337"))
	draw_circle(p, 11 * s, GOLD)
	draw_line(p + Vector2(0, -6) * s, p + Vector2(0, 6) * s, Color("a86b36"), 2 * s)

func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var a := TAU * float(i) / 24
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)

func _button(r: Rect2, label: String, color: Color, text_color: Color, size: int) -> void:
	draw_rect(Rect2(r.position + Vector2(0, 4), r.size), color.darkened(0.27))
	draw_rect(r, color)
	var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	_text(label, Vector2(r.position.x + (r.size.x - width) / 2, r.position.y + r.size.y / 2 + size * 0.35), size, text_color)

func _pill(r: Rect2, label: String, color: Color, text_color: Color) -> void:
	draw_rect(r, color)
	var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	_text(label, Vector2(r.position.x + (r.size.x - width) / 2, r.position.y + 31), 17, text_color)

func _panel(r: Rect2, color: Color, border: Color) -> void:
	draw_rect(Rect2(r.position + Vector2(0, 4), r.size), Color(0, 0, 0, 0.2))
	draw_rect(r, border)
	draw_rect(Rect2(r.position + Vector2(3, 3), r.size - Vector2(6, 6)), color)

func _text(label: String, p: Vector2, size: int, color: Color) -> void:
	draw_string(font, p, label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw_room_backdrop(offset: float) -> void:
	var wall := Color("29262b") if stage == 1 else Color("242a32")
	var plaster := Color("514746") if stage == 1 else Color("424652")
	draw_rect(Rect2(0, 0, W, H), wall)
	draw_rect(Rect2(0, 62, W, 353), plaster)
	for i in range(9):
		var px := float(i * 180) - fposmod(offset * 0.3, 180.0)
		draw_line(Vector2(px, 68), Vector2(px - 12, 414), Color(0.11, 0.09, 0.12, 0.18), 2)
		draw_line(Vector2(px + 3, 70), Vector2(px - 8, 414), Color(0.9, 0.72, 0.54, 0.06), 1)
	draw_rect(Rect2(0, 412, W, 184), Color("332f35"))
	draw_rect(Rect2(0, 412, W, 12), Color("82705d"))
	draw_rect(Rect2(0, 428, W, 5), Color("211f27"))
	draw_rect(Rect2(0, 25, W, 35), Color("191a21"))
	draw_line(Vector2(0, 60), Vector2(W, 60), Color("98806a"), 3)
	# Soft amber spill keeps the shadowy room readable and child-friendly.
	var glow := PackedVector2Array([Vector2(452, 213), Vector2(474, 213), Vector2(878, 585), Vector2(300, 585)])
	draw_colored_polygon(glow, Color(1.0, 0.59, 0.28, 0.055))
	for i in range(5):
		var yy := 472.0 + i * 42.0
		draw_line(Vector2(0, yy), Vector2(W, yy), Color(0.08, 0.07, 0.1, 0.3), 2)

func _draw_room_furniture(offset: float) -> void:
	var base := 0.0 if stage == 1 else 900.0
	_draw_window(base + 78.0 - offset)
	_draw_bookshelf(base + 224.0 - offset)
	_draw_wall_lamp(base + 428.0 - offset)
	_draw_mobile(base + 558.0 - offset)
	_draw_toy_cart(base + 550.0 - offset)

func _draw_window(sx: float) -> void:
	if sx < -110 or sx > W + 110: return
	var center := sx + 54.0
	var pane := Rect2(sx, 139, 108, 270)
	var light_beam := PackedVector2Array([Vector2(sx + 82, 204), Vector2(sx + 106, 204), Vector2(sx + 310, 589), Vector2(sx - 160, 589)])
	draw_colored_polygon(light_beam, Color(0.56, 0.69, 0.86, 0.10))
	draw_rect(pane, Color("23303b"))
	draw_rect(Rect2(sx + 10, 168, 41, 224), Color("5a6c79"))
	draw_rect(Rect2(sx + 57, 168, 41, 224), Color("485967"))
	draw_rect(Rect2(sx + 48, 164, 9, 244), Color("392f2c"))
	draw_rect(Rect2(sx + 3, 281, 102, 9), Color("392f2c"))
	draw_arc(Vector2(center, 170), 54, PI, TAU, 32, Color("684f42"), 10)
	draw_line(Vector2(sx - 5, 168), Vector2(sx - 5, 410), Color("684f42"), 10)
	draw_line(Vector2(sx + 113, 168), Vector2(sx + 113, 410), Color("684f42"), 10)
	draw_rect(Rect2(sx - 15, 401, 138, 14), Color("8d7055"))
	draw_rect(Rect2(sx - 8, 397, 124, 4), Color("c4a075"))

func _draw_bookshelf(sx: float) -> void:
	if sx < -100 or sx > W + 100: return
	draw_rect(Rect2(sx - 58, 218, 116, 370), Color("201d22"))
	draw_rect(Rect2(sx - 53, 223, 106, 357), Color("654a3b"))
	for shelf_y in [294.0, 371.0, 448.0, 525.0]:
		draw_rect(Rect2(sx - 51, shelf_y, 102, 8), Color("a17b58"))
		draw_rect(Rect2(sx - 49, shelf_y + 8, 98, 3), Color("30252a"))
	if stage == 2:
		var fruit_colors := [Color("d88c63"), Color("e5bc69"), Color("8fb28a"), Color("a884ad")]
		for row in range(3):
			for col in range(4):
				var fx := sx - 35 + col * 23
				var fy := 280.0 + row * 77
				draw_circle(Vector2(fx, fy), 9, fruit_colors[(row + col) % fruit_colors.size()])
				draw_circle(Vector2(fx - 3, fy - 3), 3, Color(1, 0.94, 0.79, 0.4))
				draw_line(Vector2(fx, fy - 9), Vector2(fx + 2, fy - 13), Color("8da677"), 2)
		return
	var book_colors := [Color("9a5e49"), Color("c19359"), Color("647a79"), Color("8d7382"), Color("b18765"), Color("59616b")]
	for row in range(3):
		for col in range(5):
			var bw := 12.0 + float((row + col) % 3) * 3.0
			var bh := 37.0 + float((row * 7 + col * 9) % 24)
			var bx := sx - 46 + col * 19
			var by := 290.0 - bh if row == 0 else (367.0 - bh if row == 1 else 444.0 - bh)
			draw_rect(Rect2(bx, by, bw, bh), book_colors[(row + col) % book_colors.size()])
			draw_rect(Rect2(bx + 3, by + 7, 2, bh - 13), Color(1, 0.86, 0.63, 0.32))
	draw_rect(Rect2(sx - 64, 211, 128, 13), Color("98714e"))
	# A tiny plush star sits on the shelf as a friendly room detail.
	draw_circle(Vector2(sx, 199), 15, Color("b38d61"))
	draw_circle(Vector2(sx - 5, 196), 2.5, Color("211e28"))
	draw_circle(Vector2(sx + 5, 196), 2.5, Color("211e28"))

func _draw_wall_lamp(sx: float) -> void:
	if sx < -100 or sx > W + 100: return
	draw_circle(Vector2(sx, 272), 108, Color(1.0, 0.57, 0.24, 0.035))
	draw_circle(Vector2(sx, 272), 70, Color(1.0, 0.65, 0.30, 0.055))
	var beam := PackedVector2Array([Vector2(sx - 15, 277), Vector2(sx + 15, 277), Vector2(sx + 135, 586), Vector2(sx - 120, 586)])
	draw_colored_polygon(beam, Color(1.0, 0.63, 0.3, 0.06))
	draw_rect(Rect2(sx - 30, 283, 60, 11), Color("2c2830"))
	draw_line(Vector2(sx, 294), Vector2(sx, 540), Color("725640"), 8)
	draw_line(Vector2(sx - 2, 302), Vector2(sx - 2, 530), Color("d3a46b"), 2)
	draw_circle(Vector2(sx, 272), 24, Color("29252c"))
	draw_circle(Vector2(sx, 272), 18, Color("bf8649"))
	draw_circle(Vector2(sx, 272), 12, Color("ffcf7e"))
	draw_rect(Rect2(sx - 36, 548, 72, 12), Color("46372f"))
	_ellipse(Vector2(sx, 554), Vector2(48, 7), Color("211e24"))

func _draw_mobile(sx: float) -> void:
	if sx < -80 or sx > W + 80: return
	draw_line(Vector2(sx, 60), Vector2(sx, 110), Color("78634f"), 2)
	draw_arc(Vector2(sx, 114), 50, PI, TAU, 24, Color("987a58"), 2)
	for i in range(5):
		var px := sx - 42 + i * 21
		var drop := 24 + (i % 3) * 16
		draw_line(Vector2(px, 114), Vector2(px, 114 + drop), Color("8d7559"), 1)
		if i == 2:
			draw_circle(Vector2(px, 130 + drop), 10, Color("f1c879"))
			draw_circle(Vector2(px + 4, 126 + drop), 9, Color("51433a"))
		else:
			_draw_star(Vector2(px, 121 + drop), 8, Color("d5b575"))

func _draw_toy_cart(sx: float) -> void:
	if sx < -150 or sx > W + 150: return
	draw_circle(Vector2(sx - 102, 579), 18, Color("252329"))
	draw_circle(Vector2(sx + 102, 579), 18, Color("252329"))
	draw_circle(Vector2(sx - 102, 579), 8, Color("957754"))
	draw_circle(Vector2(sx + 102, 579), 8, Color("957754"))
	draw_line(Vector2(sx - 102, 579), Vector2(sx - 68, 535), Color("806044"), 5)
	draw_line(Vector2(sx + 102, 579), Vector2(sx + 68, 535), Color("806044"), 5)
	draw_rect(Rect2(sx - 128, 527, 256, 15), Color("805c40"))
	draw_rect(Rect2(sx - 120, 525, 240, 5), Color("c0955e"))
	draw_rect(Rect2(sx - 82, 487, 50, 38), Color("996b47"))
	draw_rect(Rect2(sx - 77, 492, 40, 28), Color("bb8954"))
	var tri := PackedVector2Array([Vector2(sx - 4, 524), Vector2(sx + 35, 478), Vector2(sx + 72, 524)])
	draw_colored_polygon(tri, Color("9c7652"))
	draw_line(Vector2(sx + 8, 514), Vector2(sx + 35, 482), Color("d2ad75"), 3)
	draw_rect(Rect2(sx + 86, 490, 32, 35), Color("805a3f"))
	draw_rect(Rect2(sx + 91, 495, 22, 25), Color("b28658"))

func _draw_room_floor(offset: float) -> void:
	draw_rect(Rect2(0, 596, W, H - 596), Color("241f24"))
	draw_rect(Rect2(0, 596, W, 11), Color("80634c"))
	for i in range(13):
		var yline := 616 + i * 34
		draw_line(Vector2(0, yline), Vector2(W, yline), Color(0.64, 0.46, 0.32, 0.22), 2)
	for i in range(10):
		var px := float(i * 144) - fposmod(offset * 0.55, 144.0)
		draw_line(Vector2(px, 609), Vector2(px - 25, 720), Color(0.07, 0.06, 0.08, 0.4), 2)
	var rug_x := (480.0 if stage == 1 else 1380.0) - offset
	if rug_x > -280 and rug_x < W + 280:
		var rug_base := Color("47343a") if stage == 1 else Color("303c43")
		var rug_light := Color("755447") if stage == 1 else Color("4f7168")
		draw_rect(Rect2(rug_x - 235, 622, 470, 88), rug_base)
		draw_rect(Rect2(rug_x - 224, 631, 448, 69), rug_light)
		draw_rect(Rect2(rug_x - 211, 638, 422, 55), rug_base.lightened(0.08))
		for i in range(9):
			_draw_star(Vector2(rug_x - 184 + i * 46, 664), 6, Color("b69566"))
		draw_rect(Rect2(rug_x - 235, 622, 470, 5), Color("b09061"))
		draw_rect(Rect2(rug_x - 235, 705, 470, 5), Color("b09061"))

func _draw_room_door(offset: float) -> void:
	var wx := (928.0 if stage == 1 else 1730.0) - offset
	if wx < -120 or wx > W + 120: return
	var door := Rect2(wx - 74, 121, 148, 474)
	draw_rect(Rect2(door.position - Vector2(12, 11), door.size + Vector2(24, 21)), Color("211f26"))
	draw_rect(door, Color("483b32"))
	draw_rect(Rect2(door.position + Vector2(8, 8), door.size - Vector2(16, 16)), Color("68503c"))
	draw_rect(Rect2(wx - 57, 256, 114, 210), Color("483a33"))
	draw_rect(Rect2(wx - 48, 265, 96, 192), Color("5e4938"))
	draw_rect(Rect2(wx - 57, 493, 114, 75), Color("493b34"))
	draw_rect(Rect2(wx - 47, 503, 94, 56), Color("5a4537"))
	for i in range(3):
		var bulb_color := Color("ffcb70") if i < 2 or keys[stage - 1] else Color("29262c")
		draw_circle(Vector2(wx, 166 + i * 43), 18, Color("2b2728"))
		draw_circle(Vector2(wx, 166 + i * 43), 13, Color("b8844d") if bulb_color.r < 0.5 else Color("e2aa5d"))
		draw_circle(Vector2(wx, 166 + i * 43), 8, bulb_color)
		if bulb_color.r > 0.7: draw_circle(Vector2(wx, 166 + i * 43), 31, Color(1, 0.63, 0.29, 0.05))
	draw_rect(Rect2(wx + 47, 371, 8, 48), Color("b89059"))
	draw_circle(Vector2(wx + 51, 395), 6, Color("e1b66e"))
	draw_circle(Vector2(wx - 48, 395), 7, Color("2c282c"))
	if not keys[stage - 1]:
		draw_circle(Vector2(wx - 48, 395), 5, Color("d9b36f"))
	else:
		_key(Vector2(wx - 48, 395), 0.32)

func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(10):
		var a := -PI / 2 + i * PI / 5
		var r := radius if i % 2 == 0 else radius * 0.46
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, color)
