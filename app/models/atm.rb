class ATM

  attr_reader :current_deposit

  def initialize
    @current_deposit = {'1' => 10, '2' => 10, '5' => 10, '10' => 10, '25' => 10, '50' => 10}
  end

  def reset_current_deposit
    @current_deposit = {'1' => 10, '2' => 10, '5' => 10, '10' => 10, '25' => 10, '50' => 10}
  end
end