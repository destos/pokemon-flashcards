extends Node

# SQLite module
const SQLite = preload("res://lib/gdsqlite.gdns")

const POKE_API = "https://www.pokemon.com/us/api/pokedex/kalos"

signal database_error
signal updating_pokemon
signal updating_pokemon_error
signal updated_pokemon
signal inserted_pokemon

# Variables
var db;

# Pokemon generations
const GEN1 = [1, 150]
const GEN2 = [151, 251]
const GEN3 = [252, 386]
const GEN4 = [387, 493]
const GEN5 = [493, 649]
const GEN6 = [493, 649]
const GEN7 = [650, 721]
const GEN8 = [722, 809]
const GENLIST = [
    GEN1,
    GEN2,
    GEN3,
    GEN4,
    GEN5,
    GEN6,
    GEN7,
    GEN8,
]

class_name PokemonManager

# Called when the node enters the scene tree for the first time.
func _init():
    # Create gdsqlite instance
    db = SQLite.new()

    # Try to load pokemon from memory, TODO: check if the time since last load was long, re-load
    if (!db.open("res://pokemon.db")):
        emit_signal("database_error")
        return

    # create pokemon table if needed
    var query = """
    CREATE TABLE IF NOT EXISTS pokemon (
    id integer PRIMARY KEY,
    name text NOT NULL,
    slug text NOT NULL,
    number integer NOT NULL,
    generation integer NOT NULL,
    weight float NOT NULL,
    height float NOT NULL,
    image text NOT NULL
    )
    """
    var result = db.query(query)

    print(result)
    update_pokemon()

func _find_generation(number):
    var gen = 0
    # TODO: See if we can split this from the tuples here
    for gen_range in GENLIST:
        gen += 1
        if number >= gen_range[0] and number <= gen_range[1]:
            return gen

    return 0

func update_pokemon():
    emit_signal("updating_pokemon")
    # Create an HTTP request node and connect its completion signal
    var http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.connect("request_completed", self, "_poke_api_request_completed")

    # Perform the HTTP request. The URL below returns a PNG image as of writing.
    var result = http_request.request(POKE_API)
    if result != OK:
        emit_signal("updating_pokemon_error", result)


func _poke_api_request_completed(result, response_code, headers, body):
    if result == HTTPRequest.RESULT_SUCCESS:
        emit_signal("updated_pokemon")
        print("parsing")
        var json = JSON.parse(body.get_string_from_utf8())
        var i = 0;
        var pokemons = Array()
        # Why doesn't godot not have array slicing, wtf
        for pokemon in json.result:
            print(pokemon["name"])
            _insert_pokemon(pokemon)
    else:
        print("An error occurred in the HTTP request.")
        emit_signal("updating_pokemon_error", result)

func _insert_pokemon(data):
    var number = int(data["number"])
    data["generation"] = _find_generation(number)
    data["number"] = number
    var query = """
    INSERT OR REPLACE INTO pokemon (
        id,
        name,
        slug,
        number,
        generation,
        weight,
        height,
        image
    ) VALUES (
        (SELECT id FROM pokemon WHERE name = '{name}'),
        '{name}',
        '{slug}',
        {number},
        {generation},
        {weight},
        {height},
        '{ThumbnailImage}'
    )
    """.format(data)
    # TODO: escape insertion of data. failing to insert a name with a quote '
    var result = db.query(query);

func get_pokemon(number):
    var query = "SELECT * FROM pokemon WHERE number={number};".format({"number": number})
    return db.fetch_array(query)[0]

func get_random_pokemon(generation=1):
    var query = """
    SELECT * FROM pokemon
    WHERE id IN (
        SELECT id FROM pokemon WHERE generation={gen} ORDER BY RANDOM() LIMIT 1
    )
    """.format({"gen": generation})
    return db.fetch_array(query)[0]
