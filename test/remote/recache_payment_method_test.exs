defmodule Remote.RecachePaymentMethodTest do
  require Logger
  use Remote.Environment.Case

  test "invalid credentials" do
    bogus_env = Environment.new("invalid", "credentials")
    { :error, message } = Spreedly.recache_payment_method(bogus_env, "some_card_token", 111)
    assert message =~ "Unable to authenticate"
  end

  test "non existent" do
    { :error, reason } = Spreedly.recache_payment_method(env(), "non_existent_card", 111)
    assert reason =~ "Unable to find the specified payment method."
  end

  test "successfully recache" do
    {:ok, add_trans } = Spreedly.add_credit_card(env(), card_deets())
    assert add_trans.payment_method.storage_state == "cached"
    {:ok, retain_trans} = Spreedly.retain_payment_method(env(), add_trans.payment_method.token)
    assert retain_trans.payment_method.storage_state == "retained"
    {:ok, recache_trans} = Spreedly.recache_payment_method(env(), retain_trans.payment_method.token, 111)
    assert recache_trans.succeeded == true
    assert recache_trans.payment_method.token == retain_trans.payment_method.token
    assert recache_trans.transaction_type == "RecacheSensitiveData"
  end
end
