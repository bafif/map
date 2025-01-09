import sys
import json

out = []

def rgb2hex(r, g, b):
    return "#{0:02x}{1:02x}{2:02x}".format(r, g, b)

for arg in sys.argv[1:]:
    with open(arg, 'r') as txt:
        for line in txt:
            item = line.split(';')
            color = rgb2hex(int(item[1]), int(item[2]), int(item[3]))
            item = [color, item[4]]
            out.append(item)
    name = arg.split('/')[-1].split('.')
    name = name[-2] + ".json"
    open(name, 'w').write((json.dumps(out, indent=4, sort_keys=False)))