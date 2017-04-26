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
    food_words  = ['Yakiniku', 'Sukiyaki', 'Horumon', 'Steakhouses', 'Yakitori']
    place_words = Postalcode.where(city:'大阪府').pluck(:address)
    # food_words  = ['焼肉']
    # place_words = ['大阪駅']

    place_words.each do |place_word|
      food_words.each do |food_word|
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
        if item['rating'] >= 4 and item['is_closed'] == false then #評価が4以上の店　厳選
          b_json = Yelp.client.business(item['id'], lang: 'ja').to_json
          b_data = JSON.parse(b_json)

          image_url = ""
          address   = ""

          image_url = item['image_url'].sub(/ms.jpg/, 'l.jpg') if item['image_url'].present?
          address   = item['location']['address'].join

          current_shop = {
            shop_provider:  'yelp',
            shop_id:        item['id'],
            name:           b_data['business']['name'],
            phone:          b_data['business']['phone'],
            review_count:   item['review_count'],
            rating:         item['rating'],
            rating_img_url: item['rating_img_url'],
            description:    b_data['business']['snippet_text'],
            url:            item['url'],
            image_url:      image_url,
            postal_code:    item['location']['postal_code'],
            city:           item['location']['city'],
            address:        address,
            latitude:       item['location']['coordinate']['latitude'],
            longitude:      item['location']['coordinate']['longitude']
          }

          if shop = Shop.find_by(shop_id: item['id'])
            puts shop.image_url
            shop.update(current_shop)
          else
            Shop.create(current_shop)
          end


          # Shop.where(shop_id: item['id']).first_or_create do |shop|
          #   shop.shop_provider  = 'yelp'
          #   shop.shop_id        = item['id']
          #   shop.name           = b_data['business']['name']
          #   shop.phone          = b_data['business']['phone']
          #   shop.review_count   = item['review_count']
          #   shop.rating         = item['rating']
          #   shop.rating_img_url = item['rating_img_url']
          #   shop.description    = b_data['business']['snippet_text']
          #   shop.url            = item['url']
          #
          #   # 画像末尾がms.jpgなら大きい画像のl.jpgに置換
          #   shop.image_url      = item['image_url'].sub(/ms.jpg/, 'l.jpg') if item['image_url'].present?
          #   shop.postal_code    = item['location']['postal_code']
          #   shop.city           = item['location']['city']
          #   shop.address        = item['location']['address'].join
          #   shop.latitude       = item['location']['coordinate']['latitude']
          #   shop.longitude      = item['location']['coordinate']['longitude']
          # end


        end
      end
    end

end
