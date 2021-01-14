require "curb"
require "json"

TAGGER_URL = "http://localhost/api/tagger"

module TagService
  # Sends the image to the tagger server for analysis. It then
  # updates the image with information returned by the server,
  # creates new +Tag+s for features in the image and returns a
  # list of suggested keywords for the image.
  # @param image [Image] The image record to tag.
  # @param data [String] The image binary data.
  # @return [Array<String>] Suggested keywords for the image.
  def self.tag_image(image, data)
    id = Curl::PostField.content("id", image.id)
    file = Curl::PostField.file("file", image.file_name) do |field|
      field.content = data
    end

    c = Curl::Easy.new(TAGGER_URL)
    c.multipart_form_post = true
    c.http_post(id, file)
    raise HttpError, 500 unless c.response_code == 200
    res = JSON.parse(c.body_str, symbolize_names: true)


    params = {
      width: res[:width],
      height: res[:height],
      orientation: res[:orientation]
    }
    image.update(params)

    tags, keywords = res[:tags].reduce([[], []]) do |acc, tag|
      t, k = acc

      kind = tag[:type]
      value = tag[:value]
      case kind
      when "feature"
        t << {
          image_id: image.id,
          kind: kind,
          value: value[0],
          count: value[1]
        }
        k << value[0]
      when "color"
        t << {
          image_id: image.id,
          kind: kind,
          value: value,
          count: nil
        }
      when "keyword"
        k << value
      else
        raise HttpError, 500
      end

      [t, k]
    end

    image.tags.create(tags)
    keywords
  end

  # @param image [Image]
  # @param keywords [Array<String>]
  def self.add_keywords(image, keywords)
    return if keywords.length.zero?

    tags = keywords.map do |keyword|
      {
        image_id: image.id,
        kind: "keyword",
        value: keyword,
        count: nil
      }
    end

    image.tags.create(tags)
  end

  # Returns +true+ if the tagger server is online
  # and reachable.
  # @return [Boolean]
  def self.tagger_online?
    c = Curl.get(TAGGER_URL)
    c.response_code == 200
  end
end