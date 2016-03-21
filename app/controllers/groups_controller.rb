class GroupsController < ApplicationController

   before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

   def index                          #首頁  用來列出所有的討論版，可以選擇各個單版
    @groups = Group.all
   end

   def new                            #新增頁面  裡面會有表單，填完以後可以送出
   @group = Group.new
   end

   def show                          #各個討論版專屬頁面  顯示討論版版名跟簡介
     @group = Group.find(params[:id])
     @posts = @group.posts
   end

   def edit                          #修改頁面  裡面會有表單呈現現有資料來，填完資料後可以送出
     @group = current_user.groups.find(params[:id])
   end

   def create                        #產生資料  new送出來的表單到create這個action，新增一筆資料
     @group = current_user.groups.create(group_params)

     if @group.save
       current_user.join!(@group)
       redirect_to groups_path
     else
       render :new
     end
   end

   def update                       #更新資料  edit送出來的表單可以到update這個 action，更新該筆資料
      @group = current_user.groups.find(params[:id])

      if @group.update(group_params)
        redirect_to groups_path, notice: "修改討論版成功"
      else
        render :edit
      end
   end

   def destroy                     #刪除資料  送出刪除請求，刪除該筆資料
       @group = current_user.groups.find(params[:id])
       @group.destroy
       redirect_to groups_path, alert: "討論版已刪除"
   end

   def join
     @group = Group.find(params[:id])

     if !current_user.is_member_of?(@group)
       current_user.join!(@group)
       flash[:notice] = "加入本討論版成功！"
     else
       flash[:warning] = "你已經是本討論版成員了！"
     end

     redirect_to group_path(@group)
   end

   def quit
     @group = Group.find(params[:id])

     if current_user.is_member_of?(@group)
       current_user.quit!(@group)
       flash[:alert] = "已退出本討論版！"
     else
       flash[:warning] = "你不是本討論版成員，怎麼退出 XD"
     end

     redirect_to group_path(@group)
   end

   private

   def group_params
     params.require(:group).permit(:title, :description)
   end

end
