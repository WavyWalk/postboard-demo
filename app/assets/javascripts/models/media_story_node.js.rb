class MediaStoryNode < Model 
  
  register

  attributes :id, :annotation, :media_type, :media_id, :media_story_id 

  has_one :media, polymorphic_type: :media_type 

  route :create, {post: "media_stories/:media_story_id/media_story_nodes"}, {defaults: [:media_story_id]}
  route :update, {put: "media_stories/:media_story_id/media_story_nodes/:id"}, {defaults: [:media_story_id, :id]} 
  route :destroy, {delete: "media_stories/:media_story_id/media_story_nodes/:id"}, {defaults: [:media_story_id, :id]}

end