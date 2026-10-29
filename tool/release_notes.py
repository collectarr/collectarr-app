"""Format Collectarr GitHub releases; preserve editorial summaries across regeneration."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


def gh(*args):
    return subprocess.check_output(['gh', *args], text=True, encoding='utf-8')


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--tag')
    parser.add_argument('--all', action='store_true')
    parser.add_argument('--write', action='store_true', help='Update published release descriptions')
    args = parser.parse_args()
    if not args.all and not args.tag:
        parser.error('Provide --tag or --all')
    root = Path(__file__).resolve().parents[1]
    summaries_path = root / 'docs' / 'release-summaries.json'
    summaries = json.loads(summaries_path.read_text(encoding='utf-8')) if summaries_path.exists() else {}
    releases = json.loads(gh('api', '--paginate', f'repos/{args.repo}/releases'))
    releases = sorted((r for r in releases if not r['draft']), key=lambda r: r['published_at'])
    previous = None
    for release in releases:
        tag = release['tag_name']
        if not args.all and tag != args.tag:
            previous = tag
            continue
        old = release.get('body') or ''
        if tag not in summaries:
            # Preserve existing release-specific notes on the first migration.
            summary = old.strip()
            if '## Changes since last release:' in summary:
                summary = summary.split('## Changes since last release:', 1)[1].split('## Known Issues', 1)[0].strip()
            summary = re.sub(r'^#+ .*\n', '', summary, count=1).strip()
            paragraphs = [p.strip() for p in summary.split('\n\n') if p.strip() and not p.startswith(('#', '<!--', '**Full Changelog'))]
            summaries[tag] = paragraphs[0] if paragraphs else 'This release updates Collectarr. The complete change list below records the included work.'
        request = ['api', '--method', 'POST', f'repos/{args.repo}/releases/generate-notes', '-f', f'tag_name={tag}']
        if previous:
            request += ['-f', f'previous_tag_name={previous}']
        generated = json.loads(gh(*request))['body']
        if "## What's Changed" not in generated:
            endpoint = f'repos/{args.repo}/compare/{previous}...{tag}?per_page=100' if previous else f'repos/{args.repo}/commits?sha={tag}&per_page=100'
            pages = json.loads(gh('api', '--paginate', '--slurp', endpoint))
            commits = [c for page in pages for c in (page['commits'] if previous else page)]
            lines = []
            for commit in commits:
                title = commit['commit']['message'].splitlines()[0]
                author = commit.get('author')
                credit = f" by @{author['login']}" if author else ''
                lines.append(f"* {title}{credit} in [{commit['sha'][:7]}]({commit['html_url']})")
            generated = "## What's Changed\n\n" + '\n'.join(lines) + '\n\n' + generated
        url = f'https://github.com/{args.repo}'
        banner = f'https://raw.githubusercontent.com/{args.repo}/main/docs/assets/release-banner.png'
        component = args.repo.removeprefix('collectarr/collectarr-').title()
        body = f'''![Collectarr — Your collections. Connected.]({banner})

## Changes since last release:

{summaries[tag]}

## Known Issues

See [open issues]({url}/issues) for reported problems and current progress.

## Installing & Updating

Use the downloads attached to this release where available. Follow the [README]({url}/blob/{tag}/README.md) for component-specific setup and update instructions.

## About Collectarr

Collectarr is a free, open-source collection catalog. App, Core and Sync work together to help you organize your collections and keep them connected. This repository contains Collectarr {component}.

## Community & Contributors

Thank you to everyone contributing code, testing, documentation and ideas. Report problems and suggest improvements through [GitHub Issues]({url}/issues). Release contributors are credited in the change list below.

## Support Collectarr

Help by testing releases, reporting bugs, improving documentation or contributing code. See the [contribution guide]({url}/blob/main/CONTRIBUTING.md).

---

{generated.strip()}
'''
        if args.write:
            subprocess.run(['gh', 'api', '--method', 'PATCH', f"repos/{args.repo}/releases/{release['id']}", '--input', '-'], input=json.dumps({'body': body}), text=True, encoding='utf-8', stdout=subprocess.DEVNULL, check=True)
        else:
            print(body)
        previous = tag
    summaries_path.parent.mkdir(parents=True, exist_ok=True)
    summaries_path.write_text(json.dumps(summaries, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
