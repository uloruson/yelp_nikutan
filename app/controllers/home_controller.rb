class HomeController < ApplicationController

  require 'json'

  def top
  end

  def index
    if params[:q] == "current"
      @q     = [params[:lati], params[:long]]
      @items = Shop.within_box(0.3, params[:lati], params[:long]).order(rating: :desc)
    elsif params[:q].present?
      @q     = Geocoder.coordinates(params[:q]) #検索ワードを緯度・経度へ変更
      @items = Shop.within_box(0.25, @q[0], @q[1]).order(rating: :desc) #480ｍ周辺
    else
      @items = Shop.all.order(rating: :desc)
    end

    @hash = Gmaps4rails.build_markers(@items) do |item, marker|
      marker.lat item.latitude
      marker.lng item.longitude
      marker.infowindow render_to_string(partial: "infowindow", locals: { infoitem: item})
      marker.json({title: item.shop_id})
    end
  end

  def insert
    food_words  = ['Yakiniku', '焼肉', 'Sukiyaki', 'ステーキ', 'Yakitori']
    place_words = Postalcode.where(city:'大阪府').pluck(:address)
    # food_words  = ['焼肉']
    # place_words = ['大阪駅']

    food_words.each do |food_word|
      place_words.each do |place_word|
        yelp_insert(food_word,place_word)
      end
    end
    # redirect_to :action => "index"
  end

  private
    def yelp_insert(food_key, place_key)
      parameters = { term: food_key, limit: 10 }
      data = Yelp.client.search(place_key, parameters).to_json
      json = JSON.parse(data)

      json['businesses'].each do |item|
        if item['rating'] >= 4 and b_data['business']['is_closed'] == false then #評価が4以上の店　厳選
          Shop.find_or_create_by(shop_id: item['id']) do |shop|
            b_json = Yelp.client.business(item['id'], lang: 'ja').to_json
            b_data = JSON.parse(b_json)

            shop.shop_provider  = 'yelp'
            shop.shop_id        = item['id']
            shop.name           = b_data['business']['name']
            shop.phone          = b_data['business']['phone']
            shop.rating         = item['rating']
            shop.rating_img_url = item['rating_img_url']
            shop.description    = b_data['business']['snippet_text']
            shop.url            = item['url']
            shop.image_url      = item['image_url']
            shop.postal_code    = item['location']['postal_code']
            shop.city           = item['location']['city']
            shop.address        = item['location']['address'].join
            shop.latitude       = item['location']['coordinate']['latitude']
            shop.longitude      = item['location']['coordinate']['longitude']
            shop.save!
          end
        end
      end
    end

end
