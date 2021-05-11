extends Control

func _ready():
	# Called every time the node is added to the scene.
	Global.connect("connection_failed", self, "_on_connection_failed")
	Global.connect("connection_succeeded", self, "_on_connection_success")
	Global.connect("player_list_changed", self, "refresh_lobby")
	Global.connect("game_ended", self, "_on_game_ended")
	Global.connect("game_error", self, "_on_game_error")
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/inputName.text = OS.get_environment("USERNAME")
		
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/inputName.text = desktop_path[desktop_path.size() - 2]


func _on_buttonHost_pressed():
	if $Connect/inputName.text == "":
		$Connect/labelError.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/labelError.text = ""

	var player_name = $Connect/inputName.text
	var port = $Connect/buttonHost/inputPort.text
	if not port.is_valid_integer():
		$Connect/labelError.text = "Invalid port!"
		return
	Global.host_game(port.to_int(), player_name)
	refresh_lobby()


func _on_buttonJoin_pressed():
	if $Connect/inputName.text == "":
		$Connect/labelError.text = "Invalid name!"
		return

	var ip = $Connect/buttonJoin/inputIP.text
	var port = $Connect/buttonJoin/inputPort.text
	if not ip.is_valid_ip_address():
		$Connect/labelError.text = "Invalid IP address!"
		return

	if not port.is_valid_integer():
		$Connect/labelError.text = "Invalid port!"
		return
	$Connect/labelError.text = ""
	$Connect/buttonHost.disabled = true
	$Connect/buttonJoin.disabled = true

	var player_name = $Connect/inputName.text
	Global.join_game(ip, port.to_int(), player_name)


func _on_connection_success():
	$Connect.hide()
	$Players.show()


func _on_connection_failed():
	$Connect/buttonHost.disabled = false
	$Connect/buttonJoin.disabled = false
	$Connect/labelError.set_text("Connection failed.")


func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/buttonHost.disabled = false
	$Connect/buttonJoin.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/buttonHost.disabled = false
	$Connect/buttonJoin.disabled = false


func refresh_lobby():
	var players = Global.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(Global.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p)

	$Players/buttonStart.disabled = not get_tree().is_network_server()


func _on_buttonStart_pressed():
	Global.begin_game()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")
