extends Node2D

#THIS IS A GLOBAL MODULE

#SKILL: DODGE
func can_dodge(perc: int) -> bool:
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var result = rand.randi_range(1, 100)
	if result>= 1 and result<= perc:
		return true
	return false
