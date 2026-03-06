
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
            name = 'Glowing Blimp',
            tooltip = 'Will get you high in more ways than one!',
            hint = 'This mushroom can be found while hallucinating on a dry evening.',
            spore = "I've seen spores of this mushroom on mud in the evening of the dream world.",
            lore1 = 'This mushroom looks puffy but is actually very dense.',
            lore2 = 'Its metabolism causes it to glow periodically.'
        },
        colors = {'#b0517c', '#aa4658', '#80385d', '#aa4658', '#80385d', '#c27281'},
        sprite_path = '/glowingblimp_sprites.png',
        texture_path = '/glowingblimp_texture.png'
    },

}