# Plan de închidere a limitei dintre kind-uri

## Obiectiv

Codul din afara `lib/features/library/kinds/<kind>/` nu interpretează
metadatele unui kind. Primește un `CatalogMediaKind`, referințe de entități și
proiecții/contracte structurale; selectează capabilitatea kind-ului și îi
transmite operația. Câmpurile, ID-urile, etichetele, valorile, regulile,
maparea, persistența și prezentarea specifică rămân în kind-ul proprietar.

UI-ul comun, transportul și registries rămân comune când au rol structural:

- UI-ul comun poate afișa `label`, `summary` și `imageUrl` primite ca proiecție,
  dar nu știe că acestea provin din `publisher`, `episodeRuntime` ori alt câmp.
- Referințele comune identifică `kind`, `work`, `release` și `copy`; nu conțin
  metadata specifică.
- DTO-urile generate și modelele native de provider oglindesc contracte wire.
  Codul comun nu le interpretează; kind-ul mapează aceste DTO-uri în modelele
  sale.
- Root-urile de compoziție pot importa module concrete pentru a le înregistra.
  Nu conțin mapare, fallback-uri sau decizii despre câmpuri.
- Rendererele comune pot consuma definiții tipizate de câmp furnizate de kind;
  nu declară câmpuri concrete și nu au switch pe `CatalogMediaKind`.

Acesta este sensul operațional al regulii „în afara kind-urilor se cunoaște
doar tipul kind-ului”: shell-ul cunoaște discriminatorul și contractele
structurale, dar nu vocabularul sau schema de date a kind-ului.

## Inventarul curent de lucru

| Zonă | Ce știe acum stratul comun/providerul | Proprietarul țintă |
|---|---|---|
| Provider preview | `ProviderPreviewCommon` decodează ISBN, publisher, characters, story arcs, ratings și alte câmpuri; `toPreview` are sloturi `video`, `music`, `game`. | `kinds/<kind>/provider/` construiește proiecția preview tipizată; UI-ul comun primește numai preview structural. |
| Adaptoare provider | TMDb normalizează runtime/publisher/rating și ramifică după Movie/TV/Anime; GCD/ComicVine emit direct chei semantice ca `item_number` și `story_arcs`. | Adaptorul păstrează protocolul și payload-ul nativ; mapperul din kind decide câmpurile catalogului și normalizarea semantică. |
| Corecții Admin | Pagina și dialogul Admin citesc/compară câmpuri concrete din Movie, Comic, video și Music prin switch-uri pe chei. Contribuitorii Admin per kind există deja, dar nu dețin întregul flux. | Extinderea contribuției Admin per kind cu schemă, codec de citire/scriere și comparație; Admin randează schema. DTO-urile Core rămân wire. |
| Rute | `app_router.dart` construiește pagini Comic Creator, Character și Story Arc; `ComicRouteContributor` înregistrează acum doar seria Comic. | Rutele și numele lor în contribuția Comic; routerul de bază doar include rutele înregistrate. |
| Căutare metadata | Helperul generic expune `series`, `issueNumber` și `publisher` ca argumente universale. | Builder de query în integrarea kind-ului; `MetadataSearchQuery` rămâne DTO de transport dacă acesta este contractul Core. |
| Add/edit | Starea și controllerul Add transportă `CatalogSearchCandidate`, accesează `editMetadata` și gestionează implicit format fizic în shell-ul comun. Sunt amestecate căutarea, hidratarea, scanarea, preview-ul și submit-ul. | Kind-ul proiectează candidatul, draft-ul și opțiunile sale. Host-ul comun păstrează ID-ul selecției, rezumatul structural și ciclul de viață al dialogului. |
| Documentație | Unele audituri numesc fișiere șterse; statusul persistence spune versiunea 1, în timp ce baza declară schema 2; gap analysis-ul Music marchează track list-ul ca lipsă deși există. | Actualizare după fiecare lot, cu branch/head real, migrații și starea verificărilor. |

Acest tabel este inventar inițial din codul curent, nu allowlist de scutiri.
Lista finală se completează cu raportul checkerului din primul lot.

## Limita de proprietate

### Rămân în kind

- modele de metadata, work/release/copy, owned details și drafts tipizate;
- field IDs, etichete, valori implicite, vocabulare și physical-format options;
- proiectoare Core/provider/local și codec-uri de import/export/sync;
- query mapping, candidate preview, hierarchy, facets, filters, sorts, groups,
  columns, stats, tracking, calendar, activity, barcode și route contributors;
- regulile de fallback, matching, ranking și editare pentru acele câmpuri.

### Rămân în shell-ul comun

- dispatch după `CatalogMediaKind` și lookup de capabilitate;
- layout, navigare, dialog lifecycle, loading/error/empty states și controale
  care operează pe o schemă structurală;
