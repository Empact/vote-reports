module ImagesHelper
  def image_with_hover_tag(image, title, attrs = {})
    style = attrs.delete(:style) || image.thumbnail.default_style
    attrs.reverse_merge!(:alt => title, :title => title)
    if style != :large && image.thumbnail.file?
      attrs[:rel] = image.thumbnail.url(:large)
      attrs[:class] ||= ''
      attrs[:class] += " act-qtip-image qtip-width-#{image.thumbnail.styles[:large][:geometry].split('x').first.to_i}"
    end
    image_tag(image.thumbnail.url(style), attrs)
  end
end
