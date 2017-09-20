class Withdraw < Grape::API

  prefix 'api'
  version 'v1'
  format :json

  desc 'Withdraw amount'
  params do
   requires :amount,
            allow_blank: false,
            type: Float,
            values: ->(v) {v <= $atm.current_deposit.map { |k, v| k.to_i * v }.reduce(:+) &&
                           v.to_f == v.to_i &&
                           v > 0 }
  end


  put :withdraw do
    withdrawn_notes = {}
    withdrawn_amount = 0
    $atm.current_deposit.keys.sort.reverse.each do |note|
      break if params[:amount] == withdrawn_amount
      max_notes = ((params[:amount] - withdrawn_amount) / note.to_i).to_i
      actual_notes = [$atm.current_deposit[note], max_notes].min
      if actual_notes > 0
        withdrawn_amount += actual_notes * note.to_i
        withdrawn_notes[note] = actual_notes.to_i
      end
    end

    error! error: "Not enough banknotes. Please try another amount. Closest is #{withdrawn_amount}" if withdrawn_amount < params[:amount]

    $atm.current_deposit.merge!(withdrawn_notes) {|key,val1,val2| val1-val2}
    withdrawn_notes
  end

end