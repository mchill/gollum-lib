class Gollum::Filter::GRAPHVIZ < Gollum::Filter
  # Extract all graphviz blocks into the map and replace with placeholders
  def extract(data)
    return data if @markup.format == :txt
    data.gsub(/^\[graphviz(?:, ?(.+?))?\]\r?\n----\r?\n(.+?)\r?\n----$/m) do
      id       = Digest::SHA1.hexdigest(Regexp.last_match[2])
      @map[id] = { :style => Regexp.last_match[1], :code => Regexp.last_match[2] }
      id
    end
  end

  # Process all diagrams from the map and replace the placeholders with
  # the final HTML.
  #
  # data - The String data (with placeholders).
  #
  # Returns the marked up String data.
  def process(data)
    @map.each do |id, spec|
      data.gsub!(id) do
        render_wsd(spec[:code], spec[:style])
      end
    end
    data
  end

  private
  # Render the sequence diagram on the remote server.
  #
  # Returns an <img> tag to the rendered image, or an HTML error.
  def render_wsd(code, style)
    if style.nil?
      style = "dot"
    end

    title = Digest::MD5.hexdigest(code)

    if not File.exist?('/root/docs/uploads/graphviz/' + title + '.png')
      File.write('/root/tmp/graph.txt', code)
      %x(dot2ruby /root/tmp/graph.txt > /root/tmp/graph.rb)
      %x(echo ".output(:use => '#{style}', :png => '/root/docs/uploads/graphviz/#{title}.png')" >> /root/tmp/graph.rb)
      %x(ruby /root/tmp/graph.rb)
      %x(cd /root/docs;git add uploads/graphviz/*;git commit -m "New Graphviz Image")
    end
    return '<img src="/uploads/graphviz/' + title + '.png">'
  end
end

