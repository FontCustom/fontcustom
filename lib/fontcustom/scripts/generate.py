import fontforge
import os
import md5
import subprocess
import tempfile
import json

#
# Parse Arguments
#

try:
    import argparse
    parser = argparse.ArgumentParser(description='Convert a directory of svg and eps files into a unified font file.')
    parser.add_argument('dir', metavar='directory', type=unicode, nargs=2, help='directory of vector files')
    parser.add_argument('--name', metavar='fontname', type=unicode, nargs='?', help='reference name of the font (no spaces)')
    parser.add_argument('--autowidth', '-a', action='store_true', help='automatically size generated glyphs to their vector width')
    parser.add_argument('--nohash', '-n', action='store_true', help='disable hash fingerprinting of font files')
    parser.add_argument('--debug', '-d', action='store_true', help='display debug messages')
    args = parser.parse_args()
    indir = args.dir[0]
    outdir = args.dir[1]
except ImportError:
    # Older Pythons don't have argparse, so we use optparse instead
    import optparse
    parser = optparse.OptionParser(description='Convert a directory of svg and eps files into a unified font file.')
    parser.add_option('--name', metavar='fontname', type='string', nargs='?', help='reference name of the font (no spaces)')
    parser.add_option('--autowidth', '-a', action='store_true', help='automatically size generated glyphs to their vector width')
    parser.add_option('--nohash', '-n', action='store_true', help='disable hash fingerprinting of font files')
    parser.add_argument('--debug', '-d', action='store_true', help='display debug messages')
    (args, posargs) = parser.parse_args()
    indir = posargs[0]
    outdir = posargs[1]

#
# Generator Functions
#

def removeSwitchFromSvg( file ):
    svgfile = open(file, 'r+')
    tmpsvgfile = tempfile.NamedTemporaryFile(suffix=".svg", delete=False)
    svgtext = svgfile.read()
    svgfile.seek(0)
    svgtext = svgtext.replace('<switch>', '')
    svgtext = svgtext.replace('</switch>', '')
    tmpsvgfile.file.write(svgtext)
    svgfile.close()
    tmpsvgfile.file.close()

    return tmpsvgfile.name

def createGlyph( font, dirname, filename, code, m ):
    name, ext = os.path.splitext(filename)
    filePath = os.path.join(dirname, filename)
    size = os.path.getsize(filePath)

    if ext == '.svg':
        filePath = removeSwitchFromSvg(filePath)
        m.update(filename + str(size) + ';')
        glyph = font.createChar(code)
        glyph.importOutlines(filePath)
        os.unlink(filePath)

        if args.autowidth:
            glyph.left_side_bearing = glyph.right_side_bearing = 0
            glyph.round()
        else:
            glyph.width = 512

        return name

    return None

#
# Import Glyphs
#

glyphs = None
glyphsPath = indir + "/glyphs.json"
if os.path.exists(glyphsPath):
    glyphsData = open(glyphsPath)
    glyphs = json.load(glyphsData)
    glyphsData.close()

#
# Assign Font Info

f = fontforge.font()
f.encoding = 'UnicodeFull'
f.design_size = 16
f.em = 512
f.ascent = 448
f.descent = 64
f.fontname = args.name
f.familyname = args.name
f.fullname = args.name

m = md5.new()
cp = 0xf100
files = []
glyphcodes = []

KERNING = 15

if glyphs:
    for g in glyphs:
        code = int(g["code"], 16)
        name = createGlyph(f, indir, g["file"], code, m)
        files.append(name)
        glyphcodes.append(code)
else:
    for dirname, dirnames, filenames in os.walk(indir):
        for filename in filenames:
            name = createGlyph(f, dirname, filename, cp, m)
            if name:
                files.append(name)
                glyphcodes.append(cp)
                cp += 1

#
# Generate TTF and SVG
#

if args.autowidth:
    f.autoWidth(0, 0, 512)

if args.nohash:
    fontfile = outdir + '/' + args.name
else:
    hashStr = m.hexdigest()
    fontfile = outdir + '/' + args.name + '_' + hashStr

f.generate(fontfile + '.ttf')
f.generate(fontfile + '.svg')

# Hint the TTF file
subprocess.call('ttfautohint -s -f -n ' + fontfile + '.ttf ' + fontfile + '-hinted.ttf > /dev/null 2>&1 && mv ' + fontfile + '-hinted.ttf ' + fontfile + '.ttf', shell=True)

# Fix SVG header for webkit
# from: https://github.com/fontello/font-builder/blob/master/bin/fontconvert.py
svgfile = open(fontfile + '.svg', 'r+')
svgtext = svgfile.read()
svgfile.seek(0)
svgfile.write(svgtext.replace('''<svg>''', '''<svg xmlns="http://www.w3.org/2000/svg">'''))
svgfile.close()

#
# Convert WOFF
#

scriptPath = os.path.dirname(os.path.realpath(__file__))
try:
    subprocess.Popen([scriptPath + '/sfnt2woff', fontfile + '.ttf'], stdout=subprocess.PIPE)
except OSError:
    # If the local version of sfnt2woff fails (i.e., on Linux), try to use the
    # global version. This allows us to avoid forcing OS X users to compile
    # sfnt2woff from source, simplifying install.
    subprocess.call(['sfnt2woff', fontfile + '.ttf'])

#
# Convert EOT for IE7
#

subprocess.call('python ' + scriptPath + '/eotlitetool.py ' + fontfile + '.ttf -o ' + fontfile + '.eot', shell=True)
subprocess.call('mv ' + fontfile + '.eotlite ' + fontfile + '.eot', shell=True)

#
# Describe output in JSON
#

outname = os.path.basename(fontfile)
print json.dumps({'fonts': [outname + '.ttf', outname + '.woff', outname + '.eot', outname + '.svg'], 'glyphs': files, 'glyphcodes': glyphcodes})
