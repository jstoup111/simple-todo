require 'rails_helper'

RSpec.describe "Todo factory" do
  it "builds a valid todo" do
    todo = build(:todo)
    expect(todo).to be_valid
    expect(todo.title).to eq("Buy milk")
    expect(todo.done).to eq(false)
  end
end
