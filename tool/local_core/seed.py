"""Seed only the isolated Docker UI test database; never a user database."""
import asyncio
from uuid import UUID

from sqlalchemy import select

from app.core.config import get_settings
from app.db.session import AsyncSessionLocal
from app.models.catalog_music_item import MusicItem
from app.schemas.catalog_music_item import CatalogMusicItemResponse


async def main():
    settings = get_settings()
    if not settings.database_url.endswith("@postgres:5432/collectarr_ui_test"):
        raise RuntimeError("This seed is restricted to the isolated UI test database")
    async with AsyncSessionLocal() as db:
        for number, title in enumerate(["After the Rain", "Northern Lights"], 1):
            identity = UUID(f"00000000-0000-4000-8000-{number:012d}")
            item = await db.scalar(select(MusicItem).where(MusicItem.id == identity))
            if item is not None:
                print(f"Already seeded: {title}")
                continue
            item = MusicItem(
                id=identity,
                title=title,
                artist="The Paper Moons",
                label="Demo Records",
                genres=["Alternative", "Rock"],
                catalog_number=f"DEMO-00{number}",
                country="United Kingdom",
                release_date={"year": 2026, "month": 2, "day": 18},
                packaging="Digipak",
                credits=[{
                    "id": f"album-credit-{number}", "name": "Alex Rivers",
                    "role": "Producer", "instruments": [], "sequence": 1,
                }],
                discs=[{
                    "id": f"10000000-0000-4000-8000-{number * 10 + disc:012d}", "disc_number": disc,
                    "format": "CD" if disc == 1 else '12" Vinyl',
                    "format_family": "opticalDisc" if disc == 1 else "vinyl",
                    "recording_date": {"year": 2025 if disc == 1 else 2024},
                    "recording_locations": ["Demo Studio" if disc == 1 else "Demo Hall"],
                    "is_live": disc == 2, "sound_types": ["Stereo"],
                    "credits": [],
                    "tracks": [{
                        "id": f"20000000-0000-4000-8000-{number * 10 + disc:012d}", "position": "1",
                        "position_order": 0, "title": "First Light" if disc == 1 else "Encore",
                        "duration_ms": 180000, "is_header": False, "indent_level": 0,
                    }],
                } for disc in [1, 2]],
            )
            db.add(item)
            await db.flush()
            CatalogMusicItemResponse.model_validate(item)
            print(f"Seeded: {title} ({identity})")
        await db.commit()


asyncio.run(main())
