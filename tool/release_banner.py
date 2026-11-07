"""Render a Collectarr release banner: the release dashboard artwork filled with a release's real data."""
import argparse
import datetime
import functools
import io
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'docs' / 'assets' / 'release-banner'
TEMPLATE = ASSETS / 'template.jpg'
# Noto Emoji images (Apache-2.0), pinned so a release renders the same later.
EMOJI_URL = 'https://raw.githubusercontent.com/googlefonts/noto-emoji/99701e07d3d1fe1bdbcdb14964547f0fd592966f/2D/png/128/emoji_u{}.png'
MONO, MONO_BOLD, HAND = 'mono', 'mono-bold', 'hand'
SCREEN_INK = (240, 234, 214)
PAPER_INK = (22, 26, 48)
ITEM_ROWS = (263, 312, 360, 408, 455, 502)
CONTRIBUTOR_ROWS = ((1136, 696), (1132, 735), (1128, 773), (1124, 811))
CONTRIBUTOR_ANGLE = -2.5
# Used when a release has no editorial items; the first matching commit scope wins.
SCOPE_EMOJI = {
    'music': '🎵', 'movies': '🎬', 'games': '🎮', 'comics': '💥', 'books': '📖', 'hardware': '🕹️', 'toys': '🧸',
    'import': '📥', 'export': '📤', 'sync': '🔄', 'scan': '📷', 'library': '🗂️', 'settings': '⚙️', 'updater': '⬆️',
    'edit': '✏️', 'add': '➕', 'search': '🔍', 'covers': '🖼️', 'admin': '🛡️',
}


class Slot:
    """A text area on the artwork: its box, tilt, ink and largest font size."""

    def __init__(self, box, angle, color, size, face=HAND, lines=1, align='center', glow=None, smallest=16):
        self.box, self.angle, self.color, self.size, self.smallest = box, angle, color, size, smallest
        self.face, self.lines, self.align, self.glow = face, lines, align, glow


SLOTS = {
    'version': Slot((600, 138, 1092, 196), 0, (112, 226, 52), 50, MONO_BOLD, glow=(60, 200, 40)),
    'date': Slot((1172, 150, 1292, 190), -5, PAPER_INK, 34),
    'issues': Slot((244, 454, 380, 516), 7, (150, 34, 26), 30, lines=2),
    'stars': Slot((1345, 552, 1505, 604), 2, (246, 200, 82), 38),
    'previous_version': Slot((296, 684, 524, 716), 1, SCREEN_INK, 24, MONO),
    'next_version': Slot((356, 736, 486, 766), 1, SCREEN_INK, 24, MONO),
    'commits': Slot((880, 678, 1042, 708), 0, PAPER_INK, 32, align='right'),
    'prs': Slot((880, 731, 1048, 761), 0, PAPER_INK, 32, align='right'),
    'contributors': Slot((880, 784, 1058, 814), 0, PAPER_INK, 32, align='right'),
    'no_contributors': Slot((1130, 730, 1370, 780), CONTRIBUTOR_ANGLE, PAPER_INK, 30),
    **{f'item_{i + 1}': Slot((605, y - 20, 1190, y + 20), 0, SCREEN_INK, 27, MONO, align='left', smallest=21) for i, y in enumerate(ITEM_ROWS)},
    **{f'contributor_{i + 1}': Slot((x + 44, y - 18, x + 236, y + 18), CONTRIBUTOR_ANGLE, PAPER_INK, 28, align='left', smallest=18) for i, (x, y) in enumerate(CONTRIBUTOR_ROWS)},
}
EMOJI_KEYS = [f'emoji_{i + 1}' for i in range(len(ITEM_ROWS))]


def gh(*args):
    return subprocess.check_output(['gh', *args], text=True, encoding='utf-8')


def font(face, size):
    if face == HAND:
        return ImageFont.truetype(str(ASSETS / 'PatrickHand-Regular.ttf'), size)
    loaded = ImageFont.truetype(str(ASSETS / 'JetBrainsMono.ttf'), size)
    loaded.set_variation_by_axes([700 if face == MONO_BOLD else 500])
    return loaded


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
        face = font(slot.face, size)
        rows = wrap(text, face, width, slot.lines)
        if rows and len(rows) * size * 1.18 <= height + size * 0.2:
            return face, rows
    words = text.split()
    while len(words) > 1:
        words.pop()
        rows = wrap(' '.join(words) + '…', face, width, slot.lines)
        if rows and len(rows) * size * 1.18 <= height + size * 0.2:
            return face, rows
    # One long word, like a login, is cut inside.
    word = words[0]
    while word and face.getlength(word + '…') > width:
        word = word[:-1]
    return face, [word + '…']


