extends Node2D

var image = "";

#func _init(poke_image=""):
#    image = poke_image

func _ready():
    # Create an HTTP request node and connect its completion signal
    var http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.connect("request_completed", self, "_http_request_completed")

    # Perform the HTTP request. The URL below returns a PNG image as of writing.
    var http_error = http_request.request(image)
    if http_error != OK:
        print("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
    var image = Image.new()
    var image_error = image.load_png_from_buffer(body)
    if image_error != OK:
        print("An error occurred while trying to display the image.")

    var texture = ImageTexture.new()
    texture.create_from_image(image)

    # Assign to the child TextureRect nodedd
    $TextureRect.set_texture(texture)
