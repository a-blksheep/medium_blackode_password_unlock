defmodule PasswordLockTest do
  use ExUnit.Case
  doctest PasswordLock

  @default_password "foo"
  @other_password "bar"

  setup do
    {:ok, pid} = PasswordLock.start_link(@default_password)
    {:ok, server: pid}
  end

  describe "unlock/2" do
    test "unlocks the password if the password is valid", %{server: pid} do
      assert :ok == PasswordLock.unlock(pid, @default_password)
    end

    test "returns an error if the password is invalid", %{server: pid} do
      assert {:error, _reason} = PasswordLock.unlock(pid, @other_password)
    end
  end

  describe "reset/2" do
    test "resets the password if the old password is valid", %{server: pid} do
      assert :ok == PasswordLock.reset(pid, {@default_password, @other_password})
      assert {:error, _reason} = PasswordLock.unlock(pid, @default_password)
      assert :ok == PasswordLock.unlock(pid, @other_password)
    end

    test "does not reset the password if the old one is invalid", %{server: pid} do
      assert {:error, _reason} = PasswordLock.reset(pid, {@other_password, @default_password})
      assert {:error, _reason} = PasswordLock.unlock(pid, @other_password)
      assert :ok = PasswordLock.unlock(pid, @default_password)
    end
  end
end
