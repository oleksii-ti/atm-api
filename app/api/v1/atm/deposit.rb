class Deposit < Grape::API

  prefix 'api'
  version 'v1'
  format :json

  desc 'Deposit amount'
  params do
    $atm.current_deposit.each_key do |param|
      optional param, allow_blank: false, type: Float, values: ->(v) {v > 0 && v.to_f == v.to_i }
    end
    at_least_one_of(*$atm.current_deposit.keys)
  end

  post :deposit do
    params.each_pair do |key, value|
      $atm.current_deposit[key] += value.to_i
    end
  end

end