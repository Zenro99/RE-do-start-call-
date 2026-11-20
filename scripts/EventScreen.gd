extends Control

func _ready():
    var par = get_parent()
    if par != null and par.has_method("switch_to"):
        par.call_deferred("switch_to", "encounter")