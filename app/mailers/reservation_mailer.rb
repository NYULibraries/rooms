class ReservationMailer < ActionMailer::Base
  default from: I18n.t('mailers.reservation_mailer.default_from'),
          reply_to: I18n.t('mailers.reservation_mailer.default_reply_to')
  
  def confirmation_email(res)
    @reservation = res
    @date_range = "#{@reservation.start_dt.strftime('%a. %b %d, %Y %I:%M %p')} -- #{@reservation.end_dt.strftime('%a. %b %d, %Y %I:%M %p')}"
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => I18n.t('mailers.reservation_mailer.confirmation_email.subject'))
  end
  
  def cancellation_email(res)
    @reservation = res
    @date_range = "#{@reservation.start_dt.strftime('%a. %b %d, %Y %I:%M %p')} -- #{@reservation.end_dt.strftime('%a. %b %d, %Y %I:%M %p')}"
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => I18n.t('mailers.reservation_mailer.cancellation_email.subject'))
  end

  def block_cancellation_admin_email(res, formatted_reservations, admin_email, cancel_request)
    @block = res
    @block_title = @block.title unless @block.title.blank?
    @formatted_reservations = formatted_reservations
    @cancel_request = cancel_request
    @alert_users = (@cancel_request == "delete_with_alert")
    @date_range = "#{@block.start_dt.strftime('%a. %b %d, %Y %I:%M %p')} -- #{@block.end_dt.strftime('%a. %b %d, %Y %I:%M %p')}"
    mail(:to => admin_email, :subject => I18n.t('mailers.reservation_mailer.block_cancellation_admin_email.subject'))
  end
  
  def block_cancellation_email(res, cc, body)
    @reservation = res
    
    unless body.blank?
      @body_text = body.gsub(/:room/,"#{@reservation.room.title}")
      @body_text = @body_text.gsub(/:start/,"#{@reservation.start_dt.strftime('%a. %b %d, %Y %I:%M %p')}")
      @body_text = @body_text.gsub(/:end/,"#{@reservation.end_dt.strftime('%a. %b %d, %Y %I:%M %p')}")
    end
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => I18n.t('mailers.reservation_mailer.block_cancellation_email.subject')) unless @body_text.nil?
  end
end
