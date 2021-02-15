require 'httparty'

class Request
  include HTTParty
  attr_reader :http_response

  headers 'Content-Type' => 'application/json'
  headers 'Accept' => 'application/json'

  def success_response?
    (200..299).cover?(status.to_i)
  end

  def status
    http_response&.code
  end

  def parsed_response
    http_response&.parsed_response
  end
end