- referințe, selecție după ID și proiecții neutre pentru card/listă;
- interfețe de capabilitate fără enum-uri, sloturi sau metode cu câmpuri ale
  kind-urilor;
- root-uri explicite de compoziție și registries care doar leagă kind-ul de
  contribuțiile sale.

### Excepții de transport, fără logică semantică

- DTO-urile generate Core și DTO-urile API publice rămân la granița HTTP;
- modelele provider-native rămân în `providers/adapters/<provider>/`;
- schema wire versionată poate avea chei serializate pentru toate kind-urile;
- Drift universal păstrează ownership, locații, sync și alte date realmente
  comune; tabelele și mapper-ele cu coloane specifice rămân în kind.

Un fișier nu este exceptat doar pentru că se numește „transport”, „common” sau
„registry”. Excepția se acordă pe rol și pe tipul de conținut.

## Etapele de migrare

### Etapa 0 — Reguli și baseline automat

1. Generează `tool/architecture/generated/kind-field-ownership.json` din
   tabelele Drift ale celor nouă kind-uri active, aliasurile găsite în mapper-ele
   locale și ID-urile de câmp din workspace. Coloanele JSON se leagă de
   proprietățile modelului, de exemplu `storyArcsJson` → `storyArcs`.
2. Folosește manifestul pentru a detecta în modelele generice, library/catalog
   și mapper-ele Core accesări/declarații de câmpuri deduse, precum și chei
   string în map-uri și indexări.
3. Păstrează un baseline exact în
   `tool/architecture/kind-field-leak-baseline.json`, cheie după cale,
   suprafață și simbol. Intrările devenite stale eșuează checkerul, iar o
   apariție nouă nu este acoperită de o scutire pe director.
4. Lasă inspectarea protocolului nativ al providerilor și DTO-urilor wire în
   afara regulii noi; regulile AST existente pentru importuri, tipuri concrete,
   map-uri generice și dispatch după kind continuă să ruleze.
5. Generează manifestul în CI înainte de verificarea fișierelor generate și
   testează atât inferența din schema/mapper/ID-uri, cât și respingerea unor
   câmpuri și chei de mapă noi în cod generic.

**Stare:** implementată. Baseline-ul inițial conține 435 de combinații cale /
suprafață / simbol deja găsite. Sunt potriviri sintactice candidate, nu o
validare cu type resolution; sunt păstrate separat pentru ca etapele următoare
să le poată elimina odată cu mutarea câmpurilor în kind-uri.

**Gata când:** CI regenerează același manifest, detectează orice utilizare
sintactică nouă în suprafețele urmărite și obligă la eliminarea intrărilor
baseline după migrare.

### Etapa 1 — Rute și compoziție

1. Mută rutele Comic Creator/Character/Story Arc în `ComicRouteContributor`.
2. Mută constantele și constructorii de locații în kind-ul respectiv.
3. Păstrează în `app_router.dart` doar rutele cross-app și lista de rute
   înregistrate.
4. Inventariază rutele de detail existente și mută orice alt route/page care
   citește direct un domeniu concret.

**Gata când:** routerul de bază nu importă un modul/page concret de kind și
adăugarea unei rute kind-specific se face fără editarea routerului.

### Etapa 2 — Admin generic, contribuții tipizate

1. Definește o schemă structurală de editare pentru Admin: tip control,
   cardinalitate, etichetă, validare și binding generic.
2. Completează contributorul fiecărui kind cu maparea proprie dintre schema sa
   tipizată și `AdminMetadataCorrectionValues`.
3. Mută în kind citirea valorii Core curente, aplicarea propunerii și
   compararea înainte/după.
4. Înlocuiește switch-urile din `admin_page.dart` și
   `admin_metadata_correction_dialog.dart` cu iterarea schemei primite.
5. Păstrează DTO-urile Admin generate, autorizarea, API-ul și chrome-ul în
   feature-ul Admin/Core.

**Gata când:** pentru a adăuga sau redenumi un câmp Admin se modifică numai
kind-ul, schema transport dacă este necesară și testul de contract; fișierele
Admin comune nu se schimbă.

### Etapa 3 — Provider boundary și preview

1. Redu `ProviderPreviewCommon` la identitate, titlu, summary și imagine sau
   elimină-l în favoarea unei proiecții structurale comune.
2. Mută decodarea ISBN, publisher, story arcs, characters, video/music/game
   metadata în mapperele kind-urilor.
3. Adaptoarele păstrează DTO-urile native, URL-uri, auth, rate limits și
   extragerea protocolului; nu aleg modelul de domeniu și nu scriu schema
   semantică a catalogului.
