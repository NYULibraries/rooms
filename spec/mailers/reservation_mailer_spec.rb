require 'rails_helper'

describe ReservationMailer, elasticsearch: true do

  let(:reservation) { create(:reservation) }
  let(:confirmation_email) { ReservationMailer.confirmation_email(reservation) }
  let(:cancellation_email) { ReservationMailer.cancellation_email(reservation) }

  describe "#confirmation_email" do
    subject { confirmation_email.body.raw_source }
    it { is_expected.to include "You have successfully reserved a study space. Reservation details below:" }
    it { is_expected.to include "Name: #{reservation.user.firstname} #{reservation.user.lastname}" }
    it { is_expected.to include "Date: #{reservation.start_dt.strftime('%a. %b %d, %Y')}" }
    it { is_expected.to include "Time: #{reservation.start_dt.strftime('%I:%M %p')} - #{reservation.end_dt.strftime('%I:%M %p')}" }
    it { is_expected.to include "Location: #{reservation.room.title}" }
    it { is_expected.to include "If you need help finding your study room or need to report a problem, visit the Circulation Services Desk (on the 1st floor of Bobst Library) or use <a href=\"http://library.nyu.edu/ask\">Ask a Librarian</a>" }
    it { is_expected.to include "To adjust or cancel your reservation, <a href=\"https://library.nyu.edu/services/study-spaces/reservable-study-spaces/reservable-study-rooms-bobst-library/\">https://library.nyu.edu/services/study-spaces/reservable-study-spaces/reservable-study-rooms-bobst-library/</a>" }
    it { is_expected.to include "Please help us improve this service by taking <a href=\"https://nyu.qualtrics.com/jfe/form/SV_3fTab30NE6XdnsF\">this brief survey</a>" }
  end

  describe "#cancellation_email" do
    subject { cancellation_email.body.raw_source }
    it { is_expected.to include "You have successfully cancelled a study space. Reservation details below:" }
    it { is_expected.to include "Name: #{reservation.user.firstname} #{reservation.user.lastname}" }
    it { is_expected.to include "Date: #{reservation.start_dt.strftime('%a. %b %d, %Y')}" }
    it { is_expected.to include "Time: #{reservation.start_dt.strftime('%I:%M %p')} - #{reservation.end_dt.strftime('%I:%M %p')}" }
    it { is_expected.to include "Location: #{reservation.room.title}" }
    it { is_expected.to include "If you need help finding your study room or need to report a problem, visit the Circulation Services Desk (on the 1st floor of Bobst Library) or use <a href=\"http://library.nyu.edu/ask\">Ask a Librarian</a>" }
    it { is_expected.to include "To adjust or cancel your reservation, <a href=\"https://library.nyu.edu/services/study-spaces/reservable-study-spaces/reservable-study-rooms-bobst-library/\">https://library.nyu.edu/services/study-spaces/reservable-study-spaces/reservable-study-rooms-bobst-library/</a>" }
    it { is_expected.to include "Please help us improve this service by taking <a href=\"https://nyu.qualtrics.com/jfe/form/SV_3fTab30NE6XdnsF\">this brief survey</a>" }
  end

end
