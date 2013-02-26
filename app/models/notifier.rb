class Notifier < ActionMailer::Base
  def direct_email(e_subject, e_send_to, formatted_body, e_cc)
      recipients e_send_to
      from "Bobst Library Graduate Room Reservation System <gswg@library.nyu.edu>"
      reply_to "no-reply@library.nyu.edu"
      cc e_cc unless e_cc.nil?
      subject e_subject
      sent_on Time.now
      body :formatted_body => formatted_body
  end
  
  def notice_of_cancellation(e_subject, e_send_to, formatted_body, e_from, e_cc)
      recipients e_send_to
      from "Bobst Library Graduate Room Reservation System <gswg@library.nyu.edu>" if e_from.nil?
      from e_from unless e_from.nil?
      reply_to "no-reply@library.nyu.edu"
      cc e_cc unless e_cc.nil?
      subject e_subject
      sent_on Time.now
      body :formatted_body => formatted_body
  end
end
