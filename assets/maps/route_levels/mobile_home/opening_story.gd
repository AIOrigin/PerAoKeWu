class_name OpeningStory
extends RefCounted

const STORY_ROOT := "res://assets/maps/route_levels/mobile_home/story_intro/"

## English opening comic — p1–p8. Web 从 CDN 拉原图，不要 preload 进 pck。
static func get_panels() -> Array[Dictionary]:
	return [
		{
			"image_path": STORY_ROOT + "p1.png",
			"caption": "Year 2179.\nThe sky cracked open.",
		},
		{
			"image_path": STORY_ROOT + "p2.png",
			"caption": "The Zero Tide arrived,\nrewriting Earth into countless deadlands.",
		},
		{
			"image_path": STORY_ROOT + "p3.png",
			"caption": "Humanity clings to life\nin scattered embers of hope.",
		},
		{
			"image_path": STORY_ROOT + "p4.png",
			"caption": "Machines run wild.\nRoutes vanish.\nThe transport network collapses.",
		},
		{
			"image_path": STORY_ROOT + "p5.png",
			"caption": "So the last roads were given to those who could run.\nThey are called Ember Runners.",
		},
		{
			"image_path": STORY_ROOT + "p6.png",
			"caption": "They cross the deadlands,\ncarrying the supplies that keep the outposts alive.",
		},
		{
			"image_path": STORY_ROOT + "p7.png",
			"caption": "Every delivery gathers the strength\nto light humanity's outposts.",
		},
		{
			"image_path": STORY_ROOT + "p8.png",
			"caption": "A single spark will eventually\nform the line of dawn.",
		},
	]

static func title_text() -> String:
	return "EMBER\nRUNNERS:\nDAWN LINE"

static func title_subtitle() -> String:
	return "Prologue"
