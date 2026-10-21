module XamanService
  class CreatePayment
    attr_reader :sender_address, :receiver_address, :amount, :token_rate, :user_token

    def self.call sender_address:, receiver_address:, amount:, token_rate:, user_token: nil
      new(sender_address, receiver_address, amount, token_rate, user_token).call
    end

    def initialize(sender_address, receiver_address, amount, token_rate, user_token)
      @sender_address = sender_address
      @receiver_address = receiver_address
      @amount = amount
      @token_rate = token_rate
      @user_token = user_token
    end

    def call
      validate_inputs!

      payload_client = Xaman.client.payloads
      txjson = {
        TransactionType: "Payment",
        Account: sender_address,
        Destination: receiver_address,
        Amount: build_amount_payload
      }

      options = { submit: true, expire: 5 }

      payload_client.create(
        txjson: txjson,
        options: options,
        user_token: user_token
      )
    end

    private
    def validate_inputs!
      raise ArgumentError, "Amount must be greater than 0" if amount <= 0
      raise ArgumentError, "Sender address is required" if sender_address.blank?
      raise ArgumentError, "Receiver address is required" if receiver_address.blank?
      raise ArgumentError, "Token rate is required" if token_rate.blank?
    end

    def build_amount_payload
      if token_rate.symbol.upcase == "XRP"
        (amount * 1_000_000).to_i.to_s
      else
        if token_rate.issuer_address.blank?
          raise ArgumentError, "Issuer address is missing for token #{token_rate.symbol}"
        end

        {
          currency: token_rate.symbol.upcase,
          value: amount.to_s,
          issuer: token_rate.issuer_address
        }
      end
    end
  end
end
