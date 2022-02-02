defmodule Katai.SignatureTest do
  use KataiWeb.ConnCase, async: true
  use Plug.Test

  test "validate_signature" do
    public_key = ExPublicKey.loads!(public_key())

    signature = create_signature()

    msg = %{"message" => "hola"}
    body = "#{Jason.encode!(msg)}"

    {:ok, true} =
      KataiWeb.Plug.SignatureValidation.validate_signature(signature, body, public_key)
  end

  test "validate_hash" do
    {:ok, hash, ts} = create_hash()

    msg =
      %{
        "message" => "letter"
      }
      |> Jason.encode!()

    {:ok, success} =
      KataiWeb.Plug.SignatureValidation.validate_hash_from_conn(
        ts,
        "localhost",
        "/test_sign",
        msg,
        hash
      )

    assert success == "valid"
  end

  test "validate_invalid_hash" do
    {:ok, hash, ts} = create_hash()

    msg =
      %{
        "message" => "letter"
      }
      |> Jason.encode!()

    {:error, error} =
      PrimeTimeWeb.Plug.SignatureValidation.validate_hash_from_conn(
        ts,
        "localhost",
        "/test_sign",
        msg,
        hash
      )

    assert error == "invalid request"
  end

  @spec public_key() :: String.t()
  def public_key do
    """
    -----BEGIN RSA PUBLIC KEY-----
    MIIBCgKCAQEAkrQZhxSYFdUbK9jLml8fXYG/fRFN+tmJmV03+KTXYBZ0+RzZoP3o
    iDJu0Xp8ZqUN67DoIlO5qiQ86WIO8y7CMiTXEs/I1eVjw9mSDxw/9F7cF9lpxKYy
    JOdZZyWOFKe3oVfrpxXG1FUqcSKnU6PV4g/5yBg77BkbInqKmVP21w0YvLGAr9pu
    mCWXCKNnGG4U2hlnMioZywyLl8W4l0m/g8eCruv6yQJ9IaDZZn9PoCsabGU7SU/+
    webVoI3z34PctvK7TaG91RvPHvAkVLJcolDY7ToCnJzNYbP36Un3Womo6nk+XPRd
    yoWBPdu3BzxwFcprhlMGbz+kWi7vOyJDJwIDAQAB
    -----END RSA PUBLIC KEY-----
    """
  end

  @spec private_key() :: String.t()
  def private_key do
    """
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCStBmHFJgV1Rsr
    2MuaXx9dgb99EU362YmZXTf4pNdgFnT5HNmg/eiIMm7RenxmpQ3rsOgiU7mqJDzp
    Yg7zLsIyJNcSz8jV5WPD2ZIPHD/0XtwX2WnEpjIk51lnJY4Up7ehV+unFcbUVSpx
    IqdTo9XiD/nIGDvsGRsieoqZU/bXDRi8sYCv2m6YJZcIo2cYbhTaGWcyKhnLDIuX
    xbiXSb+Dx4Ku6/rJAn0hoNlmf0+gKxpsZTtJT/7B5tWgjfPfg9y28rtNob3VG88e
    8CRUslyiUNjtOgKcnM1hs/fpSfdaiajqeT5c9F3KhYE927cHPHAVymuGUwZvP6Ra
    Lu87IkMnAgMBAAECggEAOUxokA7mG9jhRO3nEANJH992aCXjHC/tA16aZt4TVO9Q
    fp/bDHs/YDq6d8zsW7bpyf2NnSKwaJjAxbLL/gVsSeODsVBAs/JlVfBbkNVK0Wpf
    cl0zZ2A2Q52smJHdfYnIOhc57keeIf6llgyf6BYcirAMsi9s8BkaNQxBqANYbMOU
    XHvd1HiqMC7rapQtuAp0FKbQMzYwsoOf7p9oS5XLdWyy6b2l1MDcH5wERc/ZdKjJ
    7fJv+kLXOjAglyTeg8FXoaNKVKA4UStT+J09/YGXm/m4XXDSYQkPHHNyXbeR5t3l
    N6JmQQjUZi0LqnHxOzIyDeBKGONLdXSobzS1KqQgYQKBgQDCPrcyqpJn9cq+oIXZ
    4PkBL8gag4xBHbWoyOSx/Qg9zpMl2Sb5JzuJ/ozSj/5dJLzJRmS6TfM1pXzfqUrh
    kLR8F9Ot6/L+mq40Q59kCQh4f6rVPt3b4tt7adHS8Nc+nNk3DQOupEJQDdgW02Vl
    VLZGCzW6JvERYbY6lIX/ub1ydwKBgQDBWA+fxt58qNg0O4OmjrIh/GX0FNrLYOWw
    MJEq0R8VCvunEcBABnZIEoFALSSDgQoE88Cd+nG0Aht2vP2WN5GbN/hRa55Gj2li
    DPWIz8NnKj7/uBG5byl7HjZYmtuZBdwWzJIyJWrcaUNf9bFCX8pFCzUcp0Rj6xoA
    T6UICOqw0QKBgDPBbiKr3DKjBRBhyQhSr0YnqxOVdWtsNRjx3i2mk+mT/xUYlQ/R
    6kVMc80u3MGIplyiyvfxCRqEK4+UlgUf/1cJKjevJKG+KSh31CJdXcptieEjzQ1n
    lr99ZJDl5xQhyqamaxK/ZYPbDHaYgO3M8nwbRIeDFLxi4qEdLc8DeHzlAoGAInay
    AkcOraXjNBxPsUbKVeiJu+JjxdD14Fwn5Dv2kGeux+8QF9mPB/XUeD4TviUoRg21
    DfPwhKfDgXzarwYkvEhTyR+nzOgPXtz0f3iZWjBbnnWPI0C/YiTWhyDDeBllS+MX
    RD0LOVLCIb7H5A7zHS+MPhlKxYzIy7lmr3H3c6ECgYEAqGks6Qe2oe+wJikg/v9H
    +YsMx/L8nNwwaj3CTRw2fsxt7yQPfzVj/4/9gzNq8sTT/Zf3dimt+DVWnskZTzh1
    Gfq7WJm64WHytl4KKJDGZ3Y9PHegj033OZvzwz/gNyDiMkahSoKfYhXHXVgvmYJR
    YAcQej+ebOOcIjj0Rf7DscI=
    -----END PRIVATE KEY-----
    """
  end

  @spec create_signature() :: any()
  def create_signature do
    private_key = ExPublicKey.loads!(private_key())

    msg = %{"name_first" => "Saul", "name_last" => "Perez"}
    msg_serialized = "#{Poison.encode!(msg)}"
    {:ok, signature} = ExPublicKey.sign(msg_serialized, private_key)
    Base.encode64(signature)
  end

  @spec create_hash() :: {:ok, String.t()}
  def create_hash() do
    msg = %{
      "card" => "9900006512347508"
    }

    ts = generate_time_stamp(DateTime.utc_now())
    msg = "#{ts}localhost/card_holders/cards/validate_body#{Poison.encode!(msg)}"
    hash = :crypto.hash(:sha256, msg) |> Base.encode64()
    {:ok, hash, ts}
  end

  @spec generate_time_stamp(DateTime.t()) :: integer
  def generate_time_stamp(date) do
    date |> DateTime.to_unix()
  end
end
