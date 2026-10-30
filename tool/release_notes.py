"""Format Collectarr GitHub releases; preserve editorial summaries across regeneration."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

BANNER = 'docs/assets/release-banner.png'
# GitHub rejects release descriptions over 125,000 characters.
BODY_LIMIT = 120_000
CLOSING = re.compile(r'\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s+#(\d+)', re.IGNORECASE)


def gh(*args):
    return subprocess.check_output(['gh', *args], text=True, encoding='utf-8')


def git(*args):
    result = subprocess.run(['git', *args], text=True, encoding='utf-8', capture_output=True)
    return result.stdout.strip() if result.returncode == 0 else ''


def banner_commit(tag):
    """Pin the banner to the commit a release shipped with, so later artwork changes keep old releases intact."""
    shipped = git('log', '-1', '--format=%H', f'{tag}^{{commit}}', '--', BANNER)
    if shipped:
        return shipped
    # Releases tagged before the banner existed use its first version.
    added = git('log', '--diff-filter=A', '--format=%H', 'origin/main', '--', BANNER).splitlines()
    if not added:
        sys.exit(f'{BANNER} has no history; fetch the full repository with tags.')
    return added[-1]


def range_commits(repo, previous, tag):
    endpoint = f'repos/{repo}/compare/{previous}...{tag}?per_page=100' if previous else f'repos/{repo}/commits?sha={tag}&per_page=100'
    pages = json.loads(gh('api', '--paginate', '--slurp', endpoint))
    commits = [c for page in pages for c in (page['commits'] if previous else page)]
    # The commits endpoint lists newest first; compare lists oldest first.
    return commits if previous else commits[::-1]


def pull_requests(repo, shas):
    """Map each commit to the merged pull request that brought it to main, with the issues that pull request closes."""
    owner, name = repo.split('/')
    found = {}
    for start in range(0, len(shas), 50):
        chunk = shas[start:start + 50]
        fields = ' '.join(
            f'c{i}: object(oid: "{sha}") {{ ... on Commit {{ associatedPullRequests(first: 5) {{ nodes {{ '
            'number title url merged baseRefName author { login } closingIssuesReferences(first: 20) { nodes { number } } '
            '} } } }'
            for i, sha in enumerate(chunk)
        )
        query = f'query {{ repository(owner: "{owner}", name: "{name}") {{ {fields} }} }}'
        data = json.loads(gh('api', 'graphql', '-f', f'query={query}'))['data']['repository']
        for i, sha in enumerate(chunk):
            nodes = [n for n in ((data.get(f'c{i}') or {}).get('associatedPullRequests') or {}).get('nodes', []) if n['merged']]
            nodes.sort(key=lambda n: n['baseRefName'] != 'main')
            if nodes:
                found[sha] = nodes[0]
    return found


def change_lines(repo, previous, tag):
    """List every change once: each merged pull request, each commit pushed directly, and the issues they close."""
    commits = [c for c in range_commits(repo, previous, tag) if len(c['parents']) < 2]
    pulls = pull_requests(repo, [c['sha'] for c in commits])
    url = f'https://github.com/{repo}'
    lines, listed, closed = [], set(), {}
    for commit in commits:
        message = commit['commit']['message']
        pull = pulls.get(commit['sha'])
        key = pull['number'] if pull else commit['sha']
        issues = closed.setdefault(key, [])
        issues += [int(n) for n in CLOSING.findall(message) if int(n) not in issues]
        if pull:
            issues += [n['number'] for n in pull['closingIssuesReferences']['nodes'] if n['number'] not in issues]
        if key in listed:
            continue
        listed.add(key)
        if pull:
            author = (pull.get('author') or {}).get('login')
            lines.append((key, f"* {pull['title'][:500]}{f' by @{author}' if author else ''} in {pull['url']}"))
        else:
            author = (commit.get('author') or {}).get('login')
            lines.append((key, f"* {message.splitlines()[0][:500]}{f' by @{author}' if author else ''} in [{commit['sha'][:7]}]({commit['html_url']})"))
    for key, line in lines:
        if closed[key]:
            yield line + ' (closes ' + ', '.join(f'{url}/issues/{n}' for n in sorted(closed[key])) + ')'
        else:
            yield line


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument('--tag', help='Format this release; the newest published release by default')
    selection.add_argument('--all', action='store_true', help='Backfill every published release')
    parser.add_argument('--write', action='store_true', help='Update published release descriptions')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    summaries_path = root / 'docs' / 'release-summaries.json'
    summaries = json.loads(summaries_path.read_text(encoding='utf-8')) if summaries_path.exists() else {}
    releases = json.loads(gh('api', '--paginate', f'repos/{args.repo}/releases'))
    releases = sorted((r for r in releases if not r['draft']), key=lambda r: r['published_at'])
    if not releases:
        sys.exit('No published releases.')
    target = None if args.all else args.tag or releases[-1]['tag_name']
    if target and target not in (r['tag_name'] for r in releases):
        sys.exit(f'{target} is not a published release.')
    previous = None
    for release in releases:
        tag = release['tag_name']
        if target and tag != target:
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
        # GitHub's own notes supply New Contributors and Full Changelog; the change list is built from the full history.
        generated = json.loads(gh(*request))['body']
        credits = re.sub(r"## What's Changed\n.*?(?=\n## |\n\*\*Full Changelog|\Z)", '', generated, flags=re.DOTALL)
        credits = re.sub(r'\n{3,}', '\n\n', credits).strip()
        url = f'https://github.com/{args.repo}'
        banner = f'https://raw.githubusercontent.com/{args.repo}/{banner_commit(tag)}/{BANNER}'
        component = args.repo.removeprefix('collectarr/collectarr-').title()
        header = f'''![Collectarr — Your collections. Connected.]({banner})

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

## What's Changed

'''
        history_url = f'{url}/compare/{previous}...{tag}' if previous else f'{url}/commits/{tag}'
        lines = list(change_lines(args.repo, previous, tag))
        budget = BODY_LIMIT - len(header) - len(credits) - 200
        shown = []
        for line in lines:
            budget -= len(line) + 1
            if budget < 0:
                break
            shown.append(line)
        if len(shown) < len(lines):
            shown.append(f'\nShowing {len(shown)} of {len(lines)} changes. [Read the complete history]({history_url}).')
        body = header + '\n'.join(shown) + '\n\n' + credits + '\n'
        if not args.write:
            print(body)
        elif body.strip() != old.replace('\r\n', '\n').strip():
            subprocess.run(['gh', 'api', '--method', 'PATCH', f"repos/{args.repo}/releases/{release['id']}", '--input', '-'], input=json.dumps({'body': body}), text=True, encoding='utf-8', stdout=subprocess.DEVNULL, check=True)
            print(f'Updated {tag}')
        previous = tag
    summaries_path.parent.mkdir(parents=True, exist_ok=True)
    summaries_path.write_text(json.dumps(summaries, indent=2, ensure_ascii=False) + '\n', encoding='utf-8', newline='\n')


if __name__ == '__main__':
    main()
