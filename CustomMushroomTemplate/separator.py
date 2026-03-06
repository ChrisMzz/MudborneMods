from PIL import Image
import numpy as np


def reorganize_sprites(shroom: np.ndarray):
    new_im = np.zeros((288,32,4), dtype=shroom.dtype)
    empty = np.zeros_like(shroom[:16])

    new_im[:16] = np.concatenate([shroom[:16], shroom[16:32]], axis=1)
    new_im[16:32] = np.concatenate([shroom[32:48], shroom[48:64]], axis=1)
    new_im[32:48] = np.concatenate([shroom[64:80], shroom[80:96]], axis=1)
    new_im[48:64] = np.concatenate([shroom[96:112], shroom[112:128]], axis=1)
    new_im[64:80] = np.concatenate([shroom[128:144], shroom[144:160]], axis=1)
    new_im[80:96] = np.concatenate([shroom[160:176], shroom[176:192]], axis=1)
    new_im[96:112] = np.concatenate([shroom[192:208], shroom[208:224]], axis=1)

    new_im[112:128] = np.concatenate([shroom[224:240], shroom[240:256]], axis=1)
    new_im[128:144] = np.concatenate([shroom[256:272], shroom[272:288]], axis=1)
    new_im[144:160] = np.concatenate([shroom[288:304], shroom[304:320]], axis=1)
    new_im[160:176] = np.concatenate([shroom[320:336], shroom[336:352]], axis=1)

    new_im[176:192] = np.concatenate([shroom[352:368], empty], axis=1)
    new_im[192:208] = np.concatenate([shroom[368:384], empty], axis=1)

    new_im[208:224] = np.concatenate([shroom[384:400], shroom[400:416]], axis=1)
    new_im[224:240] = np.concatenate([shroom[416:432], shroom[432:448]], axis=1)
    new_im[240:256] = np.concatenate([shroom[448:464], shroom[464:480]], axis=1)
    new_im[256:272] = np.concatenate([shroom[480:496], shroom[496:512]], axis=1)
    new_im[272:] = np.concatenate([shroom[512:], empty], axis=1)

    return new_im


spritesheet = np.array(Image.open("spritesheet.png"))

shrooms = [spritesheet[:,16*i:16*(i+1)] for i in range(spritesheet.shape[1]//16)]

for e, shroom in enumerate(shrooms, start=1):
    Image.fromarray(reorganize_sprites(shroom)).save(f"dumps/mushroom{e}_sprites.png")
