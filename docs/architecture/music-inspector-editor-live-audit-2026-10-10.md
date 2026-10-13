# Sidebar, inspector and editor comparison - 2026-10-10

This continues [the sidebar audit](music-sidebar-live-audit-2026-10-10.md). The reference is the authenticated CLZ Music Web page inspected through Opera DevTools CLI. Collectarr is the rebuilt Web release served locally and driven through Playwright with disposable three-album fixtures. Both desktop captures use 1844 x 945; Collectarr also has a 700 x 650 capture. CLZ resizing remains unsupported by this Opera instance.

No catalog mutations were saved in CLZ. Reference editor tabs were opened and canceled. Reference action inventories establish that controls exist; they do not establish that their server operations succeed. Local draft disc/track/credit additions were canceled. This is an audit commit, with no application changes.

## Most significant findings

1. Music inspector uses the generic hero and metadata table, rather than the richer Music panel found elsewhere in the code. The registered contributor adds track lists when tracks exist, but does not assemble the rich panel's Credits, disc recording details, album details and listening sections. Do not interpret the empty fixture's lack of tracks as proof that track rendering is missing.
2. Duplicate and Loan are unavailable in the inspected library-entry inspector. The generic body explicitly passes `libraryEntry: null`; inspector action construction requires a non-null summary for those actions, despite retaining typed entry dispatch. Loan is visibly disabled and Duplicate is absent. This is an entry-context wiring issue, not evidence that loan persistence is unimplemented.
3. The editor still hardcodes a blue Save button (`0xFF5EB1DE`). Status icons and some other controls also show blue. The requested accent policy is therefore not yet uniformly applied outside the dialogs fixed in the previous audit.
4. Music editor width is 1024 px versus CLZ's 1200 px at the same viewport. The top edge is correctly anchored at 10 px in both. Changing tabs changes the bottom edge while preserving the header position.

## Sidebar and adjacent controls

| Area | CLZ | Collectarr evidence | Outcome |
| --- | --- | --- | --- |
| Sidebar geometry | 250 px wide; 38 px header; 33 px search band; 27 px folder rows | Same 250 px panel and 27 px rows in the desktop capture; search/action composition is close | Broad geometry aligned; icons and font metrics differ |
| Folder search / selection | Folder-name search, counts and selected bucket | Previous live audit verifies search narrows folder names without changing album scope, selection narrows albums, Reset restores all | Covered by previous live checks |
| Alphabetical / count ordering | Separate compact ordering controls | Count toggle changes tooltip/state; Genre fixture retains None/Jazz/Rock, each count 1 | Toggle verified; unequal-count ordering and direction remain to test |
| Folder categories | Images, Main, Details, Classical, People, Personal | Expandable category menu with favorites and Music v2 fields | Classical/People replacement by Credits is intentional; do not restore root role arrays |
| Nested folders / Back | Nested favorites and ancestor navigation | Previous live run verifies Genre / Disc Format, entry into a nested scope and Back | Covered by previous audit |
| Vocabulary manager | Manage pick lists from folder controls | Previous create/rename/remove and duplicate checks; Genre manager button appears when Genre selected | Covered at evidence levels in prior report |
| Collection status | All, In Collection, For Sale, On Wish List, On Order, Sold, Not In Collection | Opened local menu contains all seven options | Menu coverage matched; this pass did not populate every status and verify result counts |
| Search scope | Albums & Tracks / Albums / Tracks | Local scope menu and kind search-target configuration provide corresponding choices | Presence checked; matching track-only queries remain to test with populated tracks |
| Alphabet field selector | Artist / Composer / Title in reference menu inventory | No equivalent selector established in this run | Open audit item; any Composer shortcut must use Music v2 credit semantics |
| Hide/show and tree/list controls | Folder presentation/navigation controls | Existing code and prior nested navigation evidence; remainder script could not locate overflow in a layout where the Genre manager fits directly | Do not claim hide/show or tree/list interaction passed in this run |
| Responsive layout | Reference desktop inspected only | At 700 x 650 inspector moves below workspace; sidebar remains; collection strip remains visible | Narrow layout works broadly, but All in the alphabet strip wraps/clips and fewer content rows remain visible |
| Icons / colors | Font Awesome; #383838 sidebar/header; blue selected folder | Material icons; app palette; orange selected folder | Accent difference is intentional. Icon shape and neutral-color parity remain open |

Existing sort/column favorites, collection CRUD/reordering, vocabulary updates and nested navigation results remain in the preceding audit; they were not all repeated here.

## Inspector

CLZ's right pane is 350 px wide with a 38 px toolbar. Its base background is #131313. The reference selected item shows cover navigation, artist/title, label/year/genres, rating, barcode, country, format, disc/track counts, total duration, catalog number, grouped tracks, Credits, Details, Personal and Links. Metadata links provide filter affordances. This is inventory evidence from a populated reference item.

