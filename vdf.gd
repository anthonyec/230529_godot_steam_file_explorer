class_name VDF
extends Node

const KEYVALUES_TOKEN_SIZE: int = 4096

enum Type {
	TYPE_NONE = 0,
	TYPE_STRING,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_PTR,
	TYPE_WSTRING,
	TYPE_COLOR,
	TYPE_UINT64,
	TYPE_NUMTYPES
}

class Buffer:
	var cursor: int = 0
	var bytes: PackedByteArray
	
	func _init(from: PackedByteArray) -> void:
		bytes = from
	
	func size() -> int:
		return bytes.size()
		
	func next() -> void:
		cursor += 1
		
	func seek(index: int) -> void:
		cursor = index
		
	func get_8() -> int:
		return bytes[cursor]
	
	# From: https://github.com/villadora/node-buffer-reader/blob/f5c1b6565f81c3b1400120014e1425c4d8528b06/index.js#L63
	func get_string_until_null() -> String:
		var length = 0
		
		while length + cursor < size() and bytes[cursor + length] != 0x00:
			length += 1

		assert(length <= size() and bytes[cursor + length] == 0x00, "Out of original buffer's boundary")

		cursor += length + 1
		
		return bytes.slice(cursor - length - 1, cursor - 1).get_string_from_utf8()

func get_string(buffer: FileAccess) -> String:
	return ""

# Inspired by: https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/tier1/KeyValues.cpp#L2529
static func parse_from_file(path: String, stack_depth: int = 0) -> Dictionary:
	# TODO: This can be changed to use `StreamPeerBuffer` to not rely on `FileAccess`.
	# ```gd
	# var buffer = StreamPeerBuffer.new()
	# buffer.data_array = file.get_buffer(file.get_length())
	# ```
	var buffer = FileAccess.open(path, FileAccess.READ)
	
	var buffer_2 = Buffer.new(buffer.get_buffer(buffer.get_length()))
	
	print(buffer.get_8())
	print(buffer_2.get_8())

	if stack_depth > 100:
		push_error("Stack depth bigger than 100")
		return {}
		
	var data: Dictionary = {}
	var type: Type = buffer.get_8()
	
	while true:
		if type == Type.TYPE_NUMTYPES:
			print("END")
			break
			
		data["type"] = type
		
#		{
#			char token[KEYVALUES_TOKEN_SIZE];
#			buffer.GetString( token, KEYVALUES_TOKEN_SIZE-1 );
#			token[KEYVALUES_TOKEN_SIZE-1] = 0;
#			dat->SetName( token );
#		} 

		match type:
			Type.TYPE_NONE:
#				data["sub"] = parse(buffer, stack_depth + 1)
				break
			
			Type.TYPE_STRING:
#				var token: PackedStringArray
				
#				get_string(token, KEYVALUES_TOKEN_SIZE - 1)
				break
				
			Type.TYPE_WSTRING:
				break
			
			Type.TYPE_INT:
				break
				
			Type.TYPE_UINT64:
				break
				
			Type.TYPE_FLOAT:
				break
			
			Type.TYPE_COLOR:
				break
				
			Type.TYPE_PTR:
				break
				
			_:
				break
	
	return data
