local foundPatcher = false
local loaded = false

return {

  -- When the mod loads (after the game launches), it will look for MushroomPatcher
  load = function(mod_id)
    foundPatcher = false
    for k,mod in pairs(game.g.mods) do
      if mod.id == "MushroomPatcher" and mod.active then
        foundPatcher = true
      end
    end
    if foundPatcher then
      patcher = require("mods/MushroomPatcher/patcher")
      shrooms = require(mod_id .. "/shrooms")
      patcher.load(mod_id, shrooms)
    end
    print('Custom Mushroom mod loaded!')
    return true
  end,

  start = function()
  -- When launching a save file, the game will look for MushroomPatcher AGAIN:
  -- This will inform the player if MushroomPatcher was found but not present on load,
  -- in which case they are prompted to restart the game 
  -- to make sure MushroomPatcher can properly function
    local fp = false
    for k,mod in pairs(game.g.mods) do
      if mod.id == "MushroomPatcher" and mod.active then
        fp = true
      end
    end
    
    if foundPatcher then
      if not loaded then
        loaded = true
        return patcher.start(shrooms)
      end
    elseif fp then
      notif = game.class.notification:new("warning", 'mushroom1', 'mushroom1')
      notif.props.title = "MushroomPatcher found, but..."
      notif.props.tooltip:set({ { text = "Restart to load mushrooms.", color = game.g.colors.font_tgrey } })      
    else
      notif = game.class.notification:new("warning", 'mushroom2', 'mushroom2')
      notif.props.title = "No MushroomPatcher found!"
      notif.props.tooltip:set({ { text = "Can't load new mushrooms.", color = game.g.colors.font_tgrey } })      
    end
  end

}