import fontforge
import os
import argparse
import md5
import json
from subprocess import call

parser = argparse.ArgumentParser(description='Convert a directory of svg and eps files into a unified font file.')
parser.add_argument('dir', metavar='directory', type=unicode, nargs='+', help='directory of vector files')
args = parser.parse_args()

f = fontforge.font()
m = md5.new()
cp = 0xf000
files = []

for dirname, dirnames, filenames in os.walk(args.dir[0]):
	for filename in filenames:
		name, ext = os.path.splitext(filename)
		filePath = os.path.join(dirname, filename)
		size = os.path.getsize(filePath)

		if ext in ['.svg', '.eps']:
			m.update(filename + str(size) + ';')
			glyph = f.createChar(cp)
			glyph.importOutlines(filePath)

			files.append(name)
			cp += 1

hashStr = m.hexdigest()
fontfile = args.dir[1] + '/fontcustom-' + hashStr

f.fontname = 'fontcustom'
f.generate(fontfile + '.otf',flags=('opentype',))
f.generate(fontfile + '.ttf')

scriptPath = os.path.dirname(os.path.realpath(__file__))
call([scriptPath + '/sfnt2woff', fontfile + '.ttf'])
call(scriptPath + '/ttf2eot ' + fontfile + '.ttf > ' + fontfile + '.eot', shell=True)

print json.dumps({'file': fontfile, 'names': files})
