class DiiaService
  def initialize(acquirer_token)
    @acquirer_token = acquirer_token
    @base_url = ENV["DIIA_ENV"] == "production" ? "https://api2.diia.gov.ua" : "https://api2s.diia.gov.ua"
    @client = Faraday.new(url: @base_url) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def get_session_token
    response = @client.post("/api/v1/auth/acquirer/#{@acquirer_token}") do |req|
      req.headers["accept"] = "application/json"
      req.headers["Content-Type"] = "application/json"
    end
    response.body["token"] if response.success?
  end
end
