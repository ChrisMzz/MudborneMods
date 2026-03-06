
return {
    {
        info = {
            conditions = {5, 4, 'dream', 'mud', 'any', false},
            buff = {'{{MAX}} {{TRAIT}}', 'x{{NUM}} {{TRAIT}}'},
            buff_col = {'trait_n', 'trait_o'},
            buff_mod = {'MAX', '*2'},
            drops = {
                dmin=1,
                dmax=2
            },
            world = 'dream'
        },
        locale = {
            name = 'Mushroom Name',
            tooltip = 'Mushroom Tooltip',
            hint = 'Text displayed to tell you how to look for the mushroom',
            spore = "Text that displays once you've seen the spores but not collected the mushroom",
            lore1 = 'Random fact about this mushroom',
            lore2 = 'Other random fact about this mushroom'
        },
        sprite_path = '/shroom_sprites_template.png',
        texture_path = '/shroom_texture_template.png'
    },

}