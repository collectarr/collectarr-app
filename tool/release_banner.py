"""Render a Collectarr release banner: the release desk artwork filled with a release's real data."""
import argparse
import functools
import json
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'docs' / 'assets' / 'release-banner'
TEMPLATE = ASSETS / 'template.jpg'


class Slot:
    """A text area on the artwork: its box, tilt, ink and largest font size."""

    def __init__(self, box, angle, color, size, weight='ExtraBold', lines=1, align='center', glow=None, smallest=20):
        self.box, self.angle, self.color, self.size, self.smallest = box, angle, color, size, smallest
        self.weight, self.lines, self.align, self.glow = weight, lines, align, glow


SLOTS = {
    'version': Slot((1140, 182, 1325, 242), -3, (58, 38, 18), 36),
    'headline': Slot((525, 286, 1220, 390), 0, (255, 226, 160), 78, lines=2, glow=(255, 150, 40)),
    'summary': Slot((622, 470, 1200, 546), 0, (120, 186, 250), 26, weight='SemiBold', lines=2, align='left', smallest=21),
    'issues': Slot((210, 448, 372, 512), 7, (150, 34, 26), 26, lines=2),
    'stars': Slot((1335, 542, 1490, 602), -2, (246, 196, 82), 30),
    'highlight_1': Slot((350, 724, 572, 790), 4, (66, 42, 16), 24, lines=2),
    'features': Slot((645, 724, 842, 790), 0, (24, 46, 98), 26, lines=2),
    'fixes': Slot((920, 726, 1128, 790), -1, (28, 112, 52), 26, lines=2),
    'highlight_2': Slot((1190, 730, 1400, 798), -5, (24, 46, 98), 24, lines=2),
}


def gh(*args):
    return subprocess.check_output(['gh', *args], text=True, encoding='utf-8')


def font(weight, size):
    return ImageFont.truetype(str(ASSETS / f'PlusJakartaSans-{weight}.ttf'), size)


def wrap(text, face, width, lines):
    """Break text into at most `lines` lines that fit `width`, or None when it does not fit."""
    words, rows = text.split(), ['']
    for word in words:
        candidate = f'{rows[-1]} {word}'.strip()
        if face.getlength(candidate) <= width:
            rows[-1] = candidate
        elif len(rows) < lines and face.getlength(word) <= width:
            rows.append(word)
        else:
            return None
    return rows


def fit(slot, text):
    """Pick the largest font that fits; at the smallest size, shorten with an ellipsis."""
    width, height = slot.box[2] - slot.box[0], slot.box[3] - slot.box[1]
    for size in range(slot.size, slot.smallest - 1, -1):
        face = font(slot.weight, size)
        rows = wrap(text, face, width, slot.lines)
        if rows and len(rows) * size * 1.18 <= height:
            return face, rows
    words = text.split()
    while words:
        words.pop()
        rows = wrap(' '.join(words) + '…', face, width, slot.lines)
        if rows and len(rows) * size * 1.18 <= height:
            return face, rows
    return face, ['…']


def draw(canvas, slot, text):
    face, rows = fit(slot, text)
    x0, y0, x1, y1 = slot.box
    pad = 40
    layer = Image.new('RGBA', (x1 - x0 + pad * 2, y1 - y0 + pad * 2), (0, 0, 0, 0))
    ink = ImageDraw.Draw(layer)
    step = face.size * 1.18
    top = pad + ((y1 - y0) - step * len(rows)) / 2
    for i, row in enumerate(rows):
        left = pad if slot.align == 'left' else pad + ((x1 - x0) - face.getlength(row)) / 2
        ink.text((left, top + i * step), row, font=face, fill=slot.color)
    if slot.glow:
        halo = Image.new('RGBA', layer.size, slot.glow + (0,))
        halo.putalpha(layer.getchannel('A').filter(ImageFilter.GaussianBlur(14)))
        layer = Image.alpha_composite(halo, layer)
    layer = layer.rotate(slot.angle, resample=Image.BICUBIC, expand=False)
    canvas.alpha_composite(layer, (x0 - pad, y0 - pad))


def plural(count, word):
    return f"{count} {word}{'' if count == 1 else 's'}"


