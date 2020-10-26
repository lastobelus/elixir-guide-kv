defmodule KV.BucketTest do
  @moduledoc """
  Tests for KV.Bucket
  """
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", "test-storing-value")
    assert KV.Bucket.get(bucket, "milk") == "test-storing-value"
  end

  test "deletes a value by key", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", "test-deleting-value")

    assert KV.Bucket.delete(bucket, "milk") == "test-deleting-value"
    assert KV.Bucket.get(bucket, "milk") == nil

    assert KV.Bucket.delete(bucket, "nonexistent") == nil
  end
end
