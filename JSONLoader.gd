extends Node2D


#READ AND RETURN JSON DATA 
func read_json(filename:String) -> String:
	var data_file = File.new()
	
	if !data_file.file_exists(filename):
		return ""
		
	data_file.open(filename, File.READ)
	
	var text = data_file.get_as_text()
	var json_data = JSON.parse(text).result
	
	data_file.close()
	return json_data