| Feature | Collectarr observation / source trace | Gap |
| --- | --- | --- |
| Hero and hierarchy | Registered Music hero delegates to generic `LibraryDetailHero`; desktop card shows title/status/update date with truncation | Music-specific hierarchy, metadata placement and cover navigation differ |
| Tracks | Registered Music presentation builder adds `MusicInspectorTrackList` when actual tracks exist | Not globally missing; populated live inspector grouping/durations still need verification |
| Credits / disc details | Rich `MusicInspectorPanel` contains these sections, but `buildMusicInspectorPanel` has no call site; active contributor builds generic metadata plus presentation track sections | Rebuild active inspector contributions around Music v2 and remove unused duplicate panel after cutover |
| Personal information | `showsDefaultPersonalSection: false`; active entry contributor adds selected entry-media facts, not the full rich panel | Personal parity is incomplete; inventory with a populated personal fixture required |
| Duplicate / Loan | Generic host passes null summary; Duplicate callback becomes null, Loan is disabled | Restore entry context through current dispatch architecture |
| Move to other collection | No option in inspected inspector toolbar; action exists in context menu and selection controls | Discoverability gap in inspector, not absent collection support |
| Share | Callback accepted but no control in `InspectorUnifiedToolbar` | Reference has private-cloud/share-email controls; local sharing policy and implementation must be decided explicitly |
| Unlink from Core | Host passes null; toolbar menu has no unlink action | Missing inspector action; verify intended strict catalog behavior before adding it |
| Update from Core | Menu option is visible | Not executed against reference or local backend in this run |
| Edit / Remove / Wishlist / Open | Local quick-action controls are present; Edit opens the editor | Edit entry point verified; destructive actions not exercised in this run |
| Layout | Dropdown exists; narrow pane is automatically placed below workspace | Manual Horizontal / Vertical / No Details switching and persistence remain to verify |
| eBay | Local icon/pill exists; reference includes sold-listings link | Outbound destination not opened; no success claim |

Relevant source boundaries: `generic/body.dart` passes the selected source dispatch but a null summary; `inspector/library_inspector.dart` derives entry actions from the summary. Music registration lives in `config/music_kind_capabilities.dart`; active builders are in `inspector/music_entity_inspector_contributors.dart`. The separate rich panel is `music/inspector_panel.dart`. Do not reconnect an obsolete panel blindly: preserve Music v2 disc-owned recording and generic scoped credits.

## Editor

All reference tabs were opened: Main, People, Details, Classical, Tracks, Personal, Custom Fields, Covers, My Images, Links. All local tabs were opened: Main, Details, Credits, Tracks, Personal, Custom Fields, Covers, My Images, Links. Icons are visible on local tabs. One Credits tab replacing People/Classical is deliberate.

| Area | Measured / observed difference | Follow-up |
| --- | --- | --- |
| Dialog | CLZ 1200 px wide, local 1024 px; both top = 10 px | Decide width parity and recheck field proportions at desktop/narrow sizes |
| Tabs | CLZ height 32 px, local semantic tab bounds 33 px; both dark inactive and raised active backgrounds | Small geometry/font/icon differences; reorder animation not exercised here |
| Fields | CLZ ordinary inputs are 34 px high, 4 px radius, #444444; local visible fields are approximately 32-34 px with matching curved outline | Compare rendered borders, not Flutter accessibility textbox boxes, which can extend beyond painted inputs |
| Status strip | Same four fields: Collection Status, Index, Quantity, Location; visible borders align in local captures | Current screenshot does not reproduce the old unequal-height complaint; responsive focus/caret checks remain |
| Main layout | Local Label uses full right-column width because recording date moved to discs; Format is read-only derived summary | Intentional semantics; root recording date and editable root format must not return |
| Typography | Reference Gilroy differs from Collectarr font. Local field values/covers toolbar/empty-state text often appear heavier; My Images helper text is smaller/lighter than reference | Tune per-control roles rather than increase weight globally |
| Accent | Save remains blue by a hardcoded footer style; status check icon is blue | Replace remaining blue controls with palette/kind accent consistently |
| Tracks | Empty album shows only right-aligned Add Disc, without old no-discs message; adding a draft disc reveals tab, table, Add Header/Add Track; Add Track creates a draft row | Requested empty-state positioning is satisfied; populated reorder/bulk interactions still need live checks |
| Credits | Add credit creates Name / Role / Instruments / Applies to row; immediately shows validation for blank name/role | Scope menu visibly offers Album and Disc 1 after adding a disc. Schema matches v2. Consider delaying error display until interaction/save; scope transfer/save/reopen not established by this run |
| Covers | Front/back outer borders removed; Upload, Find Online and Crop/Rotate present; large side-by-side previews | Actual search/download/crop persistence not exercised here; do not mark Find Online backend behavior closed |
| My Images | Both use centered dashed drop area, max-five helper, description/type semantics | Local helper weight/size and dashed-line contrast differ. Upload/drop/paste and save persistence remain untested here |
| Links | Local Name / URL / Description plus Add Link; CLZ visible URL / Description plus New Link | Extra Name is a product/domain choice; local empty-state row changes density |
| Previous / Next | Controls present; script invoked both but did not capture title assertions | Navigation success remains unverified, especially dirty-draft handling |
| Cancel | Reference canceled; local disc/credit draft sessions canceled | No user CLZ data changed |

