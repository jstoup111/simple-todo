require 'rails_helper'

RSpec.describe "Api::Todos", type: :request do
  describe "POST /api/todos" do
    context "with a blank title" do
      it "returns 422 with errors and does not persist the record" do
        expect {
          post "/api/todos", params: { todo: { title: "" } }, as: :json
        }.not_to change(Todo, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]["title"]).to include("can't be blank")
      end
    end

    context "with extra params (mass assignment)" do
      it "returns 201 and ignores done and unknown keys" do
        post "/api/todos", params: { todo: { title: "ok", done: true, admin: true } }, as: :json

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["done"]).to eq(false)
      end
    end

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
