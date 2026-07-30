"""
HYPERLUNATIC / 星火信使 — 精简命名空间（仅保留跑酷所需常量）
"""

class_name HL
extends NAMESPACE

const DoubleClick = preload("res://assets/global/scripts/double_click.gd")
const Attack = preload("res://assets/global/scripts/attack.gd")
const ForceControlCharacterBody3D = preload("res://assets/global/scripts/force_control_character_body3d.gd")

class Viscositys:
	const AIR: float = 0.0000178
	const WATER: float = 0.001
	const QUICKSILVER: float = 0.00155

const E: float = 2.718281828459045
const GOLDEN_RATIO: float = 0.618033988749895

const LowercaseAlphabet: String = "abcdefghijklmnopqrstuvwxyz"
const UppercaseAlphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const Alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const Digits: String = "0123456789"
const Alphanumeric: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

static func _pass(value): return value
static func _true(_value) -> bool: return true
static func _nop(_arg = null): pass
