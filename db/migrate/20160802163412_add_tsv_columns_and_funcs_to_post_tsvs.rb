class AddTsvColumnsAndFuncsToPostTsvs < ActiveRecord::Migration
  def up

    add_column :post_tsvs, :tsv_content, :tsvector
    add_column :post_tsvs, :tsv_options, :text
    add_column :post_tsvs, :tsv_weight, :character

    add_index :post_tsvs, :tsv_content, using: 'gin'

    execute <<-SQL
      CREATE OR REPLACE FUNCTION func_transform_to_tsv_for_post_tsvs()
      RETURNS trigger AS
      $$
      DECLARE

        value_to_convert_to_tsv text;

        weight_value "char";

        dictionary_is_set boolean := true;
        dictionary_value regconfig;

      BEGIN

      value_to_convert_to_tsv := coalesce(new.content, '');

      weight_value := coalesce(new.tsv_weight, 'D');

      if new.tsv_options = 'russian' then
        dictionary_value := 'russian';
      elsif new.tsv_options = 'english' then
        dictionary_value := 'english';
      else
        dictionary_is_set := false;
      end if;


      if dictionary_is_set then
        new.tsv_content = setweight(to_tsvector(dictionary_value, value_to_convert_to_tsv), weight_value);
      else
        new.tsv_content = setweight(to_tsvector(value_to_convert_to_tsv), weight_value);
      end if;


      RETURN NEW;

      END;
      $$

      LANGUAGE 'plpgsql'
    SQL

    execute <<-SQL
      create trigger transform_post_tsvs_content_to_tsv
      before insert or update on post_tsvs
      for each row
      execute procedure func_transform_to_tsv_for_post_tsvs()
    SQL


  end


  def down
    execute <<-SQL
      DROP TRIGGER if exists transform_post_tsvs_content_to_tsv
      ON post_ts_searches CASCADE;
      DROP function if exists func_transform_to_tsv_for_post_tsvs() CASCADE;

    SQL

    remove_index :post_tsvs, :tsv_content
    remove_column :post_tsvs, :tsv_content
    remove_column :post_tsvs, :tsv_weight
    remove_column :post_tsvs, :tsv_options
  end
end
