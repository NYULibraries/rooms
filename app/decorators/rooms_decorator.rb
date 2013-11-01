class RoomsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :results

end