return {

  load = function(mod_id)
    print("Mushroom Patcher loaded!")
    return true
  end,

  start = function()
    for m=1,game.g.mushroom_total do
      local shroom = game.g.dictionary['mushroom' .. tostring(m)]
      if shroom == nil then
        game.g.mushroom_total = 24
      end
    end
  end


}