## Recommended next work

1. Fix inspector entry-context wiring, then verify Duplicate and Loan against disposable entries; expose collection transfer alongside the existing context-menu flow.
2. Consolidate active Music inspector sections into kind-owned contributions. Include scoped Credits, disc recording/technical details, personal data and populated track lists. Delete the unused panel once its supported behavior has moved.
3. Remove hardcoded editor blue; align dialog width, typography roles and remaining narrow alphabet layout with the chosen accent policy.
4. Use a populated mixed-disc fixture for live scope transfer, save/reopen, track search, multiple group buckets, inspector metadata filters and Previous/Next dirty drafts.
5. Run real Find Online -> select result -> save -> reopen and image upload/crop/drop/paste checks with the backend. Share/Unlink require defined supported behavior; menu presence alone cannot close them.

## Implementation follow-up

The findings above describe the pre-fix comparison. The following changes have now landed:

- Entry inspectors resolve the selected entry summary, enabling Duplicate and Loan. The toolbar exposes Edit, Share, collection transfer and Unlink from Core for linked entries. Unlink preserves canonical and personal data and creates a durable sync update. Removal uses the page's existing confirmation flow.
- Music owns the active Overview, grouped Track List, Disc Details, Album details, Personal, Listening history, Credits and Links contributions. Recording data remains disc-owned; credits include role, instruments and album/disc scope. Front/back cover navigation supports remote URLs and local images. The unused inspector panel wrapper was deleted.
- Music editor width is 1200 px with its existing fixed 10 px top anchor. Save and text selection follow the kind accent. Typography roles were adjusted for ordinary values, the title and My Images helper. The narrow alphabet strip scrolls when necessary and keeps All on one line.
- New blank credit rows defer validation until interaction; selecting a valid role refreshes the error immediately. Inspector icon buttons expose accessible names and button actions.

Live Playwright verification against disposable local entries established:

- Find Online returned real image-provider results with dimensions; choosing a 600 x 600 Lupus Dei cover, saving and reopening retained the image.
- Hiding the folder sidebar and restoring Has Back grouping restored folder controls and all three entries.
- Adding Disc 1 and First Song (1:30), adding John with role Producer, changing Applies to from Album to Disc 1, saving and reopening retained both the track and scoped credit. The inspector displayed one disc, one track and the 1:30 total.
- Desktop editor geometry, accent Save and the narrow layout were captured again. CLZ data was not edited.

Share intentionally opens the existing local TXT/CSV export surface. Hosted public links, email sharing and CLZ privacy controls are not implemented. The alphabet field selector, complete manual inspector layout persistence, track-only search queries, dirty Previous/Next navigation and image upload/crop/drop/paste remain separate verification items; this follow-up does not claim complete CLZ parity.

Validation after the credit refresh: 819 tests passed with one existing skipped test; analyzer clean; Web release and Windows debug builds passed. Architecture checks found no boundary violations or repeated kind implementation clusters, with 364 complexity warnings remaining. Widget regressions cover validation clearing, accessible inspector actions, entry unlink preservation, editor geometry, accent Save and narrow alphabet navigation.

Additional temporary evidence: `fixed-online-reopened.png`, `fixed-sidebar-restored.png`, `fixed-music-reopened.png`, `fixed-music-save.log` and `fixed-music-narrow.png` under `%TEMP%/collectarr-browser-compare`.

## Original audit evidence and limits

Temporary browser artifacts are in `%TEMP%/collectarr-browser-compare`: `clz-editor-audit.log`, `clz-audit-editor-*.png`, `local-inspector-editor-tabs.log`, `local-editor-*.png`, `local-audit-inspector-more.png`, `local-inspector-narrow.png`, `local-sidebar-remainder.log`, and `local-final-menus.log`. Reference pane metrics are also in ignored `.tmp-reference-inspector-details.log`. These temporary artifacts are not permanent repository assets; the findings and metrics above are the committed record.

Flutter popup content can disappear from accessibility text while still visible in screenshots. Screenshots and source tracing were therefore used alongside semantic text. Two remainder scripts stopped on an unavailable overflow locator; those actions remain explicitly unverified rather than reported as product failures. No fresh full test/build gate was run for this documentation-only audit; the preceding code gate remains 816 tests passed, one skipped, analyzer and Web/Windows builds passing.
