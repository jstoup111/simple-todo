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

    private

    def todo_params
      params.require(:todo).permit(:title)
    end

    def complete
      head :not_implemented
    end
  end
end
