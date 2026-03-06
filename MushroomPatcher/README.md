# MushroomPatcher

MushroomPatcher is a utility mod for mod creators and users to add custom mushooms to the game.
Once MushroomPatcher is installed and active, you can download as many mushroom-adding mods as you want, so long as they are created using the [Custom Mushroom Template](https://github.com/ChrisMzz/MudborneMods/tree/main/CustomMushroomTemplate).

It is available on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3679319195).

## Notes

MushroomPatcher **does not add any content to the game**. Its purpose is to make mushroom-adding mods compatible with each other, and simplify the overall process of adding a mushroom to the game.

However, when content packs (in general) are loaded for a save file, those content packs should not be removed from the save file. Removing a content pack after its content was added to the game always comes with the risk of breaking a save file.

There is a safeguard for this (if the game expects more `total_mushrooms` than what is actually in the data, the maximum number reverts to 24 as a safety precaution as not to crash the game), but you should still be careful.

## Making a mod with MushroomPatcher

You don't actually need to edit MushroomPatcher's files! Install it, and then head on other to [Custom Mushroom Template](https://github.com/ChrisMzz/MudborneMods/tree/main/CustomMushroomTemplate) for further instructions.

