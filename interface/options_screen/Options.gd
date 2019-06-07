extends Control

#const PokemonManager = preload("res://PokemonManager.gd")
var pokemon

# Called when the node enters the scene tree for the first time.
func _update_label(text):
    $Status.text = text

func _ready():
    pokemon = PokemonManager.new()
    add_child(pokemon)
    pokemon.connect("database_error", self, "_on_db_error")
    pokemon.connect("updating_pokemon", self, "_on_updating")
    pokemon.connect("updating_pokemon_error", self, "_on_updating_error")
    pokemon.connect("updated_pokemon", self, "_on_updated")
    _update_label("starting")
    pokemon.update_pokemon()
    var poke = pokemon.get_random_pokemon(2)["name"]
    print(poke)

    poke = pokemon.get_random_pokemon(1)["name"]
    print(poke)

    poke = pokemon.get_random_pokemon(3)["name"]
    print(poke)

func _on_db_error():
    _update_label("DB error")

func _on_updating():
    _update_label("Updating pokemon")

func _on_updating_error(result):
    _update_label("Updating pokemon error {error}".format({"error": result}))

func _on_updated():
    _update_label("Updated pokemon!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
