class Services::Pagination

  def self.extract_pagintaion_settings(params)
    return {
            per_page: params[:per_page] || 10,
            page: params[:page] || 1
          }
  end

  def self.extract_pagination_hash(pagination_model)

    {pagination: {current_page: pagination_model.current_page.to_i,  total_pages: pagination_model.total_pages}}

  end


end
