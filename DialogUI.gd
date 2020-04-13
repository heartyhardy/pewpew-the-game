extends Control

onready var speaker = $DialogMargins/DialogPanel/Conversations/Speaker
onready var captions = $DialogMargins/DialogPanel/Conversations/Captions


#SET SPEAKER TEXT
func set_speaker(speaker_txt:String) -> void:
	speaker.text = speaker_txt


#SET CAPTIONS TEXT
func set_captions(captions_text:String) -> void:
	captions.text = captions_text


func _ready():
	DialogMediator.set_dialogui_visibility(false)
	self.visible = DialogMediator.is_dialog_visible()
	

func _physics_process(delta):
	self.visible = DialogMediator.is_dialog_visible()
	set_speaker(DialogMediator.get_speaker())
	set_captions(DialogMediator.get_captions())