def draw(canvas, slot, text):
    face, rows = fit(slot, text)
    x0, y0, x1, y1 = slot.box
    pad = 40
    layer = Image.new('RGBA', (x1 - x0 + pad * 2, y1 - y0 + pad * 2), (0, 0, 0, 0))
    ink = ImageDraw.Draw(layer)
    step = face.size * 1.18
    top = pad + ((y1 - y0) - step * len(rows)) / 2
    for i, row in enumerate(rows):
        spare = (x1 - x0) - face.getlength(row)
        left = pad + {'left': 0, 'center': spare / 2, 'right': spare}[slot.align]
        ink.text((left, top + i * step), row, font=face, fill=slot.color, stroke_width=1 if slot.face == HAND else 0, stroke_fill=slot.color)
    if slot.glow:
        halo = Image.new('RGBA', layer.size, slot.glow + (0,))
        halo.putalpha(layer.getchannel('A').filter(ImageFilter.GaussianBlur(10)))
        layer = Image.alpha_composite(halo, layer)
    layer = layer.rotate(slot.angle, resample=Image.BICUBIC, expand=False)
    canvas.alpha_composite(layer, (x0 - pad, y0 - pad))


@functools.cache
def emoji_image(emoji):
    # Noto names its images after the code points, without the emoji variation selector.
    code = '_'.join(f'{ord(c):x}' for c in emoji if c != '️')
    with urllib.request.urlopen(EMOJI_URL.format(code)) as response:
        return Image.open(io.BytesIO(response.read())).convert('RGBA')