def git(*args):
    result = subprocess.run(['git', *args], check=False, cwd=ROOT, capture_output=True, text=True, encoding='utf-8')
    return result.stdout.strip() if result.returncode == 0 else ''


def changes(tag):
    """Conventional commit descriptions since the previous tag, grouped by type (feat, fix, ...)."""
    previous = git('describe', '--tags', '--abbrev=0', f'{tag}^')
    groups = {}
    for subject in git('log', '--no-merges', '--format=%s', f'{previous}..{tag}' if previous else tag).splitlines():
        match = re.match(r'(\w+)(?:\([^)]*\))?!?: (.+)', subject)
        if match:
            groups.setdefault(match.group(1), []).append(match.group(2))
    return groups


def short(text):
    """The first clause of a commit description, cut to a few words for a card."""
    words = re.split(r'[:;,(]', text, maxsplit=1)[0].strip().rstrip('.').split()
    card = ' '.join(words[:6]) + ('…' if len(words) > 6 else '')
    return card[:1].upper() + card[1:]


def editorial(tag):
    """The release's entry in docs/release-summaries.json, empty when it has none."""
    path = ROOT / 'docs' / 'release-summaries.json'
    return json.loads(path.read_text(encoding='utf-8')).get(tag, {}) if path.exists() else {}


@functools.cache
def history(repo):
    """When each issue opened and closed, and when each current star was given."""
    pages = json.loads(gh('api', '--paginate', '--slurp', f'repos/{repo}/issues?state=all&per_page=100'))
    issues = [(i['created_at'], i['closed_at']) for page in pages for i in page if 'pull_request' not in i]
    pages = json.loads(gh('api', '--paginate', '--slurp', '-H', 'Accept: application/vnd.github.star+json', f'repos/{repo}/stargazers?per_page=100'))
    return issues, [star['starred_at'] for page in pages for star in page]


def stats_at(repo, moment):
    """Open issues and stars as they were at `moment`, so any release can be rendered again later."""
    issues, stars = history(repo)
    open_issues = sum(1 for opened, closed in issues if opened <= moment and not (closed and closed <= moment))
    # Stars withdrawn since cannot be recovered.
    return open_issues, sum(1 for starred in stars if starred <= moment)


def release_data(repo, tag, entry):
    """Slot texts: editorial headline, summary and highlights, with commit counts and GitHub stats at publication."""
    entry = {'summary': entry} if isinstance(entry, str) else entry
    groups = changes(tag)
    features, fixes = groups.get('feat', []), groups.get('fix', [])
    component = repo.removeprefix('collectarr/collectarr-').title()
    # Commits are listed newest first; the earliest features usually carry the release.
    highlights = entry.get('highlights') or [short(line) for line in features[::-1][:2]]
    issues, stars = stats_at(repo, json.loads(gh('api', f'repos/{repo}/releases/tags/{tag}'))['published_at'])
    return {
        'version': tag,
        'headline': entry.get('headline') or f'Collectarr {component} {tag}',
        'summary': entry.get('summary', ''),
        'issues': plural(issues, 'open issue'),
        'stars': plural(stars, 'star'),
        'features': plural(len(features), 'new feature'),
        'fixes': plural(len(fixes), 'fix').replace('fixs', 'fixes'),
        'highlight_1': highlights[0] if highlights else 'Free and open source',
        'highlight_2': highlights[1] if len(highlights) > 1 else 'Your collections. Connected.',
    }


def render(data, out):
    canvas = Image.open(TEMPLATE).convert('RGBA')
    for key, slot in SLOTS.items():
        if data.get(key):
            draw(canvas, slot, data[key])
    canvas.convert('RGB').save(out, optimize=True)


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--set', action='append', default=[], metavar='KEY=TEXT', help=f'Override a slot: {", ".join(SLOTS)}')
    args = parser.parse_args()
    data = release_data(args.repo, args.tag, editorial(args.tag))
    for override in args.set:
        key, _, text = override.partition('=')
        if key not in SLOTS:
            parser.error(f'Unknown slot {key}')
        data[key] = text
    render(data, args.out)
    print(json.dumps(data, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
