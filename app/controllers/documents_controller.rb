require 'Winnower'
class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:user]

  respond_to :html

  def index
    @documents = Document.all
    respond_with(@documents)
  end

  def show
    respond_with(@document)
  end

  def user
    @user = User.find(params[:id])
    respond_with(@user)
  end

  def new
    @document = Document.new
    respond_with(@document)
  end

  def edit
  end

  def create
    @document = Document.new(document_params)
    @document.save
    respond_with(@document)
  end

  def update
    @document.update(document_params)
    respond_with(@document)
  end

  def destroy
    @document.destroy
    respond_with(@document)
  end

  def test
    redirect_to new_user_session_path if current_user.admin
    path = Rails.root.join("public", "uploads","document","file")
    @win = Winnower.new(15,10,path)
    @win.execute
  end

  private
    def set_document
      @document = Document.find(params[:id])
    end

    def document_params
      params[:document][:user_id] = current_user.id
      params.require(:document).permit(:title, :file, :md5, :user_id, :public, :abstract)
    end
end
