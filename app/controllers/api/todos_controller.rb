module Api
  class TodosController < ApplicationController
    def create
      todo = Todo.new(todo_params)
      if todo.save
        render json: todo, status: :created
      else
        render json: { errors: todo.errors }, status: :unprocessable_entity
      end
    end

    def complete
      todo = Todo.find(params[:id])
      todo.update!(done: true)
      render json: todo, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    private

    def todo_params
      params.require(:todo).permit(:title)
    end
  end
end
