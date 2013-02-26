class ReservationMailer < ActionMailer::Base
  default from: "gswg@library.nyu.edu"
  
  def confirmation_email(res)
    @reservation = res
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => "NYU Libraries- Room reservation confirmation")
  end
  
  def cancellation_email(res)
    @reservation = res
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => "NYU Libraries- Room reservation cancellation")
  end

  def block_cancellation_admin_email(res, formatted_reservations, admin_email, cancel_request)
    @reservation = res
    mail(:to => admin_email, :subject => "NYU Libraries- Room reservation cancellation", :formatted_reservations => formatted_reservations, :cancel_request => cancel_request)
  end
  
  def block_cancellation_email(res, cc, body)
    @reservation = res
    mail(:to => @reservation.user.email, :cc => @reservation.cc, :subject => "NYU Libraries- Room reservation cancellation", :body_text => body)
  end
end
