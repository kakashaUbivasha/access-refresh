class AuthController < ApplicationController
  SECRET_KEY = Rails.application.secrets.secret_key_base
  skip_before_action :verify_authenticity_token
  def token
    user = User.find_by(uuid: params[:uuid])
    if user
      payload = {
        uuid: user.uuid,
        ip: request.remote_ip,
        exp: 1.hour.from_now.to_i
      }
      access_token = JWT.encode(payload, SECRET_KEY, 'HS512')
      refresh_token = SecureRandom.urlsafe_base64
      user.update(refresh_token_digest: BCrypt::Password.create(refresh_token))
      render json: { access_token: access_token, refresh_token: refresh_token }
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end
  def refresh
    begin
      decoded_payload = JWT.decode(params[:access_token], SECRET_KEY, true, { algorithm: 'HS512' })
      payload = decoded_payload[0]
      user = User.find_by(uuid: payload['uuid'])

      current_ip = request.remote_ip
      if payload['ip'] != current_ip
        warning_mail(user.email)
      end
      refresh_token = params[:refresh_token]
      if user && BCrypt::Password.new(user.refresh_token_digest) == refresh_token
        user.update(last_ip: current_ip) if user.last_ip != current_ip
        new_payload = {
          uuid: user.uuid,
          ip: current_ip,
          exp: 1.hour.from_now.to_i
        }
        new_access_token = JWT.encode(new_payload, SECRET_KEY, 'HS512')
        render json: { access_token: new_access_token }
      else
        render json: { error: 'Invalid refresh token' }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: { error: 'Invalid Access token' }
    end
  end
  private
  def warning_mail(email)
    UserMailer.warning_email(email).deliver_now
  end
end