def draw_emoji(canvas, emoji, y):
    size = 36
    image = emoji_image(emoji).resize((size, size), Image.LANCZOS)
    canvas.alpha_composite(image, (558 - size // 2, y - size // 2))


def draw_mark(canvas, row):
    """The GitHub mark in front of a contributor row."""
    x, y = row
    mark = Image.open(ASSETS / 'contributor-mark.png').convert('RGBA').rotate(CONTRIBUTOR_ANGLE, resample=Image.BICUBIC)
    canvas.alpha_composite(mark, (x, y - mark.height // 2))


def plural(count, word):
    return f"{count} {word}{'' if count == 1 else 's'}"


def git(*args):
    result = subprocess.run(['git', *args], check=False, cwd=ROOT, capture_output=True, text=True, encoding='utf-8')
    return result.stdout.strip() if result.returncode == 0 else ''


def previous_tag(tag):
    return git('describe', '--tags', '--abbrev=0', f'{tag}^')


def changes(tag, previous):
    """Conventional commit scopes and descriptions since the previous tag, grouped by type (feat, fix, ...)."""
    groups = {}
    for subject in git('log', '--no-merges', '--format=%s', f'{previous}..{tag}' if previous else tag).splitlines():
        match = re.match(r'(\w+)(?:\(([^)]*)\))?!?: (.+)', subject)
        if match:
            groups.setdefault(match.group(1), []).append((match.group(2) or '', match.group(3)))
    return groups


def short(text):
    """The first clause of a commit description, cut to a few words for a row."""
    words = re.split(r'[:;,(]', text, maxsplit=1)[0].strip().rstrip('.').split()
    card = ' '.join(words[:6]) + ('…' if len(words) > 6 else '')
    return card[:1].upper() + card[1:]


def commit_items(tag, previous):
    """Rows for a release without editorial items: its earliest features, then its earliest fixes."""
    groups = changes(tag, previous)
    # Commits are listed newest first; the earliest features usually carry the release.
    features = [{'emoji': SCOPE_EMOJI.get(scope, '✨'), 'text': short(text)} for scope, text in groups.get('feat', [])[::-1]]
    fixes = [{'emoji': SCOPE_EMOJI.get(scope, '🔧'), 'text': short(text)} for scope, text in groups.get('fix', [])[::-1]]
    rows = len(ITEM_ROWS)
    return (features[:max(rows - len(fixes), 4)] + fixes)[:rows]


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


def release_commits(repo, previous, tag):
    """The non-merge commits a release brought."""
    endpoint = f'repos/{repo}/compare/{previous}...{tag}?per_page=100' if previous else f'repos/{repo}/commits?sha={tag}&per_page=100'
    pages = json.loads(gh('api', '--paginate', '--slurp', endpoint))
    commits = [c for page in pages for c in (page['commits'] if previous else page)]
    return [c for c in commits if len(c['parents']) < 2]


def merged_pull_requests(repo, previous, tag):
    """Pull requests merged into main after the previous tag, up to this tag."""
    until = git('log', '-1', '--format=%cI', tag)
    since = git('log', '-1', '--format=%cI', previous) if previous else '2000-01-01T00:00:00Z'
    query = f'repo:{repo} is:pr is:merged base:main merged:{since}..{until}'
    return json.loads(gh('api', '--method', 'GET', 'search/issues', '-f', f'q={query}', '-F', 'per_page=1'))['total_count']


def contributors(commits):
    """GitHub logins behind the commits, first seen first, without bots."""
    logins = (c['author']['login'] for c in commits if c.get('author'))
    return [login for login in dict.fromkeys(logins) if not login.endswith('[bot]')]


def new_contributors(repo, logins, previous):
    """The logins with no commit in the history of the previous tag."""
    if not previous:
        return logins
    return [login for login in logins if not json.loads(gh('api', f'repos/{repo}/commits?sha={previous}&author={login}&per_page=1'))]


def week_of(moment):
    """The Monday of the week a release was published, like `Oct 26`."""
    day = datetime.datetime.fromisoformat(moment.replace('Z', '+00:00')).date()
    monday = day - datetime.timedelta(days=day.weekday())
    return f'{monday:%b} {monday.day}'


def contributor_rows(logins):
    """One row per new contributor; the last row counts the ones that do not fit."""
    rows = len(CONTRIBUTOR_ROWS)
    if not logins:
        return {'no_contributors': 'None this release'}
    shown = list(logins)
    if len(shown) > rows:
        shown = shown[:rows - 1] + [f'+{len(logins) - rows + 1} more']
    return {f'contributor_{i + 1}': text for i, text in enumerate(shown)}


def release_data(repo, tag, entry):
    """Slot texts: editorial items, with commit and contributor counts and GitHub stats at publication."""
    entry = {'summary': entry} if isinstance(entry, str) else entry
    previous = previous_tag(tag)
    items = entry.get('items') or commit_items(tag, previous)
    moment = json.loads(gh('api', f'repos/{repo}/releases/tags/{tag}'))['published_at']
    issues, stars = stats_at(repo, moment)
    commits = release_commits(repo, previous, tag)
    logins = contributors(commits)
    return {
        'version': tag,
        'date': week_of(moment),
        'issues': plural(issues, 'open issue'),
        'stars': plural(stars, 'star'),
        'previous_version': previous or 'First release',
        'next_version': tag,
        'commits': str(len(commits)),
        'prs': str(merged_pull_requests(repo, previous, tag)),
        'contributors': str(len(logins)),
        **contributor_rows(new_contributors(repo, logins, previous)),
        **{f'item_{i + 1}': item['text'] for i, item in enumerate(items[:len(ITEM_ROWS)])},
        **{f'emoji_{i + 1}': item['emoji'] for i, item in enumerate(items[:len(ITEM_ROWS)])},
    }


def render(data, out):
    canvas = Image.open(TEMPLATE).convert('RGBA')
    for key, slot in SLOTS.items():
        if data.get(key):
            draw(canvas, slot, data[key])
    for key, y in zip(EMOJI_KEYS, ITEM_ROWS):
        if data.get(key):
            draw_emoji(canvas, data[key], y)
    for i, row in enumerate(CONTRIBUTOR_ROWS):
        # The "+N more" row names no one, so it has no mark.
        text = data.get(f'contributor_{i + 1}', '')
        if text and not text.startswith('+'):
            draw_mark(canvas, row)
    canvas.convert('RGB').save(out, quality=90, method=6)


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--set', action='append', default=[], metavar='KEY=TEXT', help=f'Override a slot: {", ".join([*SLOTS, *EMOJI_KEYS])}')
    args = parser.parse_args()
    data = release_data(args.repo, args.tag, editorial(args.tag))
    for override in args.set:
        key, _, text = override.partition('=')
        if key not in SLOTS and key not in EMOJI_KEYS:
            parser.error(f'Unknown slot {key}')
        data[key] = text
    render(data, args.out)
    print(json.dumps(data, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
