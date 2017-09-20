require './app/models/atm.rb'
$atm = ATM.new

require './app/api/v1/atm/deposit.rb'
require './app/api/v1/atm/withdraw.rb'

get '/' do
  "ATM API"
end