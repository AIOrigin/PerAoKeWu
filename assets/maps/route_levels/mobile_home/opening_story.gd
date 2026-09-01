class_name OpeningStory
extends RefCounted

const STORY_ROOT := "res://assets/maps/route_levels/mobile_home/story_intro/"

## English opening comic — p1–p8, textures preloaded for reliable display.
static func get_panels() -> Array[Dictionary]:
	return [
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p1.png"),
			"caption": "Year 2179.\nThe sky cracked open.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p2.png"),
			"caption": "The Zero Tide arrived,\nrewriting Earth into countless deadlands.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p3.png"),
			"caption": "Humanity clings to life\nin scattered embers of hope.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p4.png"),
			"caption": "Machines run wild.\nRoutes vanish.\nThe transport network collapses.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p5.png"),
			"caption": "So the last roads were given to those who could run.\nThey are called Ember Runners.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p6.png"),
			"caption": "They cross the deadlands,\ncarrying the supplies that keep the outposts alive.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p7.png"),
			"caption": "Every delivery gathers the strength\nto light humanity's outposts.",
		},
		{
			"texture": preload("res://assets/maps/route_levels/mobile_home/story_intro/p8.png"),
			"caption": "A single spark will eventually\nform the line of dawn.",
		},
	]

static func title_text() -> String:
	return "EMBER\nRUNNERS:\nDAWN LINE"

static func title_subtitle() -> String:
	return "Prologue"
