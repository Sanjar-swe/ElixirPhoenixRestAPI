defmodule TodoAppWeb.TodoLive.Index do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(TodoApp.PubSub, "todos")
    {:ok, stream(socket, :todos, Todos.list_todos())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case socket.assigns.live_action do
      :new ->
        {:noreply,
         socket
         |> assign(:page_title, "New Todo")
         |> assign(:todo, %TodoApp.Todos.Todo{})}

      :edit ->
        todo = Todos.get_todo!(params["id"])
        {:noreply,
         socket
         |> assign(:page_title, "Edit Todo")
         |> assign(:todo, todo)}

      :index ->
        {:noreply, assign(socket, :page_title, "Listing Todos")}
    end
  end

  @impl true
def handle_event("save", %{"todo" => todo_params}, socket) do
  case Todos.create_todo(todo_params) do
    {:ok, _todo} ->
      {:noreply,
       socket
       |> put_flash(:info, "Todo created successfully")
       |> push_navigate(to: ~p"/todos")}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, changeset: changeset)}
  end
end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Todos
      <:actions>
        <.link patch={~p"/todos/new"}>
          <.button>New Todo</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="todos"
      rows={@streams.todos}
      row_click={fn {_id, todo} -> JS.navigate(~p"/todos/#{todo}") end}
    >
      <:col :let={{_id, todo}} label="Title"><%= todo.title %></:col>
      <:col :let={{_id, todo}} label="Is done"><%= todo.is_done %></:col>
      <:action :let={{_id, todo}}>
        <.link patch={~p"/todos/#{todo}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, todo}}>
        <.link
          phx-click={JS.push("delete", value: %{id: todo.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="todo-modal" show on_cancel={JS.patch(~p"/todos")}>
      <.live_component
        module={TodoAppWeb.TodoLive.FormComponent}
        id={@todo.id || :new}
        title={@page_title}
        action={@live_action}
        todo={@todo}
        patch={~p"/todos"}
      />
    </.modal>
    """
  end
end
