extends RichTextLabel

var info : String # the information this text is displaying

# sets up the text's information
func setInfo(new_info):
	info = new_info

# returns the text current information
func getInfo():
	return info
