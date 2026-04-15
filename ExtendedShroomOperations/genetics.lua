return {
    patch_genetics = function()
        game.genetics.calculateChange = function(mushroom1, mushroom2, mushroom3, mushroom4, mushroom5, mushroom6)
            local traits = {
            trait_a = 0,
            trait_n = 0,
            trait_o = 0,
            trait_u = 0,
            trait_r = 0,
            trait_e = 0,
            trait_s = 0
            }
            local avail_traits = {"trait_a", "trait_n", "trait_o", "trait_u", "trait_r", "trait_e", "trait_s"}
            local multipliers = {}
            local finaliers = {}
            local mushrooms = {}
            if mushroom1 ~= '' and mushroom1 ~= nil then table.insert(mushrooms, mushroom1) end
            if mushroom2 ~= '' and mushroom2 ~= nil then table.insert(mushrooms, mushroom2) end
            if mushroom3 ~= '' and mushroom3 ~= nil then table.insert(mushrooms, mushroom3) end
            if mushroom4 ~= '' and mushroom4 ~= nil then table.insert(mushrooms, mushroom4) end
            if mushroom5 ~= '' and mushroom5 ~= nil then table.insert(mushrooms, mushroom5) end
            if mushroom6 ~= '' and mushroom6 ~= nil then table.insert(mushrooms, mushroom6) end
            -- do basic addition/subtraction first
            for m=1,#mushrooms do
            local def = game.g.dictionary[mushrooms[m]]
            if def then
                for b=1,#def.buff_col do
                local trait = def.buff_col[b]
                local modify = def.buff_mod[b]
                if trait == 'trait_random' then
                    trait = avail_traits[ math.random(#avail_traits) ]
                end
                if modify == '➕1' then
                    traits[trait] = traits[trait] + 1
                elseif modify == '➖1' then
                    traits[trait] = traits[trait] - 1
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
                traits[trait] = traits[trait] * 2
            elseif modify == '*-1' then
                traits[trait] = traits[trait] * -1
            elseif modify == '/2' then
                traits[trait] = math.floor(traits[trait] / 2)
            elseif modify == '^2' then
                traits[trait] = traits[trait] ^ 2
            end
            end
            -- then apply finaliers
            for f=1,#finaliers do
            local trait = finaliers[f][1]
            local modify = finaliers[f][2]
            if modify == 'MAX' then
                traits[trait] = 999
            elseif modify == 'MIN' then
                traits[trait] = -999
            end
            end
            for f=1,#finaliers do
            local trait = finaliers[f][1]
            local modify = finaliers[f][2]
            if modify == 'SUPRESS' then
                traits[trait] = 0
            end
            end
            return traits
        end
    end
}