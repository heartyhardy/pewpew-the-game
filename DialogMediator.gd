extends Node2D

var speaker:String
var captions:String
var dialog_visible: bool

#SET SPEAKER
func set_speaker(speaker_txt:String) -> void:
	speaker = speaker_txt


#SET CAPTIONS
func set_captions(captions_text:String) -> void:
	captions = captions_text
	

#GET SPEAKER
func get_speaker() ->String:
	return speaker


#GET CAPTIONS
func get_captions() -> String:
	return captions


#SET DIALOG UI VISIBILITY
func set_dialogui_visibility(show: bool):
	dialog_visible = show
	
	
#IS DIALOG UI VISIBLE
func is_dialog_visible() -> bool:
	return dialog_visible

