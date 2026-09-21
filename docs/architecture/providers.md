# Provider architecture

Provider adapters own wire protocol and provider-native models under
`lib/features/providers/adapters/<provider>/`. They normalize provider results
into `ProviderRawEnvelope` at the provider-to-kind edge. Semantic mapping
starts only after that boundary and belongs to the target kind, for example:

```text
providers/adapters/anilist/       protocol + native payload
library/kinds/anime/provider/     Anime semantic mapping
library/kinds/manga/provider/     Manga semantic mapping
```

The provider-kind matrix is explicit in
`test/features/providers/provider_kind_mapping_contract_test.dart` and its
manifest. It covers every mapped pair, including providers that serve more
than one kind. Personal-list ingestion remains a separate personal-state
adapter and is not treated as catalog metadata mapping. `ProviderSearchResult`
carries only structural identity/presentation fields; kind-specific search
attributes are opaque and decoded by the kind candidate mapper.

Provider changes should therefore update the adapter contract, the owning
kind mapper, and the applicable typed provider contract test together.
