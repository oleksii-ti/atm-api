require 'bundler'
Bundler.require(:default, :test)
require './app.rb'

describe Deposit do
  def deposit
    Deposit
  end

  let!(:browser) { Rack::Test::Session.new(Rack::MockSession.new(deposit)) }

  after :each do
    $atm.reset_current_deposit()
  end

  context '201 calls' do
    after :each do
      expect(browser.last_response.status).to eq(201)
    end

    it 'positive value' do
      post_params = {'1' => 5}
      browser.post '/api/v1/deposit', post_params
      expect($atm.current_deposit['1']).to eq 15
    end

    it 'few values' do
      post_params = {'1' => 5, '10' => 1}
      browser.post '/api/v1/deposit', post_params
      expect($atm.current_deposit['1']).to eq 15
      expect($atm.current_deposit['10']).to eq 11
    end
  end

  context '400 calls' do
    after :each do
      expect(browser.last_response.status).to eq(400)
      expect(JSON.parse browser.last_response.body).to have_key('error')
    end

    it 'few values with one incorrect' do
      post_params = {'1' => 5, '10' => 0}
      browser.post '/api/v1/deposit', post_params
    end

    it 'incorrect banknote' do
      post_params = {'31' => 5}
      browser.post '/api/v1/deposit', post_params
    end

    it 'negative value' do
      post_params = {'1' => -9}
      browser.post '/api/v1/deposit', post_params
    end

    it 'zero' do
      post_params = {'1' => 0}
      browser.post '/api/v1/deposit', post_params
    end

    it 'float value' do
      post_params = {'1' => 5.5}
      browser.post '/api/v1/deposit', post_params
      expect(browser.last_response.body).to include '1 does not have a valid value'

    end

    it 'non-numeric' do
      post_params = {'1' => 'five'}
      browser.post '/api/v1/deposit', post_params
      expect(browser.last_response.body).to include '1 is invalid, 1 does not have a valid value'

    end

    it 'empty' do
      post_params = {}
      browser.post '/api/v1/deposit', post_params
      expect(browser.last_response.body).to include 'one parameter must be provided'
    end

    it 'nil value' do
      post_params = {'1': nil}
      browser.post '/api/v1/deposit', post_params
    end
  end

  context '500 calls' do
    it 'few banknotes with one incorrect' do
      post_params = {'1' => 5, '11' => 5}
      browser.post '/api/v1/deposit', post_params
    end
  end

end