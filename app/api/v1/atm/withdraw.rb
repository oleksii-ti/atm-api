class Withdraw < Grape::API

  prefix 'api'
  version 'v1'
  format :json

  desc 'Withdraw amount'
  params do
   requires :amount,
            allow_blank: false,
            type: Float,
            values: ->(v) {v <= $atm.current_amount &&
                           v.to_f == v.to_i &&
                           v > 0 }
  end


  put :withdraw do
    withdrawn_notes = {}
    withdrawn_amount = 0
    closest_availiable = nil
    banknotes = $atm.current_deposit.keys.map(&:to_i).sort.reverse.map(&:to_s)

    while withdrawn_amount < params[:amount] && !banknotes.empty?
      withdrawn_notes = {}
      withdrawn_amount = 0
      banknotes.each do |note|
        max_notes = ((params[:amount] - withdrawn_amount) / note.to_i).to_i
        actual_notes = [$atm.current_deposit[note], max_notes].min
        if actual_notes > 0
          withdrawn_amount += actual_notes * note.to_i
          withdrawn_notes[note] = actual_notes.to_i
        end
        break if params[:amount] == withdrawn_amount
      end

      closest_availiable = withdrawn_amount if closest_availiable.nil?
      banknotes.shift
    end

    error! error: "Not enough banknotes. Please try another amount. Closest is #{closest_availiable}" if withdrawn_amount < params[:amount]

    $atm.current_deposit.merge!(withdrawn_notes) {|key,val1,val2| val1-val2}
    withdrawn_notes
  end

end