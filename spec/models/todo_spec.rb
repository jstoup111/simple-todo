require 'rails_helper'

RSpec.describe Todo, type: :model do
  it "is invalid with a blank title" do
    todo = Todo.new(title: "")
    expect(todo).not_to be_valid
    expect(todo.errors[:title]).to include("can't be blank")
  end

  it "is valid with a title" do
    todo = Todo.new(title: "Buy milk")
    expect(todo).to be_valid
  end
end
