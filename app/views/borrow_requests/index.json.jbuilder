json.data do
  json.array! @borrow_requests, partial: "borrow_requests/borrow_request", as: :borrow_request
end

json.pagination do
  json.(@page, :next_cursor, :previous_cursor)
  json.has_next @page.has_next?
  json.has_previous @page.has_previous?
end
