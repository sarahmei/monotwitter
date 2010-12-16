class StatusUpdatesController < ApplicationController
  # GET /status_updates
  # GET /status_updates.xml
  def index
    @status_updates = StatusUpdate.order('post_date desc')
    query           = params['q']
    url             = "http://search.twitter.com/search.json?q=#{query}"

    http            = EM::HttpRequest.new(url).get

    http.callback do
      StatusUpdate.delete_all
      results = JSON.parse(http.response)["results"]
      results.each do |result|
        status_update =
          StatusUpdate.find_or_create_by_twitter_guid(result["id_str"])

          lang = result["iso_language_code"]
          message = result['text']

          translate_url = "https://www.googleapis.com/language/translate/v2?key=AIzaSyCx0e_YdOi5wcrUES0c-1RaK9eXVoIs9IY&source=#{lang}&target=en&q=#{URI.encode(message)}"
          goog = EM::HttpRequest.new(translate_url).get

          goog.callback {
            message = JSON.parse(goog.response)["data"]["translations"].first["translatedText"]
            puts message.to_yaml
            status_update.update_attributes(
              :text         => message,
              :twitter_name => result["from_user"],
              :post_date    => Time.parse(result["created_at"]),
              :image_url    => result["profile_image_url"],
              :language_code => result["iso_language_code"]
            )
          }

          goog.errback{
            status_update.update_attributes(
              :text         => result['text'],
              :twitter_name => result["from_user"],
              :post_date    => Time.parse(result["created_at"]),
              :image_url    => result["profile_image_url"],
              :language_code => result["iso_language_code"]
            )
          }
        end
    end
    http.errback { puts "totally failed" }


    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @status_updates }
    end
  end

  # GET /status_updates/1
  # GET /status_updates/1.xml
  def show
    @status_update = StatusUpdate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @status_update }
    end
  end

  # GET /status_updates/new
  # GET /status_updates/new.xml
  def new
    @status_update = StatusUpdate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @status_update }
    end
  end

  # GET /status_updates/1/edit
  def edit
    @status_update = StatusUpdate.find(params[:id])
  end

  # POST /status_updates
  # POST /status_updates.xml
  def create
    @status_update = StatusUpdate.new(params[:status_update])

    respond_to do |format|
      if @status_update.save
        format.html { redirect_to(@status_update, :notice => 'Status update was successfully created.') }
        format.xml { render :xml => @status_update, :status => :created, :location => @status_update }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @status_update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /status_updates/1
  # PUT /status_updates/1.xml
  def update
    @status_update = StatusUpdate.find(params[:id])

    respond_to do |format|
      if @status_update.update_attributes(params[:status_update])
        format.html { redirect_to(@status_update, :notice => 'Status update was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @status_update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /status_updates/1
  # DELETE /status_updates/1.xml
  def destroy
    @status_update = StatusUpdate.find(params[:id])
    @status_update.destroy

    respond_to do |format|
      format.html { redirect_to(status_updates_url) }
      format.xml { head :ok }
    end
  end
end
