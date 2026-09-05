/// Structural repository contracts shared by kinds.
///
/// These contracts describe lifecycle shape only. They intentionally carry no
/// catalog, release, owned-item, or tracking semantics.
abstract interface class ReadRepository<TId, TEntity> {
  Future<TEntity?> findById(TId id);
}