4. Extinde separat integrările TMDb Movie/TV/Anime și ComicVine/GCD Comic.
5. Verifică separat `AdminProviderPreview` și `ProviderRawEnvelope`: primul
   rămâne transport API dacă Core îl cere; al doilea rămâne opac pentru host.

**Gata când:** preview-ul generic nu declară câmpuri de kind și un câmp Core nou
este mapat prin integrarea kind-ului fără schimbări în preview host.

### Etapa 4 — Add/Edit/metadata tipizate

1. Schimbă fluxul generic să păstreze `CatalogDisplaySummary` și ID-ul
   candidatului; decodează payload-ul selectat doar prin mapperul kind-ului.
2. Elimină accesul generic la `CatalogSearchCandidate.editMetadata`, `copyWith`
   semantic și orice `mapTransport` în widget/controller comun.
3. Mută hydration merge, release selection mapping și provider proposal mapping
   în integrația Add/Edit a kind-ului. Host-ul comun decide doar momentul
   căutării/seleției/submit-ului.
4. Mută default-urile și câmpurile de draft specifice din state-ul comun în
   typed Add draft/capability; lasă în state doar valori universal personale.
5. Descompune `LibraryAddSessionController` în căutare, preview/hydration,
   provider action și submit. Evită subdivizarea pură după număr de linii.
6. Revizuiește query builder-ele din metadata compare/cache și fluxurile de
   import ca să transmită query-uri construite de kind.

**Gata când:** controllerul/dialogul Add pot rula fără a citi metadata generică
din candidatul Core/provider și toate drafts păstrează tipul kind-ului.

### Etapa 5 — Auditul tuturor suprafețelor transversale

Verifică fiecare modul care primește `CatalogMediaKind`: collection/CSV,
owned/wishlist/loans, sync/tracking, stats/activity/calendar, barcode,
catalog/provider, workspace/table/sidebar, export/import, detail/inspector,
settings, admin și seed-uri.

Pentru fiecare câmp întâlnit:

1. identifică owner-ul de domeniu;
2. mută schema, valorile și mapping-ul în acel kind;
3. lasă generică doar orchestration-ul și renderer-ul structural;
4. adaugă test de contract pentru toate kind-urile aplicabile.

Nu muta primitive universale sau contracte Core doar pentru că au un câmp
similar. De exemplu, un DTO extern păstrează forma Core; kind-ul deține
interpretarea și proiecția în modelul propriu.

**Gata când:** căutarea AST/field inventory nu mai găsește semantică în afara
kind-urilor, cu excepțiile documentate din secțiunea de transport/compoziție.

### Etapa 6 — Documente și release gate

1. Actualizează `current-status.md`, `local-persistence.md`, branch audit-ul,
   parity report-ul și feature-gap analysis-ul după implementare.
2. Elimină referințele la fișiere șterse și snapshots care pretind un head/branch
   curent neactualizat.
3. Documentează politica reală de migrare Drift și testează migrațiile dintre
   fiecare schema version încă suportată.
4. Rulează checkerul, contract tests, analyzer, suită completă, smoke test,
   generator-ele și web build-ul definite în CI.

## Împărțire recomandată în pull request-uri

1. **Boundary contract:** regulă, checker, teste checker și allowlist precis.
2. **Routes + Admin:** mutare fără schimbarea contractelor Core.
3. **Provider preview:** preview comun structural și mappere per kind/provider.
4. **Add/Edit:** candidate structural, drafts tipizate, decompoziție orchestration.
5. **Cross-cutting sweep:** export/import/tracking/stats/calendar/settings și
   orice finding nou din checker.
6. **Docs + release gate:** baseline final, migrații și eliminarea datoriilor
   documentare temporare.

Fiecare PR trebuie să rămână analizabil independent și să actualizeze generarea,
contract tests și documentația owner-ului odată cu schimbarea.

## Criterii finale de acceptare

- În afara `kinds`, niciun feature nu citește, scrie, etichetează, validează,
  sortează, grupează, caută sau serializează un câmp specific unui kind.
- Nu există switch-uri pe `CatalogMediaKind` în ecrane, servicii sau helpers
  generici; dispatch-ul este în registry/capability boundary.
- Provider adapters nu emit modele comune care combină câmpuri concrete;
  kind-ul mapează protocolul în propriile modele.
- API DTO-urile rămân transport pur; decodarea lor semnificativă se face în
  remote mapper-ul owner-ului.
- Tabelele și codec-urile de date specifice sunt kind-owned; DB-ul comun doar
  compune schema și deține datele cu adevărat universale.
- Fiecare câmp nou adăugat în Core/provider produce o clasificare explicită și
  un mapping sau motiv documentat pentru ignorare.
- Checkerul de boundary rulează în CI, are excepții motivate și nu are
  allowlist-uri globale pentru straturi întregi de feature.
- Documentele de arhitectură reflectă codul, schema DB și commit-ul curent.
