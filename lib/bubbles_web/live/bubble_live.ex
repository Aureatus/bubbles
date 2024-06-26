defmodule BubblesWeb.BubbleLive do
  use BubblesWeb, :live_view
  alias Bubbles.Bubbles

  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-max h-max">
      <.perk_section
        score={assigns.score}
        auto_reset={assigns.auto_reset}
        auto_pop={assigns.auto_pop}
        pop_radius_increase={assigns.pop_radius_increase}
      />
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

    assigns = %{
      bubbles: Bubbles.generate(10),
      score: 0,
      auto_reset: false,
      auto_pop: false,
      pop_radius_increase: false
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_event("pop_bubble", value, socket) do
    column = String.to_integer(value["column"])
    row = String.to_integer(value["row"])

    bubbles = socket.assigns[:bubbles]

    if socket.assigns[:pop_radius_increase] do
      cols =
        Enum.filter([column - 1, column, column + 1], fn num ->
          num >= 0 && num < Enum.count(bubbles)
        end)

      rows =
        Enum.filter([row - 1, row, row + 1], fn num -> num >= 0 && num < Enum.count(bubbles) end)

      temp_list =
        for col <- cols, row <- rows do
          selected? =
            bubbles
            |> Enum.at(col)
            |> Enum.at(row)

          if selected?, do: [], else: [col, row]
        end
        |> Enum.filter(fn x -> !Enum.empty?(x) end)

      new_bubbles =
        Enum.reduce(temp_list, bubbles, fn x, acc ->
          Bubbles.update_bubble(acc, Enum.at(x, 0), Enum.at(x, 1))
        end)

      socket =
        update(socket, :bubbles, fn _ -> new_bubbles end)
        |> update(:score, &(&1 + Enum.count(temp_list)))

      {:noreply, socket}
    else
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
              &Bubbles.update_bubble(&1, column, row)
            )
            |> update(:score, &(&1 + 1))

          {:noreply, socket}
      end
    end
  end

  def handle_event("reset_bubbles", _, socket) do
    socket =
      update(
        socket,
        :bubbles,
        fn _ ->
          Bubbles.generate(10)
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

  def handle_event("enable-pop_radius_increase", _, socket) do
    case socket.assigns[:score] do
      n when n < 20 ->
        {:noreply, socket}

      n when n >= 20 ->
        socket =
          update(
            socket,
            :pop_radius_increase,
            fn _ -> true end
          )
          |> update(:score, fn x -> x - 20 end)

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
            Bubbles.generate(10)
          end
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:auto_pop, socket) do
    #  Maybe withIndex enum function can help do this more efficiently?
    auto_pop? =
      socket.assigns[:auto_pop]

    bubbles = socket.assigns[:bubbles]
    all_popped? = Enum.all?(bubbles, fn column -> Enum.all?(column) end)

    transformed_bubbles =
      Enum.with_index(bubbles)
      |> Enum.map(fn {bbl, index} -> {Enum.with_index(bbl), index} end)

    filtered_column_bubbles =
      transformed_bubbles
      |> Enum.filter(fn {val, _index} -> !Enum.all?(val, fn {bool, _index} -> bool end) end)

    filtered_row_bubbles =
      filtered_column_bubbles
      |> Enum.map(fn {val, index} -> {Enum.filter(val, fn {bool, _} -> !bool end), index} end)

    if auto_pop? and !all_popped? do
      {column_index, row_index} = Bubbles.get_rand(filtered_row_bubbles)

      socket =
        update(
          socket,
          :bubbles,
          &Bubbles.update_bubble(&1, column_index, row_index)
        )
        |> update(:score, &(&1 + 1))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
