class ResourceTextbooksController < ApplicationController
  include JSONAPI::ActsAsResourceController

  # skip_before_filter :ensure_valid_accept_media_type, only: [:kortext_search, :click]

  # Scrapes the Kortext store and returns results as JSON
  def kortext_search
    @q = view_context.escape_javascript(params[:query].gsub(" ", "+"))
    url = "https://www.kortextstore.com/search?q=#{@q}"
    doc = Nokogiri::HTML(open(url))
    items = []
    doc.css(".product-item").each do |item|
      title = item.at_css("h3").text
      id = item['data-productid']
      img = item.at_css(".product-image img")['src']
      link = item.at_css(".product-image a")['href']
      # items << [title, id, img]
      items << {name: title, id: id, img: img, link: "https://www.kortextstore.com#{link}"}
    end
    render json: items.to_json
    # render text: params[:query].gsub(" ", "+")
  end

  # Record a click on a resource link
  def click
    @resource_textbook = ResourceTextbook.find(params[:id])
    @user = User.find(params[:user_id])
    KortextClick.create!(
      user: @user,
      resource_textbook: @resource_textbook,
      emails: @user.email_accounts.collect{|a| a.email}.join(","),
      kortext_link: @resource_textbook.kortext_link
    )

    redirect_to @resource_textbook.kortext_link + "?oslr=1"
  end
end
