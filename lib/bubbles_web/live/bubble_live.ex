defmodule BubblesWeb.BubbleLive do
  use BubblesWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-max h-max">
      <.header>Score: <%= @score %></.header>
      <.button phx-click="reset_bubbles" class="w-full">Reset bubbles</.button>
      <div class="grid grid-cols-10 grid-rows-10 border-2 w-fit h-fit">
        <%= for {c, cindex} <- Enum.with_index(@bubbles) do %>
          <%= for {r, rindex} <- Enum.with_index(c) do %>
            <button
              phx-click="pop_bubble"
              phx-value-column={cindex}
              phx-value-row={rindex}
              class="w-16 h-16 text-center m-2 text-l border-2 rounded-full select-none"
            >
              <%= unless r do
                "pop"
              else
                "popped"
              end %>
            </button>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    bubbles = List.duplicate(false, 10) |> Enum.map(fn _x -> List.duplicate(false, 10) end)
    {:ok, assign(socket, %{bubbles: bubbles, score: 0})}
  end

  def handle_event("pop_bubble", value, socket) do
    selected? =
      socket.assigns[:bubbles]
      |> Enum.at(String.to_integer(value["column"]))
      |> Enum.at(String.to_integer(value["row"]))

    case selected? do
      true ->
        {:noreply, socket}

      false ->
        socket =
          update(
            socket,
            :bubbles,
            &merge_bubble_changes(&1, value)
          )
          |> update(:score, &(&1 + 1))

        {:noreply, socket}
    end
  end

  def handle_event("reset_bubbles", _, socket) do
    socket =
      update(
        socket,
        :bubbles,
        fn _ ->
          List.duplicate(false, 10) |> Enum.map(fn _x -> List.duplicate(false, 10) end)
        end
      )

    {:noreply, socket}
  end

  defp merge_bubble_changes(bubbles, value) do
    List.update_at(
      bubbles,
      value["column"] |> String.to_integer(),
      &List.update_at(&1, value["row"] |> String.to_integer(), fn _ -> true end)
    )
  end
end
