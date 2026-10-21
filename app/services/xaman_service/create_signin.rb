module XamanService
  class CreateSignin
    def self.call
      payload_client = Xaman.client.payloads

      payload_client.create(
        txjson: {
          TransactionType: "SignIn"
        }
      )
    end
  end
end
