class UserMailer < ApplicationMailer
  default from: 'automail@gmail.com'
  def warning_email(email)
    @greeting = "Здравствуйте!"
    mail(to: email, subject: 'Внимание: Изменение IP-адреса')
  end
end
