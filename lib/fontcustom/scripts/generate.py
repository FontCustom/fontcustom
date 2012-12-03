import fontforge
import os
import argparse
import md5
import json
from subprocess import call

parser = argparse.ArgumentParser(description='Convert a directory of svg and eps files into a unified font file.')
parser.add_argument('dir', metavar='directory', type=unicode, nargs=2, help='directory of vector files')
parser.add_argument('--name', metavar='fontname', type=unicode, nargs='?', default='fontcustom', help='reference name of the font (no spaces)')
parser.add_argument('--nohash', '-n', action='store_true', help='disable hash fingerprinting of font files')
args = parser.parse_args()

f = fontforge.font()
f.encoding = 'UnicodeFull'

m = md5.new()
cp = 0xf100
files = []

KERNING = 15

for dirname, dirnames, filenames in os.walk(args.dir[0]):
	for filename in filenames:
		name, ext = os.path.splitext(filename)
		filePath = os.path.join(dirname, filename)
		size = os.path.getsize(filePath)

		if ext in ['.svg', '.eps']:
			m.update(filename + str(size) + ';')
			glyph = f.createChar(cp)
			glyph.importOutlines(filePath)

			glyph.left_side_bearing = KERNING
			glyph.right_side_bearing = KERNING

			# possible optimization?
			# glyph.simplify()
			# glyph.round()

			files.append(name)
			cp += 1

if args.nohash:
	fontfile = args.dir[1] + '/' + args.name
else:
	hashStr = m.hexdigest()
	fontfile = args.dir[1] + '/' + args.name + '-' + hashStr

f.fontname = args.name
f.familyname = args.name
f.fullname = args.name
f.generate(fontfile + '.ttf')
f.generate(fontfile + '.svg')

# Fix SVG header for webkit (from: https://github.com/fontello/font-builder/blob/master/bin/fontconvert.py)
svgfile = open(fontfile + '.svg', 'r+')
svgtext = svgfile.read()
svgfile.seek(0)
svgfile.write(svgtext.replace('''<svg>''', '''<svg xmlns="http://www.w3.org/2000/svg">'''))
svgfile.close()

scriptPath = os.path.dirname(os.path.realpath(__file__))
call([scriptPath + '/sfnt2woff', fontfile + '.ttf'])
call(scriptPath + '/ttf2eot ' + fontfile + '.ttf > ' + fontfile + '.eot', shell=True)

# Hint the TTF file
call(scriptPath + '/ttfautohint -s -n ' + fontfile + '.ttf ' + fontfile + '-hinted.ttf && mv ' + fontfile + '-hinted.ttf ' + fontfile + '.ttf', shell=True)
