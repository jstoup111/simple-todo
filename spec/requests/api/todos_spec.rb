require 'rails_helper'

RSpec.describe "Api::Todos", type: :request do
  describe "POST /api/todos" do
    context "with valid params" do
      it "returns 201 with the todo JSON and persists the record" do
        expect {
          post "/api/todos", params: { todo: { title: "Buy milk" } }, as: :json
        }.to change(Todo, :count).by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["id"]).to be_a(Integer)
        expect(body["title"]).to eq("Buy milk")
        expect(body["done"]).to eq(false)
        expect(body["created_at"]).to be_present
        expect(body["updated_at"]).to be_present
      end
    end
  end
end
