class VideoEmbed < Model

  register

  attributes :id, :link, :provider

  route :create, post: 'video_embeds'
  route :destroy, {delete: 'video_embeds/:id'}, {defaults: [:id]}

end