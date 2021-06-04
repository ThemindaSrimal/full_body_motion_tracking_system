#show player stats

extends Control

onready var strength = get_node("Background/VBoxContainer/Strength/StatValue")
onready var vitality = get_node("Background/VBoxContainer/Vitality/StatValue")

func _ready():
	 pass

func LoadPlayerStats(stats):
	strength.set_text(str(stats.Strenght))
	vitality.set_text(str(stats.Vitality))
