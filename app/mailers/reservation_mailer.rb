class ReservationMailer < ActionMailer::Base
  default from: "Bobst Library Graduate Room Reservation System <gswg@library.nyu.edu>"
  
  def confirmation_email(res)
    @reservation = res
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => "NYU Libraries- Room reservation confirmation")
  end
  
  def cancellation_email(res)
    @reservation = res
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => "NYU Libraries- Room reservation cancellation")
  end

  def block_cancellation_admin_email(res, formatted_reservations, admin_email, cancel_request)
    @block = res
    @formatted_reservations = formatted_reservations
    @cancel_request = cancel_request
    mail(:to => admin_email, :subject => "NYU Libraries- Room reservation cancellation")
  end
  
  def block_cancellation_email(res, cc, body)
    @reservation = res
    @body_text = body
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => "NYU Libraries- Room reservation cancellation") unless @body_text.nil?
  end
end
