extends StaticBody2D

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player_attack"):
		destroy()

func destroy():
	# Optionally drop an item here
	queue_free()
