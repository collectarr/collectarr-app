"""Insert the comparison fixture into Core using its strict canonical schema.

Run with Core's Python environment and its repository root on PYTHONPATH.
Existing schemas are never altered. --initialize-empty creates the current
Core schema only when the explicitly selected database has no tables.
"""

import argparse
import asyncio
import json
import os
from pathlib import Path
from uuid import UUID

from app.schemas.catalog_music_item import CatalogMusicItemResponse


async def seed(payload: dict, initialize_empty: bool) -> None:
    from app.db.session import AsyncSessionLocal, engine
    from app.models.catalog_music_item import MusicItem

    if initialize_empty:
        from app.models import Base
        from sqlalchemy import inspect, text

        async with engine.begin() as connection:
            tables = await connection.run_sync(lambda conn: inspect(conn).get_table_names(schema="public"))
            if tables:
                raise ValueError("Initialization requires an empty database; existing schemas are never reshaped")
            await connection.execute(text("CREATE EXTENSION IF NOT EXISTS pg_trgm"))
            await connection.run_sync(Base.metadata.create_all)

    values = CatalogMusicItemResponse.model_validate(payload).model_dump(mode="json")
    item_id = UUID(values.pop("id"))
    values.pop("kind")
    values.pop("revision")
    async with AsyncSessionLocal() as session:
        item = await session.get(MusicItem, item_id)
        if item is not None and item.title != payload["title"]:
            raise ValueError("Fixture ID belongs to an unrelated catalog item")
        if item is None:
            session.add(MusicItem(id=item_id, **values))
        else:
            for field, value in values.items():
                setattr(item, field, value)
        await session.commit()
        stored = await session.get(MusicItem, item_id)
        if stored is None:
            raise RuntimeError("Seeded catalog item was not persisted")
        actual = CatalogMusicItemResponse.model_validate(stored, from_attributes=True).model_dump(mode="json")
        expected = CatalogMusicItemResponse.model_validate(payload).model_dump(mode="json")
        for field in expected:
            if field != "revision" and actual[field] != expected[field]:
                raise RuntimeError(f"Persisted field differs from fixture: {field}")
    print(f"Seeded Core Music item {item_id}: {payload['title']}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fixture", type=Path, default=Path(__file__).resolve().parents[1] / "tool/fixtures/music_inspector_reference.json")
    parser.add_argument("--validate-only", action="store_true")
    parser.add_argument("--database-host", help="Override the configured host for a locally published PostgreSQL port")
    parser.add_argument("--database-name", help="Use a separately created comparison database")
    parser.add_argument("--initialize-empty", action="store_true", help="Create current typed tables only if the database has no public tables")
    args = parser.parse_args()
    payload = json.loads(args.fixture.read_text(encoding="utf-8"))["catalog"]
    CatalogMusicItemResponse.model_validate(payload)
    if args.validate_only:
        print("Core canonical Music fixture is valid")
    else:
        if args.database_host or args.database_name:
            from app.core.config import get_settings
            from sqlalchemy.engine import make_url

            url = make_url(get_settings().database_url)
            if args.database_host:
                url = url.set(host=args.database_host)
            if args.database_name:
                url = url.set(database=args.database_name)
            os.environ["DATABASE_URL"] = url.render_as_string(hide_password=False)
            get_settings.cache_clear()
        asyncio.run(seed(payload, args.initialize_empty))


if __name__ == "__main__":
    main()
