namespace :deleted_by do
  desc "New boolean field to manage deleted reservations, transfer old field"
  task :to_deleted_field => :environment do
    @reservations = Reservation.where("deleted_by IS NOT NULL")
    @reservations.each do |res|
      res.update_attributes(:deleted => true)
    end
  end
end