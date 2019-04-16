extends CanvasLayer

# Preload the class only once at compile time.
const PokeImage = preload("PokeImage.tscn")

func _ready():
    pass

func _on_Button_pressed():
    print("requesting pokemon")
    $HTTPRequest.request("https://www.pokemon.com/us/api/pokedex/kalos")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
    print(result)
    if result == $HTTPRequest.RESULT_SUCCESS:
        print("parsing")
        var json = JSON.parse(body.get_string_from_utf8())
        var i = 0;
        var pokemons = Array()
        # Why doesn't godot not have array slicing, wtf
        for pokemon in json.result:
            print(pokemon["name"])
            pokemons.push_back(pokemon)
            i += 1
            if i == 16:
                break

        for pokemon in pokemons:
            var image = PokeImage.instance()
            image.image = pokemon["ThumbnailImage"]
            add_child(image)

        # print(json.result[0]["ThumbnailImage"])
    else:
        print('failed')
