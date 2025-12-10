defmodule EsportsFan.Cache do
  @moduledoc """
  A simple caching layer for PandaScoreAPI.
  """

  @spec get(String.t(), (-> {:ok, any} | {:error, any})) :: nil
  def get(key, fallback) do
    ConCache.fetch_or_store(:pandascore_api, key, fallback)
  end
end
