json.results do
  json.array! @borrow_requests, partial: "me/borrow_requests/borrow_request", as: :borrow_request
end

json.set! :num_pages, @borrow_requests.total_pages
json.set! :num_results, @borrow_requests.total_count
json.set! :current_page, @borrow_requests.current_page
