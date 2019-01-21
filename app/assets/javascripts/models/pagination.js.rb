class Pagination < Model

	register

	attributes :current_page, :total_entries, :total_pages, :next_page, :previous_page, :offest

end
