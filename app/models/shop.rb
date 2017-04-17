class Shop < ActiveRecord::Base

  reverse_geocoded_by :latitude, :longitude

  class << self
    def within_box(distance, latitude, longitude)
      distance = distance # 単位はマイル
      center_point = [latitude, longitude] # 緯度経度
      box = Geocoder::Calculations.bounding_box(center_point, distance)
      self.within_bounding_box(box)
    end
  end

end
