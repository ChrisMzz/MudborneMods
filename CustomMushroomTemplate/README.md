# Custom Mushroom Template

This is a small template to help you design custom mushrooms.
You have two `.lua` files. One of them, `mod.lua`, is already fully completed, and all you really have to change is the print statement:
```lua
print('Custom Mushroom mod loaded!')
```
where you can (should) replace `Custom Mushroom` by the name of your mod.

The other, `shrooms.lua`, is where you should define every new mushroom you want to add.

The structure of `shrooms.lua` is as follows:
```lua
return {
    shroom1,
    shroom2,
    ...,
    shroomn
}
```
This is a list of all mushrooms that you are adding, where each of these `shroom`s looks like this:
```lua
{
    info = {...},
    locale = {...},
    colors = {...},
    sprite_path = "...",
    texture_path = "..."
},
```

In a given mushroom, `info` contains all the information relevant to the game logic of the mushroom, `locale` contains the text associated to it, `colors` is a list of hexadecimal colors representing the mushroom, and then the `sprite_path` needs to specify the local path to the in-game sprites, while `texture_path` needs to specify the way the mushroom appears in the book.


## `info`

Here is a typical `info`:
```lua
info = {
    conditions = {1, 6, 'awake', 'mud', 'any', false},
    buff = {'{{SUPPRESS}} {{TRAIT}}', 'x{{NUM}} {{TRAIT}}'},
    buff_col = {'trait_o', 'trait_s'},
    buff_mod = {'SUPRESS', '*2'},
    drops = {
        dmin=1,
        dmax=2
    },
    world = 'dream'
}
```

- `conditions` is a list of `Temperature`, `Moisture`, `World`, `Terrain`, `TimeOfDay` (I don't know what that last boolean is, sorry).
 - `Temperature` and `Moisture` are exactly the integers used in the game's UI
 - `World` is either `awake` or `dream`
 - `Terrain` is either `grass`, `mud`, `water`, `inside` or `stagnant`
 - `TimeOfDay` is unused by the game as far as I'm aware; all mushrooms use `any`. Use at your own risk.
- `buff` is a list of strings that determine how the buff will display. Typically `{{NUM}}` represents the number associated to the buff, `{{TRAIT}}` the trait, and then you can use `{{SUPPRESS}}`, `{{MIN}}` or `{{MAX}}`. Note that you can also write any text here.
- `buff_col` is a list of strings representing the traits buffed by the mushroom. Obviously, this is either `trait_a`, `trait_n`, `trait_o`, `trait_u`, `trait_r`, `trait_e`, or `trait_s`.
- `buff_mod` is a list of the exact buff modifier. This is where it gets weird, for addition and subtraction of traits, use ➕ or ➖, followed by the number you want to add or subtract by. For multiplication you can just use `*`. For minimum, maximum and suppress, just write `MIN`, `MAX` or `SUPRESS`, respectively. Note that the buff for `SUPRESS` only takes one P here; I believe this is due to a typo in the game code (check in the game files' `re_dictionary.lua` if you want to see for yourself!).
- `drops` should always be a table with `dmin` as the minimum number of mushrooms obtained from picking one of these mushrooms up, and `dmax` being the maximum. 
- `world` is the world this mushroom spawns in, either `awake` or `dream`. **Be warned** that setting a *condition* for a mushroom to only spawn in a world will make it unobtainable if you don't also make this field that same world (you, in principle, can't mix and match).

## `locale`

Here is a typical `locale`:

```lua
locale = {
    name = 'Mushroom Name',
    tooltip = 'Mushroom Tooltip',
    hint = 'Text displayed to tell you how to look for the mushroom',
    spore = "Text that displays once you've seen the spores but not collected the mushroom",
    lore1 = 'Random fact about this mushroom',
    lore2 = 'Other random fact about this mushroom'
}
```
The descriptions speak for themselves here.

## `colors`

The colors list looks something like this:
```lua
colors = {'#b0517c', '#aa4658', '#80385d', '#aa4658', '#80385d', '#c27281'}
```

If you're unfamiliar with hexadecimal encoding for RGB colors, consider using a Hex color picker online.

## Sprites

Sprites in the same folder as the `shrooms.lua` can be referenced like so:
```lua
sprite_path = '/shroom_sprites_template.png',
texture_path = '/shroom_texture_template.png'
```

To design a new mushroom, you need to draw a texture for the book art. The exact dimensions + alpha channel for this is prepared in `shroom_texture_template.png`. Draw whatever you want there.

The in-game sprites for the mushroom can be found in a spritesheet, given here as `shroom_sprites_template.png`. The placement is important; a clearer separated view of each sprite is done for the sake of this example over in `shroom_sprites_delims.png`.

These correspond to, in order :
- (the seven first rows) sprites are cultivator and spawner sprites for different regions of the game
- the magic mushroom sprite
- the mushroom item
- the powder item
- the mushroom as it appears in-game
- the mushroom as it begins to spawn (but can't be collected yet)
- the mushroom as it appears in the corner of an item slot
- the spore item
- the spore print item
- the mushroom hybrid (diffs only, uses color scheme)
- the mushroom hybrid as it begins to spawn
- the mushroom hybrid item
- the mushroom hybrid powder 

I've included a `spritesheet.png` file with the original mushrooms' spritesheets, formatted as they are in-game, as well as a Python script `separator.py` that will dump them in the `dumps/` folder in the same format as what MushroomPatcher expects. You can draw your sprites in the same way the game does and then convert using the Python script if you prefer doing it that way.

## Finishing up

Once you have created all your spritework and created all the mushrooms in `shrooms.lua`, jut make sure to create an `icon.png` for you shroom content pack and of course to enter the title of your content pack (+ your name as a mod author!) in the `config.json`.
Then, you're ready to publish the mod using [Mudloader](https://github.com/Mudborne-Modding/mudloader)!
