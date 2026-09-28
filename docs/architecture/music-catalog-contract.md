# Music Fields in Catalog Item v1

Music is one typed kind in the source-neutral `CatalogItemV1` API. Its details
cover album metadata, identifiers, ordered disc titles, tracks, credits, images,
and links. Core exports the complete graph in
`contracts/catalog-item-v1.json`; App pins that artifact and generates all
kind transport types with `tool/generate_catalog_item_v1_dto.dart`.

There is no separate Music catalog contract or DTO generator. Music editions
and the other eight kinds share one Catalog Item identity and one versioned
wire contract. App-owned copies, collection state, purchase information,
personal images, and activity remain outside Core's catalog contract.
