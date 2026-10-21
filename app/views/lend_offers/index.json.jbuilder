json.results do
  json.array! @lend_offers, partial: "lend_offers/lend_offer", as: :lend_offer
end

json.set! :num_pages, @lend_offers.total_pages
json.set! :num_results, @lend_offers.total_count
json.set! :current_page, @lend_offers.current_page
