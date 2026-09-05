# `kinds/_shared` audit

Audit date: 2026-09-05. The shared tree is an inventory for PR78; it is not
permission to keep domain behavior shared. `VISUAL STRUCTURAL` and
`TECHNICAL PRIMITIVE` are the only categories that can survive PR79, and only
when their inputs are genuinely owner-neutral.

| File | Classification | PR79 disposition |
| --- | --- | --- |
| `add/add_bottom_bar.dart` | EDIT | Move to the owning add flow |
| `add/grading_draft.dart` | DOMAIN MODEL | Move to comic/manga/book owners |
| `add/signature_draft.dart` | DOMAIN MODEL | Move to the owning kind |
| `add/video_physical_release_draft.dart` | EDIT | Move/duplicate into movie/TV/anime |
| `ownership/grading_details.dart` | DOMAIN MODEL | Move to comic/manga/book owners |
| `ownership/signature_details.dart` | DOMAIN MODEL | Move to the owning kind |
| `ownership/video_like_owned_details.dart` | DOMAIN MODEL | Replace with kind-owned details |
| `ownership/video_physical_copy_details.dart` | DOMAIN MODEL | Move/duplicate into video owners |
| `serial/authority/serial_authority_dialog.dart` | EDIT | Move to serial-capable owners |
| `serial/authority/serial_authority_repository.dart` | PERSISTENCE | Move behind typed serial owners |
| `serial/serial_library_media_presentation_builder.dart` | DOMAIN BEHAVIOR | Move to kind presentation |
| `video/catalog/video_catalog_item.dart` | DOMAIN MODEL | Move/duplicate into movie/TV/anime |
| `video/catalog/video_catalog_mapper.dart` | DOMAIN BEHAVIOR | Move provider mapping into owners |
| `video/catalog/video_catalog_release.dart` | DOMAIN MODEL | Move to video kind owners |
| `video/detail/video_detail_page.dart` | DOMAIN BEHAVIOR | Split into movie/TV/anime detail |
| `video/detail/video_external_links_section.dart` | EDIT | Split into kind detail flows |
| `video/detail/video_inspector_panel.dart` | EDIT | Split into kind inspector flows |
| `video/detail/video_inspector_sections.dart` | FIELDS | Split into kind-owned fields |
| `video/detail/video_metadata_corrections_section.dart` | DOMAIN BEHAVIOR | Move to kind metadata flows |
| `video/edit/dialogs/tv_custom_episode_dialog.dart` | EDIT | Move to TV/Anime owner |
| `video/edit/tabs/tv_episode_disc_map_tab.dart` | EDIT | Move to TV owner |
| `video/edit/tabs/tv_episodes_tab.dart` | EDIT | Move to TV/Anime owner |
| `video/edit/tabs/tv_release_media_tab.dart` | EDIT | Move to TV owner |
| `video/edit/tabs/video_cast_tab.dart` | EDIT | Split into kind edit flows |
| `video/edit/tabs/video_crew_tab.dart` | EDIT | Split into kind edit flows |
| `video/edit/tabs/video_discs_tab.dart` | EDIT | Split into kind edit flows |
| `video/edit/tabs/video_edit_models.dart` | DOMAIN MODEL | Split by kind edit schemas |
| `video/edit/tabs/video_edit_tab_helpers.dart` | EDIT | Keep only owner-neutral helpers |
| `video/edit/tabs/video_edition_tab.dart` | EDIT | Split by kind release semantics |
| `video/edit/tabs/video_links_tab.dart` | EDIT | Split by kind edit flows |
| `video/edit/tabs/video_media_tab.dart` | EDIT | Split by kind edit flows |
| `video/edit/tabs/video_specs_tab.dart` | EDIT | Split by kind edit flows |
| `video/edit/video_custom_tab_builder.dart` | EDIT | Move into kind edit composition |
| `video/edit/video_edit_controller.dart` | DOMAIN BEHAVIOR | Split into kind controllers |
| `video/edit/video_kind_edit_draft.dart` | DOMAIN MODEL | Replace with kind drafts |
| `video/edit/widgets/tv_episode_row.dart` | VISUAL STRUCTURAL | Move/duplicate into TV/Anime |
| `video/edit/widgets/tv_episode_thumbnail.dart` | VISUAL STRUCTURAL | Move/duplicate into TV/Anime |
| `video/release/video_release_projection_capability.dart` | DOMAIN BEHAVIOR | Move into kind release projections |
| `video/release/video_release_source.dart` | DOMAIN BEHAVIOR | Move into kind release sources |
| `video/video_detail_page.dart` | DOMAIN BEHAVIOR | Split into movie/TV/anime detail |
| `video/video_drilldown_library_page_state.dart` | HIERARCHY | Move into TV/Anime hierarchy |
| `video/video_external_links_section.dart` | EDIT | Split into kind detail flows |
| `video/video_inspector_panel.dart` | EDIT | Split into kind inspector flows |
| `video/video_inspector_sections.dart` | FIELDS | Split into kind-owned fields |
| `video/video_library_media_presentation_builder.dart` | DOMAIN BEHAVIOR | Move into kind presentation |
| `video/video_metadata_corrections_section.dart` | DOMAIN BEHAVIOR | Move into kind metadata flows |
| `video/video_release_projection_capability.dart` | DOMAIN BEHAVIOR | Move into kind release projections |
| `video/video_release_source.dart` | DOMAIN BEHAVIOR | Move into kind release sources |

## Audit outcome

The shared directory contains no persistence or provider implementation that
is safe to treat as universal merely because it is reused. The remaining
shared candidates are small visual components and must expose owner-neutral
inputs; all video domain, hierarchy, edit, field, provider, release, and
tracking behavior is queued for PR79. Ten video boundaries have already moved
out during PR79 progress: TV legacy models, TV display models, per-kind video
physical formats, generic Add provider-kind filter chrome, and episodic
tracking rules for TV/Anime. Movie's release shelf drilldown is also now
Movie-owned; the unused workspace progress surface has been removed. Universal
session history and its presenter now live under library tracking. The Add
seasons/episodes preview and video result policy are also now part of generic
Add infrastructure. TV
now owns episodic progress, identity, row/card, season-tracking, rating, and
upcoming-episode surfaces. The TV season provider compatibility layer is now
TV-owned as well.
