require 'rails_helper'

describe ReservationMailer, elasticsearch: true do

  let(:title) { 'Maintenance' }
  let(:reservation) { create(:reservation) }
  let(:block) { create(:block, title: title) }
  let(:formatted_reservations) { nil }
  let(:admin_email) { nil }
  let(:cancel_request) { nil }
  let(:cc) { nil }
  let(:body) { nil }
  let(:confirmation_email) { ReservationMailer.confirmation_email(reservation) }
  let(:cancellation_email) { ReservationMailer.cancellation_email(reservation) }
  let(:block_cancellation_admin_email) { ReservationMailer.block_cancellation_admin_email(block, formatted_reservations, admin_email, cancel_request) }
  let(:block_cancellation_email) { ReservationMailer.block_cancellation_email(block, cc, body) }

  describe '#confirmation_email' do
    subject { confirmation_email.body.raw_source }
    it { is_expected.to include "You have successfully reserved a study space. Reservation details below:" }
    it { is_expected.to include "Name: #{reservation.user.firstname} #{reservation.user.lastname}" }
    it { is_expected.to include "Date: #{reservation.start_dt.strftime('%a. %b %d, %Y')}" }
    it { is_expected.to include "Time: #{reservation.start_dt.strftime('%I:%M %p')} - #{reservation.end_dt.strftime('%I:%M %p')}" }
    it { is_expected.to include "Location: #{reservation.room.title}" }
    it { is_expected.to include "If you need help finding your study room or need to report a problem, visit the Circulation Services Desk (on the 1st floor of Bobst Library) or use <a href=\"http://library.nyu.edu/ask\">Ask a Librarian</a>" }
    it { is_expected.to include "To adjust or cancel your reservation, <a href=\"https://rooms.library.nyu.edu\">https://rooms.library.nyu.edu</a>" }
    it { is_expected.to include "Please help us improve this service by taking <a href=\"https://nyu.qualtrics.com/jfe/form/SV_3fTab30NE6XdnsF\">this brief survey</a>" }
  end

  describe '#cancellation_email' do
    subject { cancellation_email.body.raw_source }
    it { is_expected.to include "You have successfully cancelled a study space. Reservation details below:" }
    it { is_expected.to include "Name: #{reservation.user.firstname} #{reservation.user.lastname}" }
    it { is_expected.to include "Date: #{reservation.start_dt.strftime('%a. %b %d, %Y')}" }
    it { is_expected.to include "Time: #{reservation.start_dt.strftime('%I:%M %p')} - #{reservation.end_dt.strftime('%I:%M %p')}" }
    it { is_expected.to include "Location: #{reservation.room.title}" }
    it { is_expected.to include "If you need help finding your study room or need to report a problem, visit the Circulation Services Desk (on the 1st floor of Bobst Library) or use <a href=\"http://library.nyu.edu/ask\">Ask a Librarian</a>" }
    it { is_expected.to include "To adjust or cancel your reservation, <a href=\"https://rooms.library.nyu.edu\">https://rooms.library.nyu.edu</a>" }
    it { is_expected.to include "Please help us improve this service by taking <a href=\"https://nyu.qualtrics.com/jfe/form/SV_3fTab30NE6XdnsF\">this brief survey</a>" }
  end

  describe '#block_cancellation_admin_email' do
    subject { block_cancellation_admin_email.body.raw_source }
    it { is_expected.to include 'A block has been created and some reservations cancelled. Please save this e-mail for your records:' }
    context 'when the admin chooses not to notify users about deleting their reservations' do
      let(:cancel_request) { 'delete_no_alert' }
      it { is_expected.to include '(Note: Users HAVE NOT been notified of these cancellations)' }
    end
    context 'when the admin chooses to notify users about deleting their reservations' do
      let(:cancel_request) { 'delete_with_alert' }
      it { is_expected.to include '(Note: Users HAVE been notified of these cancellations)' }
    end
  end

  describe '#block_cancellation_email' do
    let(:body) { ':room :start :end' }
    subject { block_cancellation_email.body.raw_source }
    it { is_expected.to include 'Room 1' }
  end

end
