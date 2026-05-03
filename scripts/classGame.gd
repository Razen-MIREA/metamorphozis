extends Node

class_name Game

var finish_game = false
var kill_counter = 0
var enemy_counter = 0
var damage : float = 20.0
var bigraf_found = false

func found():
	bigraf_found = true
func is_found():
	return bigraf_found

func setDMG(dmg):
	damage = dmg
func getDMG():
	return damage

func change():
	finish_game = true
func finished(): return finish_game

func clear_data():
	kill_counter = 0
	enemy_counter = 0	
func add_kill():
	kill_counter += 1
	enemy_counter -= 1
func add_enemy():
	enemy_counter += 1
func killcounter():
	return kill_counter
func enemycounter():
	return enemy_counter
