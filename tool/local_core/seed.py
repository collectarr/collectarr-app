"""Complete fictional fixtures, restricted to the isolated Docker UI database."""
import asyncio
from io import BytesIO
from uuid import UUID

from PIL import Image, ImageDraw
from sqlalchemy import select

from app.core.config import get_settings
from app.db.session import AsyncSessionLocal
from app.models.catalog_music_item import MusicItem
from app.schemas.catalog_music_item import CatalogMusicItemResponse
from app.storage.client import ObjectStorage


def barcode(number):
    digits = f"2000000000{number:02d}"
    check = (-sum(int(digit) * (1 if index % 2 == 0 else 3)
                  for index, digit in enumerate(digits))) % 10
    return digits + str(check)


def cover(storage, number, title, back=False, thumbnail=False):
    # Original procedural art, with no external or proprietary image assets.
    size = 240 if thumbnail else 800
    image = Image.new("RGB", (size, size), "#172838" if number == 1 else "#28203b")
    draw = ImageDraw.Draw(image)
    for y in range(size):
        shade = int(35 + 65 * y / size)
        draw.line((0, y, size, y), fill=(20, shade, shade + 35))
    moon = size // 4
    draw.ellipse((moon, moon, size - moon, size - moon), fill="#e6bb7c")
    draw.ellipse((moon + size // 7, moon - size // 10,
                  size - moon + size // 7, size - moon - size // 10), fill="#172838")
    draw.rectangle((0, size * 3 // 4, size, size), fill="#172838")
    draw.text((size // 16, size * 13 // 16), "THE PAPER MOONS", fill="white")
    draw.text((size // 16, size * 14 // 16), title.upper(), fill="#e6bb7c")
    if back:
        draw.text((size // 16, size // 16), "DISC 1: FIRST LIGHT / OPEN SKIES", fill="white")
        draw.text((size // 16, size // 16 + 18), "DISC 2: ENCORE / AFTERGLOW", fill="white")
        draw.text((size // 16, size * 15 // 16), barcode(number), fill="white")
    output = BytesIO()
    image.save(output, format="JPEG", quality=90)
    purpose = "thumbnail" if thumbnail else "back" if back else "front"
    return storage.put_object(f"ui-fixtures/v1/{number}-{purpose}.jpg",
                              output.getvalue(), "image/jpeg")


def credit(identity, name, role, instruments=None):
    return {"id": identity, "name": name, "sort_name": name.split()[-1] + ", " + name.split()[0],
            "role": role, "role_id": role.lower(), "instruments": instruments or [], "sequence": 1}


def disc(number, index):
    vinyl = index == 2
    identity = f"10000000-0000-4000-8000-{number * 10 + index:012d}"
    return {
        "id": identity, "disc_number": index, "title": "Live at Demo Hall" if vinyl else "Studio Sessions",
        "format": '12" Vinyl' if vinyl else "CD", "format_family": "vinyl" if vinyl else "opticalDisc",
        "recording_date": {"year": 2024} if vinyl else {"year": 2025, "month": 6, "day": 12},
        "recording_locations": ["Demo Hall"] if vinyl else ["Demo Studio", "Room Two"],
        "is_live": vinyl, "sound_types": ["Stereo"], "spars_code": "ADD" if vinyl else "DDD",
        "color": "Red" if vinyl else None, "vinyl_weight_grams": 180 if vinyl else None,
        "rpm": "45" if vinyl else None, "matrix_number": None if vinyl else f"DEMO-{number}-CD",
        "matrix_number_side_a": f"DEMO-{number}-A" if vinyl else None,
        "matrix_number_side_b": f"DEMO-{number}-B" if vinyl else None,
        "credits": [credit(f"disc-credit-{number}-{index}", "Jane Harbor" if vinyl else "Robin Vale",
                           "Guitarist" if vinyl else "Engineer", ["Guitar"] if vinyl else [])],
        "tracks": [{
            "id": f"20000000-0000-4000-8000-{(number * 10 + index if track == 1 else number * 100 + index * 10 + track):012d}",
            "position": ("A1" if track == 1 else "B1") if vinyl else str(track),
            "position_order": track - 1,
            "title": (["Encore", "Afterglow"] if vinyl else ["First Light", "Open Skies"])[track - 1],
            "artist": "The Paper Moons", "composition": "Moonlight Suite" if track == 1 else "Skyward",
            "duration_ms": 180000 + track * 15000,
            "is_header": False, "indent_level": 0,
        } for track in [1, 2]],
    }


async def main():
    settings = get_settings()
    if not settings.database_url.endswith("@postgres:5432/collectarr_ui_test"):
        raise RuntimeError("This seed is restricted to the isolated UI test database")
    storage = ObjectStorage()
    async with AsyncSessionLocal() as db:
        for number, title in enumerate(["After the Rain", "Northern Lights"], 1):
            identity = UUID(f"00000000-0000-4000-8000-{number:012d}")
            values = {
                "title": title, "sort_title": title, "subtitle": "Deluxe Edition",
                "artist": "The Paper Moons",
                "artist_credits": [{"id": f"artist-{number}", "name": "The Paper Moons",
                                    "sort_name": "Paper Moons, The", "sequence": 1}],
                "label": "Demo Records", "genres": ["Alternative", "Rock"],
                "catalog_number": f"DEMO-00{number}", "barcode": barcode(number),
                "country": "United Kingdom", "release_date": {"year": 2026, "month": 2, "day": 18},
                "original_release_date": {"year": 2024, "month": 9}, "packaging": "Digipak",
                "extra": ["Bonus tracks", "Limited edition"], "box_set": "Moonlight Collection",
                "credits": [credit(f"album-credit-{number}", "Alex Rivers", "Producer")],
                "external_links": [{"url": "https://example.com/collectarr-demo", "title": "Demo release",
                                    "description": "Fictional UI fixture"}],
                "cover_image_url": cover(storage, number, title),
                "back_cover_image_url": cover(storage, number, title, back=True),
                "thumbnail_image_url": cover(storage, number, title, thumbnail=True),
                "discs": [disc(number, index) for index in [1, 2]],
            }
            item = await db.scalar(select(MusicItem).where(MusicItem.id == identity))
            if item is None:
                item = MusicItem(id=identity, **values)
                db.add(item)
            else:
                changed = any(getattr(item, key) != value for key, value in values.items())
                for key, value in values.items():
                    setattr(item, key, value)
                if changed:
                    item.revision += 1
            await db.flush()
            CatalogMusicItemResponse.model_validate(item)
            print(f"Ready: {title} | The Paper Moons | {barcode(number)} | DEMO-00{number}")
        await db.commit()


asyncio.run(main())
