# ~*~ encoding: utf-8 ~*~

class Gollum::Filter::Render < Gollum::Filter
  def extract(data)
    begin
      Dir.chdir(@markup.dir) do
        data = GitHub::Markup.render(@markup.name, data)
      end
      if data.nil?
        raise "There was an error converting #{@markup.name} to HTML."
      end
    rescue Object => e
      data = html_error("Failed to render page: #{e.message}")
    end

    data
  end

  def process(data)
    data
  end
end
