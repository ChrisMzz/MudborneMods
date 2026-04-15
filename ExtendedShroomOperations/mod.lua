return {

  load = function(mod_id)
    require(mod_id .. "/ui").patch_ui()
    require(mod_id .. "/genetics").patch_genetics()
    print('ExtendedShroomOperations loaded!')
    game.g.locale["label_trait_random"] = "Random"
    return true
  end


}
