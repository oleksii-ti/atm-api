require 'bundler'
Bundler.require(:default, :test)
require './app.rb'

describe 'Withdraw' do
  def withdraw
    Withdraw
  end

  after :each do
    $atm.reset_current_deposit
  end

  let!(:browser) { Rack::Test::Session.new(Rack::MockSession.new(withdraw)) }

  context '200 calls' do
    after :each do
      expect(browser.last_response.status).to eq(200)
    end

    it 'one' do
      post_params = {amount: 1}
      browser.put '/api/v1/withdraw', post_params
      expect(JSON.parse browser.last_response.body).to eq({'1' => 1})
    end

    it 'consume one type' do
      post_params = {amount: 500}
      browser.put '/api/v1/withdraw', post_params
      expect(JSON.parse browser.last_response.body).to eq({'50' => 10})
      expect($atm.current_deposit).to eq({'1' => 10, '2' => 10, '5' => 10, '10' => 10, '25' => 10, '50' => 0})
    end

    it 'consume all balance' do
      post_params = {amount: 930}
      browser.put '/api/v1/withdraw', post_params
      expect(JSON.parse browser.last_response.body).to eq({'1' => 10, '2' => 10, '5' => 10, '10' => 10, '25' => 10, '50' => 10})
      expect($atm.current_deposit).to eq({'1' => 0, '2' => 0, '5' => 0, '10' => 0, '25' => 0, '50' => 0})
    end
  end

  context '400 calls' do
    after :each do
      expect(browser.last_response.status).to eq(400)
      expect(JSON.parse browser.last_response.body).to have_key('error')
    end

    it 'all existing bankbotes' do
      post_params = {amount: 0}
      browser.put '/api/v1/withdraw', post_params
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'amount does not have a valid value'
    end

    it 'exceed current balance' do
      post_params = {amount: 950}
      browser.put '/api/v1/withdraw', post_params
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'amount does not have a valid value'
      expect($atm.current_deposit).to eq({'1' => 10, '2' => 10, '5' => 10, '10' => 10, '25' => 10, '50' => 10})
    end

    it 'float' do
      post_params = {amount: 50.5}
      browser.put '/api/v1/withdraw', post_params
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'amount does not have a valid value'
    end

    it 'zero' do
      post_params = {amount: 0}
      browser.put '/api/v1/withdraw', post_params
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'amount does not have a valid value'
    end

    it 'negative' do
      post_params = {amount: -900.0}
      browser.put '/api/v1/withdraw', post_params
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'amount does not have a valid value'
    end

    it 'non-numeric' do
      post_params = {amount: 'ten'}
      browser.put '/api/v1/withdraw', post_params
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'amount is invalid, amount does not have a valid value'
    end

    it 'empty' do
      post_params = {}
      browser.put '/api/v1/withdraw', post_params
      expect(browser.last_response.body).to include 'amount is missing, amount is empty, amount does not have a valid value'
    end

    it 'nil value' do
      post_params = {amount: nil}
      browser.put '/api/v1/withdraw', post_params
    end
  end

  context '500 calls' do
    after :each do
      expect(browser.last_response.status).to eq(500)
      expect(JSON.parse browser.last_response.body).to have_key('error')
    end

    it 'consume one type' do
      post_params = {amount: 9}
      8.times do
        browser.put '/api/v1/withdraw', post_params
      end
      response = JSON.parse browser.last_response.body
      expect(response['error']).to eq 'Not enough banknotes. Please try another amount. Closest is 7'
      expect($atm.current_deposit).to eq({'1' => 2, '2' => 0, '5' => 3, '10' => 10, '25' => 10, '50' => 10})
    end
  end

end