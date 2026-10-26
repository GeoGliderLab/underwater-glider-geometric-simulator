"""Build a compact animated README preview from MATLAB-exported MP4 frames."""
from pathlib import Path
from PIL import Image, ImageOps

ROOT=Path(__file__).resolve().parents[1]
paths=sorted((ROOT/'tmp/preview_frames').glob('frame_*.png'))
if not paths:
    raise SystemExit('First run tools/export_preview_frames.m in MATLAB.')
frames=[]
for path in paths:
    with Image.open(path) as image:
        rgb=ImageOps.contain(image.convert('RGB'),(960,540))
        frames.append(rgb.quantize(colors=96))
target=ROOT/'results/glider_preview.gif'
frames[0].save(target,save_all=True,append_images=frames[1:],duration=200,loop=0,optimize=True,disposal=2)
print('Saved',len(frames),'preview frames;',target.stat().st_size,'bytes.')
