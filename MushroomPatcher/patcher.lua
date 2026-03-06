
patch_ui_picker_new = function(height) 
  -- create new constructor for future predictors 
  game.class.ui_picker.new = function(self, x, y, ptype, parent)
    local ui = tn.class.menu:new(x, y, 146, height, 'sp_predictor_selection', nil, false, 'picker')
    ui.priority = true
    ui:extend(self)
    ui:define({
      options = {},
      option = '',
      target = -1,
      ptype = ptype,
      pvalue = '',
      parent = parent
    })
    local ux = 7
    local uy = 4
    for i=1,game.g.mushroom_total do
      local option = game.class.ui_button:new(ux, uy, 'sp_button_select', ui, 'picker_option')
      option.scripts.tooltip = self.btooltip
      table.insert(ui.props.options, option)
      ux = ux + 23
      if i % 6 == 0 then
        uy = uy + 23
        ux = 7
      end
    end
    return ui
  end
end

patch_ui_picker_existing = function(height, minshrooms, maxshrooms)
  -- patch existing predictors
  local ux
  local uy
  for k, menu in pairs(tn.internals.menus) do
    if menu ~= nil then
      if menu.label == "PREDICTOR1" or menu.label == "PREDICTOR2" then
        menu.picker.h = height
        ux = 7
        uy = 4
        if #menu.picker.props.options < maxshrooms then
          for i=1,game.g.mushroom_total do
            if (i >= minshrooms) and (i <= maxshrooms) then
              local option = game.class.ui_button:new(ux, uy, 'sp_button_select', menu.picker, 'picker_option')
              option.scripts.tooltip = game.class.ui_picker.btooltip
              table.insert(menu.picker.props.options, option)
            end
            ux = ux + 23
            if i % 6 == 0 then
              uy = uy + 23
              ux = 7
            end
          end
        end

      end
    end
  end
end

