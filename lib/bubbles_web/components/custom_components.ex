defmodule BubblesWeb.CustomComponents do
  import BubblesWeb.CoreComponents
  use Phoenix.Component

  attr :score, :integer, required: true
  attr :auto_reset, :boolean, required: true
  attr :auto_pop, :boolean, required: true
  attr :pop_radius_increase, :boolean, required: true
  attr :rest, :global

  def perk_section(assigns) do
    ~H"""
    <div {@rest}>
      <.header>Score: <%= @score %></.header>
      <.button phx-click="reset_bubbles" class="w-full">
        Reset bubbles
      </.button>
      <.button
        disabled={@score < 3 || @auto_reset}
        phx-click="enable-auto_reset"
        class="disabled:opacity-5"
      >
        Purchase auto reset
      </.button>
      <.button
        disabled={@score < 10 || @auto_pop}
        phx-click="enable-auto_pop"
        class="disabled:opacity-5"
      >
        Purchase auto pop
      </.button>
      <.button
        disabled={@score < 20 || @pop_radius_increase}
        phx-click="enable-pop_radius_increase"
        class="disabled:opacity-5"
      >
        Purchase pop radius increase
      </.button>
    </div>
    """
  end
end
