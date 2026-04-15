return {
    patch_ui = function() 
        game.ui.getTooltip = function()

            -- check mouse errors first before we begin
            game.g.mouse:call('error')

            local last_tooltip = game.g.tooltip_key .. ''
            local shift = game.g.input:held("SHIFT")
            if game.g.settings.a11y.expand_tooltips then
            shift = true
            end
            if game.g.gamepad and game.g.joystick and (game.g.joystick:getGamepadAxis('triggerleft') > 0.3 or game.g.joystick:getGamepadAxis('triggerright') > 0.3) then
            shift = true
            end
        
            local title = nil
            local category = nil
            local subtitle = {}
            local desc = nil
            local action = nil
            local action2 = nil
            local icon_label = nil
            local icons = { icons = {} }
            local mushrooms = {}
            local override = false
            local traits = nil
            local quickerr = nil
            local hp = nil
            local extra = {}
            local flooded = false
            local frozen = false
            local quantum = false
            local is_hybrid = false

            local titlecol = {207, 204, 202}
            local categorycol = {66, 110, 97}
            local desccolor = {89, 130, 145}
            local subtitlecolor = {67, 99, 117}
            if game.g.settings.a11y.hc_tooltips then
            titlecol = {220, 220, 0}
            categorycol = {150, 150, 150}
            desccolor = {220, 220, 220}
            subtitlecolor = {220, 0, 220}
            end

            -- ignore pet frog
            if game.g.highlighted_obj ~= nil and game.g.highlighted_obj.oid == 'frog' and game.g.highlighted_obj.props.pet then


            -- ignore decor + domes
            elseif game.g.highlighted_obj ~= nil and (game.g.highlighted_obj.oid:find('decor') == 1 or game.g.highlighted_obj.oid:find('dome') == 1) then
            
            

            -- notifications need to ignore the mouse errors if any
            elseif game.g.highlighted_obj ~= nil and game.g.highlighted_obj.oid == 'notification' then
            --game.g.tooltip_key = game.g.highlighted_obj.props.type .. game.g.highlighted_obj.props.icon
            --title = { text = 'Notification', color = {207, 204, 202} }
            --desc = { text = 'Click to open!', color = {89, 130, 145} }
        
            -- errors just have a title
            elseif game.g.mouse.props.error and game.g.mouse.props.error_msg ~= '' then
            game.g.tooltip_key = game.g.mouse.props.error_msg
            title = { text = game.g.mouse.props.error_msg, color = {182, 90, 112} }
        
            -- same for 'info' prompts
            elseif game.g.mouse.props.info and game.g.mouse.props.info_msg ~= '' then
            game.g.tooltip_key = game.g.mouse.props.info_msg
            title = { text = game.g.mouse.props.info_msg, color = {89, 130, 145} }

            -- objects have a title, category, desc + icons
            elseif game.g.highlighted_obj ~= nil then
        
            game.g.tooltip_key = game.g.highlighted_obj.oid .. tn.util.ternary(shift, '-shift', '')
            local def = game.g.dictionary[game.g.highlighted_obj.oid] or { name = 'UNDEFINED', oid = 'UNDEFINED', tooltip = 'UNDEFINED', category = 'nature' }
            local stats = nil
            if game.g.highlighted_obj.oid == 'spawn' and game.g.highlighted_obj.props.moid ~= '' then
                def = game.g.dictionary[game.g.highlighted_obj.props.moid]
            end
            local tooltip_oid = game.g.highlighted_obj.oid
            if def.tooltip_oid then
                tooltip_oid = def.tooltip_oid
            end
            if game.g.highlighted_obj.oid == 'item' then
                tooltip_oid = game.g.highlighted_obj.props.item
                def = game.g.dictionary[game.g.highlighted_obj.props.item]
                if def == nil then
                tooltip_oid = game.g.highlighted_obj.props.item_def
                def = game.g.dictionary[game.g.highlighted_obj.props.item_def]
                end
                stats = game.g.highlighted_obj.props.stats
            end
            local name = game.g.locale[tooltip_oid .. '_name']
            if game.g.highlighted_obj.oid ~= 'item' and def.oid == 'frog' then
                local variant = game.g.highlighted_obj.props.traits.variant
                local species = game.g.highlighted_obj.props.traits.species
                if variant == nil then variant = 'a' end
                if species == nil then species = 'frog1' end
                game.g.tooltip_key = game.g.tooltip_key .. '-' .. species .. '-' .. variant
                name = game.g.locale[species .. '_name']
                stats = game.g.highlighted_obj.props.traits
            end
            if game.g.highlighted_obj == game.g.player then
                name = name:gsub('{{NAME}}', game.g.player.props.name)
            end
            if tooltip_oid:find('plush') then
                local frog = game.g.highlighted_obj.oid:gsub('plush', 'frog')
                if name == nil then name = game.g.locale['plush_name'] end
                if frog ~= 'item' then
                name = name:gsub('{{SPECIES}}', game.g.locale[frog .. '_name'])
                end
                game.g.tooltip_key = game.g.tooltip_key .. frog
            end
            if def == nil then def = { name = 'UNDEFINED', oid = 'UNDEFINED', tooltip = 'UNDEFINED', category = 'nature' } end
            if def.oid:find('pool') == 1 then
                name = game.g.locale['gate' .. tostring(game.g.highlighted_obj.props.pid) .. '_name']
            end
            if def.oid:find('mushroom') or def.oid:find('powder') or def.oid:find('spore') then
                local mushroom = def.oid:gsub('powder', 'mushroom')
                mushroom = mushroom:gsub('spore', 'mushroom')
                if def.oid:find('powder') then
                name = game.g.locale['powder_name']:gsub('{{MUSHROOM}}', game.g.locale[mushroom .. '_name'])
                elseif def.oid:find('spore') then
                name = game.g.locale['spore_name']:gsub('{{MUSHROOM}}', game.g.locale[mushroom .. '_name'])
                else
                name = game.g.locale[mushroom .. '_name']
                end
            end
            local mushroom_split = nil
            if def.oid == 'hmushroom' then
                local mushids = game.g.highlighted_obj.props.item:gsub('hmushroom', 'mushroom')
                mushroom_split = tn.util.split(mushids, '([^_]+)')
                name = game.g.locale['hmushroom_name']:gsub('{{MUSHROOM1}}', game.g.locale[mushroom_split[1] .. '_name'])
            end
            if def.oid == 'hpowder' then
                local mushids = game.g.highlighted_obj.props.item:gsub('powder', 'mushroom')
                mushids = mushids:gsub('hmushroom', 'mushroom')
                mushroom_split = tn.util.split(mushids, '([^_]+)')
                name = game.g.locale['hpowder_name']:gsub('{{MUSHROOM1}}', game.g.locale[mushroom_split[1] .. '_name'])
            end
            if game.g.world == 'dream' and game.g.locale[tooltip_oid .. '_name_dream'] then
                name = game.g.locale[tooltip_oid .. '_name_dream']
            end
            if (def.oid:find('door') or def.oid == 'ladderup') and game.g.highlighted_obj.props.locked == true then
                name = game.g.locale['door_name_locked']
                table.insert(extra, {
                text = game.g.locale['ui_overworld_locked'], color = game.g.colors.font_temperature
                })
                table.insert(extra, {
                text = tn.util.ternary(def.oid == 'ladderup', game.g.locale['ui_locked_prompt_ladderup'], game.g.locale['ui_locked_prompt_door']), color = game.g.colors.font_temperature
                })
                table.insert(icons.icons, 'sp_' .. game.g.highlighted_obj.props.key .. '_item')
            end
            if def.oid == 'lift' and game.g.highlighted_obj.props.missing ~= '' then
                table.insert(extra, {
                text = game.g.locale['ui_overworld_broken'], color = game.g.colors.font_temperature
                })
            end
            if (def.oid == 'ladderdown' or def.oid == 'ladderup') and game.g.highlighted_obj.props.closed == true then
                table.insert(extra, {
                text = game.g.locale['ui_overworld_closed'], color = game.g.colors.font_temperature
                })
            end
            if def.oid == 'sign' and game.g.highlighted_obj.props.sign ~= '' then
                name = game.g.locale['sign_' .. game.g.highlighted_obj.props.sign]
            end
            if def.oid == 'sign2' and game.g.highlighted_obj.props.title ~= '' then
                name = game.g.highlighted_obj.props.title
            end
            if game.g.highlighted_obj.oid == 'spawn' and game.g.highlighted_obj.props.moid ~= '' and not game.g.highlighted_obj.props.blooming then
                name = game.g.locale['spore_name']:gsub('{{MUSHROOM}}', game.g.locale[game.g.highlighted_obj.props.moid .. '_name'])
            end
            if game.g.highlighted_obj.oid == 'bed' and game.g.highlighted_obj.props.npc > 0 then
                name = game.g.locale.bed_name_npc:gsub('{{NPC}}', game.g.locale['npc' .. tostring(game.g.highlighted_obj.props.npc) .. '_name'])
            end
            -- SET TITLE
            title = { text = name, color = titlecol}
            if def.oid == 'frog' then
                local gentext = game.g.locale['label_frog_gen']:gsub('{{NUMBER}}', game.ui.getNumerals(stats.gen))
                table.insert(subtitle, { text = gentext, color = {101, 161, 121}})
                if stats.variant ~= 'a' then
                table.insert(subtitle, { text = game.g.locale[stats.species .. stats.variant .. '_name'], color = game.g.colors[stats.species .. stats.variant]})
                end
                traits = stats
                if stats.species == 'frog30' then
                traits = { a = love.math.random(1, 7), n = love.math.random(1, 7), o = love.math.random(1, 7), u = love.math.random(1, 7), r = love.math.random(1, 7), e = love.math.random(1, 7), s = love.math.random(1, 7) }
                end
            end
            if def.oid == 'tadpoles' then
                traits = game.g.highlighted_obj.props.stats
            end
            -- SET CATEGORY
            category = { text = game.g.locale['category_' .. (def.category or 'UNKNOWN')], color = categorycol}
            local tooltip = game.g.locale[tooltip_oid .. '_tooltip']
            if (def.oid:find('door')) and game.g.highlighted_obj.props.locked == true then
                tooltip = game.g.locale['door_tooltip_locked']
            end
            if def.oid:find('powder') then
                tooltip = game.g.locale['powder_tooltip']:gsub('{{MUSHROOM}}', game.g.locale[def.oid:gsub('powder', 'mushroom') .. '_name'])
            end
            if def.oid:find('spore') then
                tooltip = game.g.locale['spore_tooltip']:gsub('{{MUSHROOM}}', game.g.locale[def.oid:gsub('spore', 'mushroom') .. '_name'])
            end
            if def.oid == 'hmushroom' then
                tooltip = game.g.locale['hmushroom_tooltip']:gsub('{{MUSHROOM1}}', game.g.locale[mushroom_split[1] .. '_name'])
                tooltip = tooltip:gsub('{{MUSHROOM2}}', game.g.locale[mushroom_split[2] .. '_name'])
            end
            if def.oid == 'hpowder' then
                tooltip = game.g.locale['hpowder_tooltip']:gsub('{{MUSHROOM1}}', game.g.locale[mushroom_split[1] .. '_name'])
                tooltip = tooltip:gsub('{{MUSHROOM2}}', game.g.locale[mushroom_split[2] .. '_name'])
            end
            if game.g.world == 'dream' and game.g.locale[tooltip_oid .. '_tooltip_dream'] then
                tooltip = game.g.locale[tooltip_oid .. '_tooltip_dream']
            end
            -- broken bridges
            if tooltip_oid == 'bridge' then
                if game.g.highlighted_obj.oid == 'bridge1' or game.g.highlighted_obj.oid == 'bridge2' then
                tooltip = game.g.locale[tooltip_oid .. '_tooltip_alt']
                end
            end
            if (def.oid == 'door' or def.oid == 'ladderup') and game.g.highlighted_obj.props.locked == true then
                tooltip = game.g.locale[game.g.highlighted_obj.oid .. '_tooltip_locked']
            end
            if game.g.highlighted_obj.oid == 'bed' and game.g.highlighted_obj.props.npc > 0 then
                local tooltip_id = tn.util.ternary(game.g.tod == 'night' and game.g.world == 'awake', 'bed_tooltip_npc_alt', 'bed_tooltip_npc')
                if game.g.highlighted_obj.props.npc == 5 then
                tooltip_id = tn.util.ternary(game.g.world == 'awake', 'bed_tooltip_npc_dendro', 'bed_tooltip_npc_dendro2')
                end
                tooltip = game.g.locale[tooltip_id]:gsub('{{NPC}}', game.g.locale['npc' .. tostring(game.g.highlighted_obj.props.npc) .. '_name'])
            end
            if game.g.highlighted_obj.oid:find('gateway') and game.g.highlighted_obj.props.nomenu then
                tooltip = game.g.locale['gateway_tooltip_nomenu']
            end
            if def.oid == 'ladderup' and game.g.highlighted_obj.props.closed == true then
                tooltip = game.g.locale['ladder_tooltip_closed']
            end
            -- SET DESC
            desc = { text = tn.util.ternary(shift, tooltip, game.g.locale['ui_tooltip_shift']), color = desccolor }
            if def.action ~= nil then
                local action_label = def.action
                if game.g.highlighted_obj.oid == 'spawn' then
                action_label = 'action_mag'
                end
                action = { text = game.g.locale['label_' .. action_label], color = {35, 158, 154}}
            end
            if def.oid:find('pillar') == 1 then
                action = { text = tn.util.ternary(game.g.world == 'dream', game.g.highlighted_obj.props.dcode, game.g.highlighted_obj.props.wcode), color = {35, 158, 154}}
            end
            if def.oid:find('critter') then
                action2 = { text = game.g.locale['label_action_tongue'], color = {35, 158, 154}}
            end
            if def.oid:find('zen') == 1 then
                action = { text = game.g.locale['ui_zen_desc'], color = {35, 158, 154} }
            end
            if def.oid:find('dtree') and game.g.world == 'dream' and game.g.highlighted_obj and game.g.highlighted_obj.props.restored then
                quickerr = { text = game.g.locale['ui_matriarch_done'], color = {186, 183, 219}}
                action = { text = game.g.locale['ui_matriarch_done'], color = {186, 183, 219}}
            end
            if def.oid:find('mushroom') == 1 or def.oid:find('powder') == 1 or def.oid:find('spore') == 1 then
                local mushroom = def.oid:gsub('powder', 'mushroom')
                mushroom = mushroom:gsub('spore', 'mushroom')
                if game.g.progress.mushrooms[mushroom].discovered == 1 then
                table.insert(mushrooms, {mushroom, 1})
                else
                table.insert(extra, { text = game.g.locale['ui_label_unknown_effects'], color = game.g.colors.font_lbgrey})
                end
            end
            if def.oid == 'hmushroom' or def.oid == 'hpowder' then
                table.insert(mushrooms, {mushroom_split[1], 1})
                table.insert(mushrooms, {mushroom_split[2], 1})
            end
            if def.oid:find('gateway') then
                if game.g.highlighted_obj then
                -- nexus shows region names
                local region = ''
                if game.g.highlighted_obj.x >= 6400 and game.g.highlighted_obj.y <= 1280 then
                    if game.g.highlighted_obj.props.link >= 100 then
                    region = 'sign_xx_title'
                    else
                    if game.g.highlighted_obj.props.link == 1 then region = 'map1_name' end
                    if game.g.highlighted_obj.props.link == 2 then region = 'map9_name' end
                    if game.g.highlighted_obj.props.link == 3 then region = 'map3_name' end
                    if game.g.highlighted_obj.props.link == 4 then region = 'map3_name' end
                    if game.g.highlighted_obj.props.link == 5 then region = 'map5_name' end
                    if game.g.highlighted_obj.props.link == 6 then region = 'map5_name' end
                    if game.g.highlighted_obj.props.link == 7 then region = 'map7_name' end
                    if game.g.highlighted_obj.props.link == 8 then region = 'map7_name' end
                    if game.g.highlighted_obj.props.link == 9 then region = 'map12_name' end
                    end
                else
                    region = 'note702_name'
                end
                table.insert(extra, {
                    text = game.g.locale[region],
                    color = game.g.colors.font_orange
                })
                end
            end
            local tools = def.tools
            if (game.g.highlighted_obj.oid == 'cultivator' or game.g.highlighted_obj.oid == 'scultivator') and game.g.highlighted_obj.props.moid ~= '' then
                local mushroom = game.g.locale[game.g.highlighted_obj.props.moid .. '_name']
                if game.g.highlighted_obj.oid == 'scultivator' then
                mushroom = game.g.locale['hmushroom_name']:gsub('{{MUSHROOM1}}', mushroom)
                end
                table.insert(extra, {
                text = mushroom,
                color = game.g.colors[game.g.highlighted_obj.props.moid][2]
                })
                if game.g.highlighted_obj.props.blooming == false then
                quickerr = { text = game.g.locale['error_not_in_bloom_q'], color = {182, 90, 112} }
                action = { text = game.g.locale['error_not_in_bloom'], color = {182, 90, 112} }
                game.g.tooltip_key = game.g.tooltip_key .. 'error_not_in_bloom_q'
                else
                quickerr = { text = game.g.locale['ui_cultivator_tank_ready'], color = {101, 161, 121} }
                action = { text = game.g.locale['ui_cultivator_tank_ready'], color = {101, 161, 121}  }
                end
            end
            if game.g.highlighted_obj.oid == 'spawn' and game.g.highlighted_obj.props.moid ~= '' then
                if game.g.highlighted_obj.props.blooming == false then
                quickerr = { text = game.g.locale['error_not_in_bloom_q'], color = {182, 90, 112} }
                action = { text = game.g.locale['error_not_in_bloom'], color = {182, 90, 112} }
                game.g.tooltip_key = game.g.tooltip_key .. 'error_not_in_bloom_q'
                end
            end
            if game.g.highlighted_obj.oid == 'player' and game.g.player.props.hp > 0 then
                quickerr = { text = game.g.locale['ui_player_eaten'], color = {101, 161, 121} }
            end
            if game.g.highlighted_obj.oid == 'farmer' and game.g.highlighted_obj.props.hready then
                quickerr = { text = game.g.locale['ui_cultivator_tank_ready'], color = {101, 161, 121} }
                action = { text = game.g.locale['ui_cultivator_tank_ready'], color = {101, 161, 121}  }
            end
            if game.g.highlighted_obj.oid:find('zen') == 1 then
                action = { text = game.g.locale['ui_zen_desc'], color = {89, 130, 145} }
            end
            if game.g.highlighted_obj.oid == 'bed' and game.g.highlighted_obj.props.npc > 0 then
                tools = {'mouse'}
            end
            if game.g.highlighted_obj.oid:find('stonechest') and game.g.highlighted_obj.props.open then
                tools = {'mouse', 'hammer'}
            end
            if tools ~= nil then
                icon_label = { text = game.g.locale['ui_tooltip_interact'], color = subtitlecolor}
                for t=1,#tools do
                table.insert(icons.icons, 'sp_' .. tools[t] .. '_item')
                end
                if (game.g.highlighted_obj.oid == 'spawn' or game.g.highlighted_obj.oid == 'cultivator') and game.progress.isDiscovered('net2') then
                table.insert(icons.icons, 'sp_net2_item')
                end
            end
            flooded = game.g.highlighted_obj.props.flood and game.g.highlighted_obj.props.flood ~= '' and game.g.highlighted_obj.props.flood > 0
            quantum = game.g.highlighted_obj.props.quantum
            frozen = game.g.highlighted_obj.props.frozen
        
            elseif game.g.highlighted_ui ~= nil then
            
            -- slot item tooltips
            if game.g.highlighted_ui.type == 'slot' then
        
                local oid = game.g.highlighted_ui.props.item
                if game.g.dictionary[oid] and game.g.dictionary[oid].tooltip_oid then
                oid = game.g.dictionary[oid].tooltip_oid
                end
                local is_defined = game.g.dictionary[oid]
                if oid:find('hmushroom') == 1 or oid:find('hpowder') == 1 or oid == 'plush' then
                is_defined = true
                end
                if oid ~= '' and is_defined then
                game.g.tooltip_key = oid .. tn.util.ternary(shift, '-shift', '')
                local def = game.g.dictionary[oid] or { oid = 'UNDEFINED', name = 'UNDEFINED', tooltip = 'UNDEFINED', category = 'nature' }
                local name = game.g.locale[oid .. '_name']
                if game.g.world == 'dream' and game.g.locale[oid .. '_name_dream'] then
                    name = game.g.locale[oid .. '_name_dream']
                end
                if oid == 'frog' or oid == 'frogspawn' then
                    local variant = game.g.highlighted_ui.props.stats.variant
                    local species = game.g.highlighted_ui.props.stats.species
                    if variant == nil then variant = 'a' end
                    if species == nil then species = 'frog1' end
                    game.g.tooltip_key = game.g.tooltip_key .. '-' .. species .. '-'
                    .. variant .. '-' .. tostring(game.g.highlighted_ui.props.index)
                    name = game.g.locale[species .. '_name']
                end
                if def.oid:find('mushroom') or def.oid:find('powder') or def.oid:find('spore') then
                    local mushroom = def.oid:gsub('powder', 'mushroom')
                    mushroom = mushroom:gsub('spore', 'mushroom')
                    if def.oid:find('powder') then
                    name = game.g.locale['powder_name']:gsub('{{MUSHROOM}}', game.g.locale[mushroom .. '_name'])
                    elseif def.oid:find('spore') then
                    name = game.g.locale['spore_name']:gsub('{{MUSHROOM}}', game.g.locale[mushroom .. '_name'])
                    else
                    name = game.g.locale[mushroom .. '_name']
                    end
                end
                local mushroom_split = nil
                if oid:find('hmushroom') == 1 then
                    mushroom_split = tn.util.split(oid, '([^_]+)')
                    local mushroom = mushroom_split[1]:gsub('hmushroom', 'mushroom')
                    name = game.g.locale.hmushroom_name:gsub('{{MUSHROOM1}}', game.g.locale[mushroom .. '_name'])
                    def.category = 'mushrooms'
                    def.machines = {'grinder'}
                    is_hybrid = true
                end
                if oid:find('hpowder') == 1 then
                    local mushid = oid:gsub('powder', 'mushroom')
                    mushroom_split = tn.util.split(mushid, '([^_]+)')
                    local mushroom = mushroom_split[1]:gsub('hmushroom', 'mushroom')
                    name = game.g.locale.hpowder_name:gsub('{{MUSHROOM1}}', game.g.locale[mushroom .. '_name'])
                    def.category = 'mushrooms'
                    def.machines = {'cauldron'}
                    is_hybrid = true
                end
                if oid == 'plush' then
                    local frog = game.g.highlighted_ui.props.item:gsub('plush', 'frog')
                    name = name:gsub('{{SPECIES}}', game.g.locale[frog .. '_name'])
                    game.g.tooltip_key = game.g.tooltip_key .. frog
                end
                title = { text = name, color = titlecol}
                if def.oid == 'frog' or def.oid == 'frogspawn' or def.oid == 'tadpoles' then
                    local gentext = game.g.locale['label_frog_gen']:gsub('{{NUMBER}}', game.ui.getNumerals(game.g.highlighted_ui.props.stats.gen))
                    table.insert(subtitle, { text = gentext, color = {101, 161, 121}})
                    if def.oid ~= 'tadpoles' then
                    if game.g.highlighted_ui.props.stats.variant and game.g.highlighted_ui.props.stats.variant ~= 'a' then
                        table.insert(subtitle, { text = game.g.locale[game.g.highlighted_ui.props.stats.species .. game.g.highlighted_ui.props.stats.variant .. '_name'], color = game.g.colors[game.g.highlighted_ui.props.stats.species .. game.g.highlighted_ui.props.stats.variant]})
                    end
                    end
                    traits = game.g.highlighted_ui.props.stats
                    if game.g.highlighted_ui.props.stats.species == 'frog30' then
                    traits = { a = love.math.random(1, 7), n = love.math.random(1, 7), o = love.math.random(1, 7), u = love.math.random(1, 7), r = love.math.random(1, 7), e = love.math.random(1, 7), s = love.math.random(1, 7) }
                    end
                end
                if def.oid:find('critter') and shift == true then
                    if game.g.progress.critters[def.oid].eaten > 0 then
                    table.insert(extra, {
                        text = game.g.locale['label_taste_' .. game.g.dictionary[def.oid].taste], color = game.g.colors.help_orange
                    })
                    else
                    table.insert(extra, {
                        text = game.g.locale['ui_book2_notaste'], color = game.g.colors.font_lbgrey
                    })
                    end
                end
                if def.oid == 'tadpoles' then
                    traits = game.g.highlighted_ui.props.stats
                end
                category = { text = game.g.locale['category_' .. def.category], color = categorycol}
                local tooltip_def = game.g.locale[oid .. '_tooltip']
                if game.g.world == 'dream' and game.g.locale[oid .. '_tooltip_dream'] then
                    tooltip_def = game.g.locale[oid .. '_tooltip_dream']
                end
                local tooltip = tn.util.ternary(shift, tooltip_def, game.g.locale['ui_tooltip_shift'])
                if shift and def.oid:find('powder') then
                    tooltip = game.g.locale['powder_tooltip']:gsub('{{MUSHROOM}}', game.g.locale[def.oid:gsub('powder', 'mushroom') .. '_name'])
                end
                if shift and def.oid:find('spore') then
                    tooltip = game.g.locale['spore_tooltip']:gsub('{{MUSHROOM}}', game.g.locale[def.oid:gsub('spore', 'mushroom') .. '_name'])
                end
                if shift and oid:find('hmushroom') == 1 and mushroom_split then
                    local mushroom = mushroom_split[1]:gsub('hmushroom', 'mushroom')
                    tooltip = game.g.locale.hmushroom_tooltip:gsub('{{MUSHROOM1}}', game.g.locale[mushroom .. '_name'])
                    tooltip = tooltip:gsub('{{MUSHROOM2}}', game.g.locale[mushroom_split[2] .. '_name'])
                end
                if shift and oid:find('hpowder') == 1 and mushroom_split then
                    local mushroom = mushroom_split[1]:gsub('hmushroom', 'mushroom')
                    tooltip = game.g.locale.hpowder_tooltip:gsub('{{MUSHROOM1}}', game.g.locale[mushroom .. '_name'])
                    tooltip = tooltip:gsub('{{MUSHROOM2}}', game.g.locale[mushroom_split[2] .. '_name'])
                end
                if def.pocket and game.g.gamepad then
                    tooltip = tooltip:gsub('<sp_key_mouseright>', '<sp_gp_rstick>')
                end
                desc = { text = tooltip, color = desccolor }
                if def.item_action ~= nil then
                    action = { text = game.g.locale['label_' .. def.item_action], color = {35, 158, 154}}
                end
                if def.oid:find('zen') == 1 then
                    action = { text = game.g.locale['ui_zen_desc'], color = {35, 158, 154} }
                end
                if def.oid:find('mushroom') or def.oid:find('powder') or def.oid:find('spore') then
                    local mushroom = def.oid:gsub('powder', 'mushroom')
                    mushroom = mushroom:gsub('spore', 'mushroom')
                    if game.g.progress.mushrooms[mushroom].discovered == 1 then
                    table.insert(mushrooms, {mushroom, 1})
                    else
                    table.insert(extra, { text = game.g.locale['ui_label_unknown_effects'], color = game.g.colors.font_lbgrey})
                    end
                end
                if oid and (oid:find('hmushroom') == 1 or oid:find('hpowder')) and mushroom_split then
                    table.insert(mushrooms, {mushroom_split[1]:gsub('hmushroom', 'mushroom'), 1})
                    table.insert(mushrooms, {mushroom_split[2], 1})
                end
                if def.oid == 'sprint' then
                    local stats = game.g.highlighted_ui.props.stats
                    if stats then
                    game.g.tooltip_key = game.g.tooltip_key .. '-' .. (stats.mushroom1 or '') .. '-' .. (stats.mushroom2 or '')
                    if stats.mushroom1 and stats.mushroom1 ~= '' and game.g.colors[stats.mushroom1] then
                        table.insert(extra, { text = game.g.locale[stats.mushroom1 .. '_name'], color = game.g.colors[stats.mushroom1][2]})
                    end
                    if stats.mushroom2 and stats.mushroom2 ~= '' and game.g.colors[stats.mushroom2] then
                        table.insert(extra, { text = game.g.locale[stats.mushroom2 .. '_name'], color = game.g.colors[stats.mushroom2][2]})
                    end
                    end
                    
                end
                if def.oid == 'magicmud' then
                    local vals = game.g.highlighted_ui.props.stats
                    local types = ''
                    if vals.mushroom1 ~= '' then table.insert(mushrooms, {vals.mushroom1, 1}); types = types .. vals.mushroom1 end
                    if vals.mushroom2 ~= '' then table.insert(mushrooms, {vals.mushroom2, 1}); types = types .. vals.mushroom2 end
                    if vals.mushroom3 ~= '' then table.insert(mushrooms, {vals.mushroom3, 1}); types = types .. vals.mushroom3 end
                    if vals.mushroom1_hybrid and vals.mushroom1_hybrid ~= '' then table.insert(mushrooms, {vals.mushroom1_hybrid, 1}); types = types .. vals.mushroom1_hybrid end
                    if vals.mushroom2_hybrid and vals.mushroom2_hybrid ~= '' then table.insert(mushrooms, {vals.mushroom2_hybrid, 1}); types = types .. vals.mushroom2_hybrid end
                    if vals.mushroom3_hybrid and vals.mushroom3_hybrid ~= '' then table.insert(mushrooms, {vals.mushroom3_hybrid, 1}); types = types .. vals.mushroom3_hybrid end
                    game.g.tooltip_key = game.g.tooltip_key .. tostring(#mushrooms) .. types
                end
                if game.g.highlighted_ui.props.stats.hp and game.g.highlighted_ui.props.stats.mhp then
                    hp = { game.g.highlighted_ui.props.stats.hp, game.g.highlighted_ui.props.stats.mhp }
                end
                if def.machines ~= nil then
                    icon_label = { text = game.g.locale['ui_tooltip_use'], color = subtitlecolor}
                    for t=1,#def.machines do
                    table.insert(icons.icons, 'sp_' .. def.machines[t] .. '_item')
                    end
                end
                else
                if game.g.highlighted_ui.props.type == 'none' then
                    game.g.tooltip_key = 'free_slot'
                    title = { text = game.g.locale['ui_slot_hand_name'], color = titlecol }
                    desc = { text = game.g.locale['ui_slot_hand_desc'], color = desccolor }
                elseif game.g.highlighted_ui.props.type == 'trash' then
                    game.g.tooltip_key = 'trash_slot'
                    title = { text = game.g.locale['ui_slot_trash_name'], color = titlecol }
                    desc = { text = game.g.locale['ui_slot_trash_desc'], color = desccolor }
                elseif game.g.highlighted_ui.props.type == 'pet' then
                    game.g.tooltip_key = 'pet_slot'
                    title = { text = game.g.locale['ui_slot_pet_name'], color = titlecol }
                    desc = { text = game.g.locale['ui_slot_pet_tooltip'], color = desccolor }
                    icon_label = { text = game.g.locale['ui_input_allowed'], color = subtitlecolor }
                    for t=1,#game.g.highlighted_ui.props.allowed do
                    table.insert(icons.icons, 'sp_' .. game.g.highlighted_ui.props.allowed[t] .. '_item')
                    end
                -- trait slot
                elseif game.g.highlighted_ui.props.type == 'trait' then
                    if game.g.highlighted_ui.props.trait_dir == 'special' then
                    game.g.tooltip_key = 'trait_slot' .. game.g.highlighted_ui.props.trait
                    title = { text = game.g.locale['ui_slot_trait_name'], color = titlecol }
                    desc = { text = game.g.locale['ui_slot_trait_special'], color = desccolor }
                    table.insert(icons.icons, 'sp_frogspawn_item')
                    elseif game.g.highlighted_ui.props.trait == 'any' then
                    game.g.tooltip_key = 'trait_slot' .. game.g.highlighted_ui.props.trait
                    title = { text = game.g.locale['ui_slot_trait_name'], color = titlecol }
                    local resetter = game.g.highlighted_ui:getMenu().inst.oid == 'resetter'
                    local desct = tn.util.ternary(resetter, 'ui_slot_trait_any_alt', 'ui_slot_trait_any')
                    desc = { text = game.g.locale[desct], color = desccolor }
                    table.insert(icons.icons, tn.util.ternary(resetter, 'sp_frogspawn_item', 'sp_frog1a_item'))
                    else
                    game.g.tooltip_key = 'trait_slot' .. game.g.highlighted_ui.props.trait
                    title = { text = game.g.locale['ui_slot_trait_name'], color = titlecol }
                    desc = { text = game.g.locale['ui_slot_trait_tooltip'], color = subtitlecolor }
                    local type = tn.util.ternary(game.g.highlighted_ui.props.trait_dir == 'max', 'Max.', 'Min.')
                    local num = tn.util.ternary(game.g.highlighted_ui.props.trait_dir == 'max', '(7)', '(1)')
                    table.insert(extra, { 
                        text = type .. ' ' .. game.g.locale['label_' .. game.g.highlighted_ui.props.trait] .. ' ' .. num,
                        color = game.g.colors[game.g.highlighted_ui.props.trait]
                    })
                    table.insert(icons.icons, tn.util.ternary(game.g.highlighted_ui:getMenu().inst.oid == 'resetter', 'sp_frogspawn_item', 'sp_frog1a_item'))
                    end
                elseif game.g.highlighted_ui.props.type == 'input' then
                    game.g.tooltip_key = 'input_slot'
                    title = { text = game.g.locale['ui_slot_input_name'], color = titlecol }
                    icon_label = { text = game.g.locale['ui_input_allowed'], color = subtitlecolor}
                    for t=1,#game.g.highlighted_ui.props.allowed do
                    table.insert(icons.icons, 'sp_' .. game.g.highlighted_ui.props.allowed[t] .. '_item')
                    game.g.tooltip_key = game.g.tooltip_key .. game.g.highlighted_ui.props.allowed[t]
                    end
                elseif game.g.highlighted_ui.props.type == 'output' then
                    game.g.tooltip_key = 'output_slot'
                    title = { text = game.g.locale['ui_slot_output_name'], color = titlecol }
                    desc = { text = game.g.locale['ui_slot_output_desc'], color = desccolor }
                end
                end
        
                if game.g.highlighted_ui.props.item == '' and game.g.highlighted_ui.props.index == 1 and game.g.highlighted_ui:getMenu().inst.oid:find('crate') then
                game.g.tooltip_key = 'crate_preview'
                title = { text = game.g.locale['ui_slot_preview_name'], color = titlecol}
                desc = { text = game.g.locale['ui_slot_preview_tooltip'], color = desccolor }
                end
        
            elseif game.g.highlighted_ui.scripts.tooltip ~= nil then
        
                local tooltip = game.g.highlighted_ui:call('tooltip', game.g.highlighted_ui:getMenu().inst)
                if tooltip ~= nil then
                local ttd = tooltip.desc
                if ttd == nil then ttd = '' end
                game.g.tooltip_key = 'ui_' .. game.g.highlighted_ui.type .. ttd
                title = { text = tooltip.title, color = titlecol}
                desc = { text = ttd, color = desccolor }
                extra = tooltip.extra or {}
                if tooltip.key then
                    game.g.tooltip_key = game.g.tooltip_key .. tooltip.key
                end
                if tooltip.mushrooms then
                    for m=1,#tooltip.mushrooms do
                    table.insert(mushrooms, {tooltip.mushrooms[m], 1})
                    end
                end
                if game.g.highlighted_ui.type == 'picker_option' then
                    game.g.tooltip_key = game.g.tooltip_key .. game.g.highlighted_ui.props.value
                    if game.g.highlighted_ui.props.discovered == 0 then
                    title.text = game.g.locale['ui_predictor_unknown_name']
                    desc.text = game.g.locale['ui_predictor_unknown_tooltip']
                    else
                    if game.g.highlighted_ui.props.value ~= '' then
                        local val = game.g.highlighted_ui.props.value
                        if val:find('hmushroom') == 1 then
                        local mushroom_split = tn.util.split(val, '([^_]+)')
                        local mushroom = mushroom_split[1]:gsub('hmushroom', 'mushroom')
                        title.text = game.g.locale.hmushroom_name:gsub('{{MUSHROOM1}}', game.g.locale[mushroom .. '_name'])
                        table.insert(mushrooms, {mushroom, 1})
                        table.insert(mushrooms, {mushroom_split[2], 1})
                        is_hybrid = true
                        else
                        table.insert(mushrooms, {val, 1})
                        end
                    end
                    end
                end
                if game.g.highlighted_ui.type == 'pick' then
                    game.g.tooltip_key = game.g.tooltip_key .. game.g.highlighted_ui.props.option .. game.g.highlighted_ui.props.hybrid
                end
                if game.g.highlighted_ui.type == 'traitkey' then
                    if game.g.highlighted_ui.props.trait_a[1] ~= 0 then
                    traits = {
                        a = game.g.highlighted_ui.props.trait_a[1],
                        n = game.g.highlighted_ui.props.trait_n[1],
                        o = game.g.highlighted_ui.props.trait_o[1],
                        u = game.g.highlighted_ui.props.trait_u[1],
                        r = game.g.highlighted_ui.props.trait_r[1],
                        e = game.g.highlighted_ui.props.trait_e[1],
                        s = game.g.highlighted_ui.props.trait_s[1]
                    }
                    if game.g.highlighted_ui.props.frog30 then
                        traits = { a = love.math.random(1, 7), n = love.math.random(1, 7), o = love.math.random(1, 7), u = love.math.random(1, 7), r = love.math.random(1, 7), e = love.math.random(1, 7), s = love.math.random(1, 7) }
                    end
                    end
                end
                if game.g.highlighted_ui.type == 'lock' then
                    local pool = game.g.highlighted_ui:getMenu().inst
                    local lock = pool.props.lock[game.g.highlighted_ui.props.lock]
                    if lock ~= 0 then
                    traits = {
                        a = lock.a[1],
                        n = lock.n[1],
                        o = lock.o[1],
                        u = lock.u[1],
                        r = lock.r[1],
                        e = lock.e[1],
                        s = lock.s[1]
                    }
                    end
                end
                end
                
            
            elseif game.g.locale['ui_' .. game.g.highlighted_ui.type .. '_name'] then
        
                game.g.tooltip_key = 'ui_' .. game.g.highlighted_ui.type
                local uititle = game.g.locale['ui_' .. game.g.highlighted_ui.type .. '_name']
                if game.g.tooltip_key == 'ui_bed_sleep5' then
                local menu = game.g.highlighted_ui:getMenu()
                uititle = uititle:gsub('{{TIME}}', tostring(menu.inst.props.hour) .. menu.inst.props.tod)
                end
                title = { text = uititle, color = titlecol}
                desc = { text = game.g.locale['ui_' .. game.g.highlighted_ui.type .. '_tooltip'], color = desccolor }
        
            end
        
            elseif game.g.highlighted_menu ~= nil and game.g.highlighted_menu.inst then
            
            if game.g.highlighted_menu.draggable then
                local oid = game.g.highlighted_menu.inst.oid
                game.g.tooltip_key = oid .. '-menu'
                local name = game.g.locale[oid .. '_name'] or 'UNDEFINED'
                if game.g.dictionary[oid] and game.g.dictionary[oid].tooltip_oid then
                name = game.g.locale[game.g.dictionary[oid].tooltip_oid .. '_name']
                end
                local mtitle = game.g.locale['ui_menu_title']:gsub('{{MACHINE}}', name)
                title = { text = mtitle, color = titlecol}
                desc = { text = game.g.locale['tooltip_menu_drag'], color = desccolor }
            end
        
            -- flooring have a smaller tooltip
            elseif game.g.highlighted_floor ~= nil then

            game.g.tooltip_key = game.g.highlighted_floor .. tn.util.ternary(shift, '-shift', '')
            local def = game.g.dictionary[game.g.highlighted_floor] or { name = 'UNDEFINED', oid = 'UNDEFINED', tooltip = 'UNDEFINED', category = 'nature' }
            local flooroid = def.oid
            if game.g.dictionary[game.g.highlighted_floor] and game.g.dictionary[game.g.highlighted_floor].tooltip_oid then
                flooroid = game.g.dictionary[game.g.highlighted_floor].tooltip_oid
            end
            local name = game.g.locale[flooroid .. '_name']
            local tooltip = game.g.locale[flooroid .. '_tooltip']
            title = { text = name, color = titlecol}
            category = { text = game.g.locale['category_' .. (def.category or 'UNKNOWN')], color = categorycol}
            desc = { text = tn.util.ternary(shift, tooltip, game.g.locale['ui_tooltip_shift']), color = desccolor }
            local tools = def.tools
            if tools ~= nil then
                icon_label = { text = game.g.locale['ui_tooltip_interact'], color = subtitlecolor}
                for t=1,#tools do
                table.insert(icons.icons, 'sp_' .. tools[t] .. '_item')
                end
            end
        
            -- nothing hjighlighted!
            else
        
            local max_allowed = 4
            if game.g.player.props.open then max_allowed = 5 end
            if game.g.book == nil and #tn.internals.openmenus > max_allowed then
                game.g.tooltip_key = 'close_all_menus'
                desc = { text = game.g.locale['tooltip_menu_close'], color = desccolor }
            end
        
            end
        
            if title ~= nil or desc ~= nil then
        
            game.g.tooltip.visible = true
        
            if game.g.tooltip_key ~= last_tooltip or game.g.tooltip_refresh then
                local max_width = tn.util.ternary(shift, game.g.tooltip_max, game.g.tooltip_min)
                if override == true then max_width = game.g.tooltip_max end
                game.g.tooltip:maxWidth(max_width)
                local lines = {
                title
                }
                if shift == true and category ~= nil then
                table.insert(lines, category)
                end
                if #subtitle > 0 then
                for s=1,#subtitle do
                    table.insert(lines, subtitle[s])
                end
                end
                if desc ~= nil then
                if game.g.gamepad then
                    desc.text = game.ui.convertKeys(desc.text)
                end
                table.insert(lines, desc)
                end
                if #extra then
                for e=1,#extra do
                    table.insert(lines, {
                    text = extra[e].text,
                    color = extra[e].color
                    })
                end
                end
                if shift ~= true and quickerr ~= nil then
                table.insert(lines, quickerr)
                end
                if shift == true and action ~= nil then
                table.insert(lines, action)
                end
                if shift == true and action2 ~= nil then
                table.insert(lines, action2)
                end
                if mushrooms == nil then mushrooms = {} end
                if #mushrooms > 0 then
                -- single mushrooms need to be different
                -- we do the same for hybrid powders/mushrooms so people dont get confused one why magic mud effects are the way they are
                -- otherwise x2 mushrooms get written as +1 for example
                if #mushrooms == 1 or is_hybrid then
                    for m=1,#mushrooms do
                    local smushroom = mushrooms[m][1]
                    if game.g.dictionary[smushroom] then
                        for b=1,#game.g.dictionary[smushroom].buff_col do
                        local bcol = game.g.dictionary[smushroom].buff_col[b]
                        local bmod = game.g.dictionary[smushroom].buff_mod[b]
                        local trait = game.g.locale['label_' .. bcol]
                        local line = trait .. ' ' .. bmod
                        if bmod == '*2' then line = game.g.locale['label_modifier_tt']:gsub('{{TRAIT}}', trait) end
                        if bmod == '*-1' then line = game.g.locale['label_modifier_tmo']:gsub('{{TRAIT}}', trait) end
                        if bmod == 'SUPRESS' then line = game.g.locale['label_modifier_ts']:gsub('{{TRAIT}}', trait) end
                        if bmod == 'MIN' then line = game.g.locale['label_modifier_mini']:gsub('{{TRAIT}}', trait) end
                        if bmod == 'MAX' then line = game.g.locale['label_modifier_maxi']:gsub('{{TRAIT}}', trait) end
                        if game.g.language == 'cn' or game.g.language == 'jp' then
                            line = line:gsub('➕', '+')
                            line = line:gsub('➖', '-')
                            line = line:gsub('*', 'x')
                        end
                        table.insert(lines, {
                            text = line,
                            color = game.g.colors[bcol]
                        })
                        end
                    end
                    end
                else
                    local btotals = {}
                    local multipliers = {}
                    local finaliers = {}
                    local avail_traits = {"trait_a", "trait_n", "trait_o", "trait_u", "trait_r", "trait_e", "trait_s"}
                    -- do basic addition/subtraction first
                    if mushrooms == nil then mushrooms = {} end
                    for m=1,#mushrooms do
                    if game.g.dictionary[mushrooms[m][1]] and game.g.dictionary[mushrooms[m][1]].buff_col then
                        for b=1,#game.g.dictionary[mushrooms[m][1]].buff_col do -- {'trait_a'}
                        local trait = game.g.dictionary[mushrooms[m][1]].buff_col[b] -- 'trait_a'
                        if trait == 'trait_random' then
                            trait = avail_traits[ math.random(#avail_traits) ]
                        end
                        local modify = game.g.dictionary[mushrooms[m][1]].buff_mod[b] -- '+1'
                        if btotals[trait] == nil then
                            btotals[trait] = 0
                        end
                        if modify == '➕1' then
                            btotals[trait] = btotals[trait] + 1
                        elseif modify == '➖1' then
                            btotals[trait] = btotals[trait] - 1
                        elseif modify == '*2' then
                            table.insert(multipliers, { trait, '*2' })
                        elseif modify == '*-1' then
                            table.insert(multipliers, { trait, '*-1' })
                        elseif modify == '/2' then
                            table.insert(multipliers, { trait, '/2' })
                        elseif modify == '^2' then
                            table.insert(multipliers, { trait, '^2' })
                        elseif modify == 'SUPRESS' then
                            table.insert(finaliers, { trait, 'SUPRESS' })
                        elseif modify == 'MAX' then
                            table.insert(finaliers, { trait, 'MAX' })
                        elseif modify == 'MIN' then
                            table.insert(finaliers, { trait, 'MIN' })
                        else
                            tn.logger.error('undefined trait modification', modify, mushrooms[m])
                        end
                        end
                    end
                    end
                    -- then apply multipliers
                    for m=1,#multipliers do
                    local trait = multipliers[m][1]
                    local modify = multipliers[m][2]
                    if modify == '*2' then
                        btotals[trait] = btotals[trait] * 2
                    elseif modify == '*-1' then
                        btotals[trait] = btotals[trait] * -1
                    end
                    end
                    for f=1,#finaliers do
                    local trait = finaliers[f][1]
                    local modify = finaliers[f][2]
                    if modify == 'MAX' then
                        btotals[trait] = 'MAX'
                    elseif modify == 'MIN' then
                        btotals[trait] = 'MIN'
                    end
                    end
                    for f=1,#finaliers do
                    local trait = finaliers[f][1]
                    local modify = finaliers[f][2]
                    if modify == 'SUPRESS' then
                        btotals[trait] = 'SUPRESS'
                    end
                    end
                    for t=1,#game.g.traits do
                    local key = 'trait_' .. game.g.traits[t]
                    local value = btotals[key]
                    if value ~= nil and type(value) == 'number' and value ~= 0 then
                        local vstr = tn.util.ternary(value > 0, '+' .. tostring(value), tostring(value))
                        if game.g.language == 'cn' or game.g.language == 'jp' then
                        vstr = vstr:gsub('➕', '+')
                        vstr = vstr:gsub('➖', '-')
                        vstr = vstr:gsub('*', 'x')
                        end
                        table.insert(lines, {
                        text = game.g.locale['label_' .. key] .. ' ' .. vstr,
                        color = game.g.colors[key]
                        })
                    end
                    if value ~= nil and type(value) == 'string' and value ~= '' then
                        local mkey = 'label_modifier_supress_sh'
                        if value == 'MAX' then mkey = 'label_modifier_max_sh' end
                        if value == 'MIN' then mkey = 'label_modifier_min_sh' end
                        table.insert(lines, {
                        text = game.g.locale[mkey]:gsub('{{TRAIT}}', game.g.locale['label_' .. key]),
                        color = game.g.colors[key]
                        })
                    end
                    end
                end
                end
                if hp ~= nil then
                local dura = tostring(hp[1]) .. '/' .. tostring(hp[2])
                table.insert(lines, {
                    text = game.g.locale['ui_tooltip_extra1']:gsub('{{DURA}}', dura),
                    color = game.g.colors.font_yellow
                })
                end
                if flooded == true then
                table.insert(lines, {
                    text = game.g.locale['ui_tooltip_extra2'],
                    color = game.g.colors.help_blue
                })
                end
                if quantum == true then
                table.insert(lines, {
                    text = game.g.locale['ui_tooltip_extra4'],
                    color = game.g.colors.font_dream1
                })
                end
                if frozen == true then
                table.insert(lines, {
                    text = game.g.locale['ui_tooltip_extra3'],
                    color = game.g.colors.font_cold
                })
                end
                if #icons.icons > 0 then
                if shift == true or game.g.tooltip_key:find('input_slot') then table.insert(lines, icon_label) end
                table.insert(lines, icons)
                end
                game.g.tooltip:set(lines)
            end
        
            else
            game.g.tooltip.visible = false
            end
        
            game.g.tooltip_traits = traits
        
        end
    end
}