update_menus = function()
-- debugging ; displays all predictors in-game's ids and number of available shroom options
-- this should always be 24 + the sum of all shrooms added by mods using this patcher
  local l = ""
  local menu
  local openmenus = {}
  for k,v in pairs(tn.internals.openmenus) do
    openmenus[v] = k
  end  
  for k, menu in pairs(tn.internals.menus) do
    if menu ~= nil then
      if menu.label == "PREDICTOR1" or menu.label == "PREDICTOR2" then
        if openmenus[k] ~= nil then
          l = l .. "-- " .. tostring(menu.id) .. " " .. tostring(#menu.picker.props.options) .. " options\n"
        else
          l = l .. tostring(menu.id) .. " " .. tostring(#menu.picker.props.options) .. " options\n"
        end
      end
    end
  end
  return l
end


local patcher = {

  load = function(mod_id, shrooms)
    -- keep track of lowest available shroom id to properly insert shrooms with the right names
    shroom_id_min = game.g.mushroom_total+1
    shroom_id_max = game.g.mushroom_total+#shrooms
    

    local i=0
    -- create new shrooms
    for m=shroom_id_min,shroom_id_max do
      i = i+1
      shroom = shrooms[i]
      game.g.dictionary["mushroom" .. tostring(m)] = {
        oid = 'mushroom' .. tostring(m),
        category = 'mushrooms',
        action = 'action_hand',
        tools = {'mouse', 'mag'},
        machines = {'grinder', 'npc2'},
        conditions = shroom.info.conditions,
        anim = 2,
        pickable = '',
        buff = shroom.info.buff,
        buff_col = shroom.info.buff_col,
        buff_mod = shroom.info.buff_mod,
        drops = {{'mushroom' .. tostring(m), shroom.info.drops.dmin, shroom.info.drops.dmax}},
        world = shroom.info.world
      }

      -- shroom colors ; still need to figure each one of those out
      game.g.colors["mushroom" .. tostring(m)] = {tn.util.hexToRGB(shroom.colors[1]),tn.util.hexToRGB(shroom.colors[2]),tn.util.hexToRGB(shroom.colors[3]),tn.util.hexToRGB(shroom.colors[4]),tn.util.hexToRGB(shroom.colors[5]),tn.util.hexToRGB(shroom.colors[6])}

      -- shroom descriptions
      game.g.locale["mushroom" .. tostring(m) .. "_name"] = shroom.locale.name
      game.g.locale["mushroom" .. tostring(m) .. "_tooltip"] = shroom.locale.tooltip
      game.g.locale["mushroom" .. tostring(m) .. "_hint"] = shroom.locale.hint
      game.g.locale["mushroom" .. tostring(m) .. "_spore"] = shroom.locale.spore
      game.g.locale["mushroom" .. tostring(m) .. "_lore1"] = shroom.locale.lore1
      game.g.locale["mushroom" .. tostring(m) .. "_lore2"] = shroom.locale.lore2


      -- choose a UI size according to how many modded shrooms are loaded in
      -- (bigger: 48 slots)
      -- (bigger: 72 slots)
      -- note: I don't have a UI design for 72+ slots... why would you need more than 48 modded shrooms T.T
      local new_ui_picker
      local height
      if shroom_id_max < 49 then
        new_ui_picker = tn.class.texture:new('my_ui_pciker' .. tostring(m), "mods/MushroomPatcher/bigger_ui_picker.png")
        height = 189
      else
        new_ui_picker = tn.class.texture:new('my_ui_pciker' .. tostring(m), "mods/MushroomPatcher/biggest_ui_picker.png")
        height = 281
      end
      patch_ui_picker_new(height)
      new_ui_picker:load({
        { "sp_predictor_selection", 0, 0, 146, height, 1}
      })

      -- shroom spritesheet + book texture
      local texture = tn.class.texture:new('mushroom_texture' .. tostring(m), mod_id .. shroom.texture_path)
      local spritesheet = tn.class.texture:new('my_spritesheet' .. tostring(m), mod_id .. shroom.sprite_path)
      texture:load({
        { "sp_book_mushroom" .. tostring(m), 0, 0, 144, 64, 1}
      })
      spritesheet:load({
        { "sp_cultivator_bg_region1", 0, 0, 16, 16, 1},
        { "sp_spawn_bg_region1", 16, 0, 16, 16, 1},

        { "sp_cultivator_bg_region2", 0, 16, 16, 16, 1},
        { "sp_spawn_bg_region2", 16, 16, 16, 16, 1},

        { "sp_cultivator_bg_region3", 0, 32, 16, 16, 1},
        { "sp_spawn_bg_region3", 16, 32, 16, 16, 1},

        { "sp_cultivator_bg_region4", 0, 48, 16, 16, 1},
        { "sp_spawn_bg_region4", 16, 48, 16, 16, 1},

        { "sp_cultivator_bg_region5", 0, 64, 16, 16, 1},
        { "sp_spawn_bg_region5", 16, 64, 16, 16, 1},

        { "sp_cultivator_bg_region6", 0, 80, 16, 16, 1},
        { "sp_spawn_bg_region6", 16, 80, 16, 16, 1},

        { "sp_cultivator_bg_region7", 0, 96, 16, 16, 1},
        { "sp_spawn_bg_region7", 16, 96, 16, 16, 1},
        
        { "sp_magicmud_mushroom" .. tostring(m), 0, 112, 16, 16, 2},

        { "sp_mushroom" .. tostring(m) .. "_item", 0, 128, 16, 16, 2},

        { "sp_powder" .. tostring(m) .. "_item", 0, 144, 16, 16, 2},

        { "sp_mushroom" .. tostring(m), 0, 160, 16, 16, 2},

        { "sp_mushroom" .. tostring(m) .. "_spawn", 0, 176, 16, 16, 1},

        { "sp_slot_mushroom" .. tostring(m), 0, 192, 7, 7, 2},

        { "sp_spore" .. tostring(m) .. "_item", 0, 208, 16, 16, 2},

        { "sp_sprint_mushroom" .. tostring(m), 0, 224, 16, 16, 2},

        { "sp_mushroom" .. tostring(m) .. "_hybrid", 0, 240, 16, 16, 2},

        { "sp_mushroom" .. tostring(m) .. "_spawn_hybrid", 0, 256, 16, 16, 1},

        { "sp_mushroom" .. tostring(m) .. "_hybrid_item", 16, 256, 16, 16, 1},

        { "sp_powder".. tostring(m) .. "_hybrid_item", 0, 272, 16, 16, 1},

      })
    end

    print('Patcher loaded')

    return true
  end,

  draw = function(type, camera_x, camera_y) 
    -- draw debugging info for mod development
    -- label = update_menus()
    if type == 'obj' then
      tn.draw.text(label, math.floor(game.g.player.x - camera_x), math.floor(game.g.player.y - camera_y))
    end
  end,

  start = function(shrooms)
    local i=0
    for m=shroom_id_min,shroom_id_max do
      i = i+1
      shroom = shrooms[i]
      local new_chapter = {
        title = game.g.locale['mushroom' .. tostring(m) .. '_name'],
        title_key = 'mushroom' .. tostring(m) .. '_name',
        icon = 'mushroom' .. tostring(m)
      }
      -- second 'category' for book2 is the mushrooms category
      table.insert(game.g.books.book2[2].chapters, new_chapter)

      -- update the player book instance
      local book2 = game.g.player.book2
      local category = book2.props.categories[2]
      local index = game.g.mushroom_total + 1 -- set the index to 1 greater than the shroom total
      local chapter = game.class.ui_chapter:new(0, 0, book2, 'mushroom' .. tostring(m), category, m, 'mushrooms', index, index, false)
      chapter.props.key = index
      table.insert(category.props.chapters, chapter)
      game.g.mushroom_total = index -- update the shroom total

      -- default prog (copied from game files)
      if game.g.progress.mushrooms['mushroom' .. tostring(m)] == nil then
        game.g.progress.mushrooms['mushroom' .. tostring(m)] = {
          unlocked = true,
          read = false,
          discovered = 0,
          spores = false,
        }
      end

    end

    -- patch preexisting predictor menu ui_picker instances to include modded shrooms
    local height
      if shroom_id_max < 49 then
        height = 189
      else
        height = 281
      end
    patch_ui_picker_existing(height, shroom_id_min, shroom_id_max)

  end

}



return patcher