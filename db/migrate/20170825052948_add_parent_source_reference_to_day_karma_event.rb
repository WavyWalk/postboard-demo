class AddParentSourceReferenceToDayKarmaEvent < ActiveRecord::Migration
  def change
    add_reference :day_karma_events, :parent_source, polymorphic: true, index: {name: 'dke_on_ps'}
  end
end
