defmodule TodoAppWeb.TodoLive.IndexTest do
  use TodoAppWeb.ConnCase
  import Phoenix.LiveViewTest

  alias TodoApp.Todos

  test "создание нового todo через LiveView", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/todos")

    # Открываем форму создания
    assert lv |> element("a", "New Todo") |> render_click() =~ "New Todo"

    # Заполняем и отправляем форму
    form_data = %{"todo" => %{"title" => "Тестовая задача", "is_done" => false}}
    {:ok, _, html} =
      lv
      |> form("#todo-form", form_data)
      |> render_submit()
      |> follow_redirect(conn, ~p"/todos")

    # Проверяем, что задача появилась в списке
    assert html =~ "Тестовая задача"
  end
end

defmodule TodoAppWeb.TodoLive.Show do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    todo = Todos.get_todo!(id)
    {:noreply, assign(socket, :todo, todo)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Todo Details
    </.header>

    <div class="todo-details">
      <p><strong>Title:</strong> <%= @todo.title %></p>
      <p><strong>Done?</strong> <%= @todo.is_done %></p>
      <p>
        <.link navigate={~p"/todos/#{@todo}/edit"}>Edit</.link> |
        <.link navigate={~p"/todos"}>Back</.link>
      </p>
    </div>

    <.list>
      <:item title="Title"><%= @todo.title %></:item>
      <:item title="Is done"><%= @todo.is_done %></:item>
    </.list>
    """
  end

  @impl true
  def handle_info({:todo_created, todo}, socket) do
    {:noreply, stream_insert(socket, :todos, todo)}
  end

  defp broadcast_todo_created(todo) do
    Phoenix.PubSub.broadcast(TodoApp.PubSub, "todos", {:todo_created, todo})
  end

  def item(assigns) do
    ~H"""
    <div><%= assigns.title %></div>
    """
  end
end
