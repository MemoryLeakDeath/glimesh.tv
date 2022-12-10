defmodule Glimesh.Repo.Migrations.MergeTagsAndDropCategoryTies do
  use Ecto.Migration

  def up do
    create_data_migration_temp_table = "SELECT * INTO tag_migration FROM tags"
    create_data_migaration_channel_temp_table = "SELECT * INTO channel_tags_migration FROM channel_tags"
    create_data_migration_stream_temp_table = "SELECT id, unnest(category_tags) AS category_tags INTO streams_tag_migration FROM streams"
    execute(create_data_migration_temp_table)
    execute(create_data_migration_channel_temp_table)
    execute(create_data_migration_stream_temp_table)

    alter table(:tags) do
      remove :identifier
      remove :category_id
    end

    truncate_table = "TRUNCATE TABLE tags CASCADE"
    execute(truncate_table)

    move_and_merge_tag_data =
      "
      INSERT INTO tags (id, name, slug, icon, count_usage, inserted_at, updated_at)
      SELECT DISTINCT ON(slug) id, name, slug, icon, count_usage, inserted_at, updated_at
      FROM tag_migration
      "
    execute(move_and_merge_tag_data)

    move_and_merge_channel_tag_data =
      "
      INSERT INTO channel_tags (id, channel_id, tag_id)
      SELECT ctm.id,ctm.channel_id,t.id FROM channel_tags_migration ctm
      INNER JOIN tag_migration tm ON (ctm.tag_id = tm.id)
      INNER JOIN tags t ON (tm.slug = t.slug)
      "
    execute(move_and_merge_channel_tag_data)

    move_and_merge_stream_tag_data =
      "
      UPDATE streams
      SET category_tags = inner_query.category_tags
      FROM(
          SELECT DISTINCT ON(stm_inner.id) stm_inner.id,
          ARRAY(
              SELECT t.id AS category_tags
              FROM streams_tag_migration stm
              INNER JOIN tag_migration tm ON (stm.category_tags = tm.id)
              INNER JOIN tags t ON (tm.slug = t.slug)
              WHERE stm_inner.id = stm.id
              ) AS category_tags
          FROM (
              SELECT stm.id, t.id AS category_tags from streams_tag_migration stm
              INNER JOIN tag_migration tm ON (stm.category_tags = tm.id)
              INNER JOIN tags t ON (tm.slug = t.slug)
          ) stm_inner
      ) inner_query
      WHERE streams.id = inner_query.id
      "
    execute(move_and_merge_stream_tag_data)

    drop_data_migration_temp_table = "DROP TABLE IF EXISTS tag_migration"
    drop_data_migration_channel_temp_table = "DROP TABLE IF EXISTS channel_tags_migration"
    drop_data_migration_stream_temp_table = "DROP TABLE IF EXISTS streams_tag_migration"
    execute(drop_data_migration_temp_table)
    execute(drop_data_migration_channel_temp_table)
    execute(drop_data_migration_stream_temp_table)
  end

  def down, do: true
end
