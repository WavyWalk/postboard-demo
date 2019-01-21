class MediaStory < Model
  
  register

  attributes :id, :title, :user_id

  has_many :media_story_nodes, class_name: 'MediaStoryNode'


  route :create, post: "media_stories"
  route :Show, get: "media_stories/:id"
  route :update, {put: "media_stories/:id"}, {defaults: [:id]}

end