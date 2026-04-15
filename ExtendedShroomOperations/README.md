# ExtendedShroomOperations

Optional dependency for shroompacks added with [Mushroom Patcher](https://steamcommunity.com/sharedfiles/filedetails/?id=3679319195&searchtext=).

This mod allows your mushrooms to affect traits in new ways, such as dividing the modifier by 2, squaring it, or making the mushroom affect a random trait.

This is still a work-in-progress dependency, and more features might be added with time (don't hesitate to request a feature as well!).

It is available on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3707362028).


## Current additions

Assuming you're familiar with adding mushrooms through Mushroom Patcher:


## New operations

- Divide by 2: you can add `buff_mod = {'/2'}` to divide by 2 and round to the nearest integer. You can write `buff = {'/2 {{TRAIT}}'}` in the buff section.
- Square 2: you can add `buff_mod = {'^2'}` to divide by 2 and round to the nearest integer. 
You can write `buff = {'Square {{TRAIT}}'}` in the buff section (or anything else you think is more appropriate).


### Random Traits

Adding the following to your buffs will affect a random trait. This trait will change constantly, so don't ever trust the tooltip for too long! If you make magic mud or get the shroom in powdered form you will see that sometimes it chooses to display `Random`, sometimes it picks a random trait, and sometimes it even doesn't show anything at all. However, it does actually affect a truly random trait each time, regardless of the tooltip display.
```lua
    buff_col = {'trait_random'}
```




