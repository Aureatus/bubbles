defmodule BubblesWeb.BubbleLive do
  use BubblesWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-max h-max">
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
    :timer.send_interval(3000, self(), :tick)
    :timer.send_interval(300, self(), :auto_pop)

    assigns = %{bubbles: create_empty_bubbles(), score: 0, auto_reset: false, auto_pop: false}

    {:ok, assign(socket, assigns)}
  end

  def handle_event("pop_bubble", value, socket) do
    column = String.to_integer(value["column"])
    row = String.to_integer(value["row"])

    selected? =
      socket.assigns[:bubbles]
      |> Enum.at(column)
      |> Enum.at(row)

    case selected? do
      true ->
        {:noreply, socket}

      false ->
        socket =
          update(
            socket,
            :bubbles,
            &update_bubble(&1, column, row)
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
          create_empty_bubbles()
        end
      )

    {:noreply, socket}
  end

  def handle_event("enable-auto_reset", _, socket) do
    case socket.assigns[:score] do
      n when n < 3 ->
        {:noreply, socket}

      n when n >= 3 ->
        socket =
          update(
            socket,
            :auto_reset,
            fn _ -> true end
          )
          |> update(:score, fn x -> x - 3 end)

        {:noreply, socket}
    end
  end

  def handle_event("enable-auto_pop", _, socket) do
    case socket.assigns[:score] do
      n when n < 10 ->
        {:noreply, socket}

      n when n >= 10 ->
        socket =
          update(
            socket,
            :auto_pop,
            fn _ -> true end
          )
          |> update(:score, fn x -> x - 10 end)

        {:noreply, socket}
    end
  end

  def handle_info(:tick, socket) do
    auto_reset? =
      socket.assigns[:auto_reset]

    if auto_reset? do
      socket =
        update(
          socket,
          :bubbles,
          fn _ ->
            create_empty_bubbles()
          end
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:auto_pop, socket) do
    auto_pop? =
      socket.assigns[:auto_pop]

    if auto_pop? do
      [rand1, rand2] = 1..2 |> Enum.map(fn _ -> Enum.random(1..10) end)

      socket =
        update(
          socket,
          :bubbles,
          &update_bubble(&1, rand1, rand2)
        )
        |> update(:score, &(&1 + 1))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp update_bubble(bubbles, column, row) do
    List.update_at(
      bubbles,
      column,
      &List.update_at(&1, row, fn _ -> true end)
    )
  end

  defp create_empty_bubbles do
    List.duplicate(false, 10) |> Enum.map(fn _x -> List.duplicate(false, 10) end)
  end
end
