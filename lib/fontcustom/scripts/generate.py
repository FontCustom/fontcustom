import fontforge
import os
import md5
import json
import subprocess

try:
	import argparse
	parser = argparse.ArgumentParser(description='Convert a directory of svg and eps files into a unified font file.')
	parser.add_argument('dir', metavar='directory', type=unicode, nargs=2, help='directory of vector files')
	parser.add_argument('--name', metavar='fontname', type=unicode, nargs='?', default='fontcustom', help='reference name of the font (no spaces)')
	parser.add_argument('--nohash', '-n', action='store_true', help='disable hash fingerprinting of font files')
	parser.add_argument('--debug', '-d', action='store_true', help='display debug messages')
	args = parser.parse_args()
	indir = args.dir[0]
	outdir = args.dir[1]
except ImportError:
	# Older Pythons don't have argparse, so we use optparse instead
	import optparse
	parser = optparse.OptionParser(description='Convert a directory of svg and eps files into a unified font file.')
	parser.add_option('--name', metavar='fontname', type='string', nargs='?', default='fontcustom', help='reference name of the font (no spaces)')
	parser.add_option('--nohash', '-n', action='store_true', help='disable hash fingerprinting of font files')
	parser.add_argument('--debug', '-d', action='store_true', help='display debug messages')
	(args, posargs) = parser.parse_args()
	indir = posargs[0]
	outdir = posargs[1]

f = fontforge.font()
f.encoding = 'UnicodeFull'

m = md5.new()
cp = 0xf100
files = []

KERNING = 15

for dirname, dirnames, filenames in os.walk(indir):
	for filename in filenames:
		name, ext = os.path.splitext(filename)
		filePath = os.path.join(dirname, filename)
		size = os.path.getsize(filePath)

		if ext in ['.svg', '.eps']:
			if ext in ['.svg']:
				# hack removal of <switch> </switch> tags
				svgfile = open(filePath, 'r+')
				svgtext = svgfile.read()
				svgfile.seek(0)

				# replace the <switch> </switch> tags with 'nothing'
				svgtext = svgtext.replace('<switch>', '')
				svgtext = svgtext.replace('</switch>', '')
			
				# remove all contents of file so that we can write out the new contents
				svgfile.truncate()			
				svgfile.write(svgtext)

				svgfile.close()
				# end hack
				
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
	fontfile = outdir + '/' + args.name
else:
	hashStr = m.hexdigest()
	fontfile = outdir + '/' + args.name + '-' + hashStr

f.fontname = args.name
f.familyname = args.name
f.fullname = args.name
f.generate(fontfile + '.ttf')
f.generate(fontfile + '.svg')

# Fix SVG header for webkit
# from: https://github.com/fontello/font-builder/blob/master/bin/fontconvert.py
svgfile = open(fontfile + '.svg', 'r+')
svgtext = svgfile.read()
svgfile.seek(0)
svgfile.write(svgtext.replace('''<svg>''', '''<svg xmlns="http://www.w3.org/2000/svg">'''))
svgfile.close()

scriptPath = os.path.dirname(os.path.realpath(__file__))
try:
	subprocess.Popen([scriptPath + '/sfnt2woff', fontfile + '.ttf'], stdout=subprocess.PIPE)
except OSError:
	# If the local version of sfnt2woff fails (i.e., on Linux), try to use the
	# global version. This allows us to avoid forcing OS X users to compile
	# sfnt2woff from source, simplifying install.
	subprocess.call(['sfnt2woff', fontfile + '.ttf'])

# eotlitetool.py script to generate IE7-compatible .eot fonts
subprocess.call('python ' + scriptPath + '/eotlitetool.py ' + fontfile + '.ttf -o ' + fontfile + '.eot', shell=True)
subprocess.call('mv ' + fontfile + '.eotlite ' + fontfile + '.eot', shell=True)

# Hint the TTF file
subprocess.call('ttfautohint -s -n ' + fontfile + '.ttf ' + fontfile + '-hinted.ttf > /dev/null 2>&1 && mv ' + fontfile + '-hinted.ttf ' + fontfile + '.ttf', shell=True)
