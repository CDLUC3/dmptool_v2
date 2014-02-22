require 'faker'
class LipsumInserter

  def self.random_texts(how_many)
    formatting = [
                    ['<b>', '</b>'], ['<strong>', '</strong>'], ['<i>', '</i>'], ['<em>', '</em>'], ['<div>', '</div>'],
                    ['<span>', '</span>'], ['<u>', '</u>'], ['<h1>', '</h1>'], ['<h2>', '</h2>'], ['<h3>', '</h3>'],
                    ['<h4>', '</h4>'], ['<h5>', '</h5>'], ['<h6>', '</h6>']
                  ]
    paragraphs = []
    how_many.times do
      paragraphs.push(Faker::Lorem.sentences(rand(30)+5).join(" "))
    end

    paragraphs.map! do |p1|
      p = p1
      number = rand(10)
      0.upto(number) do |i|
        words = p.split(" ")
        word = words[rand(words.length)]
        markup_item = formatting[rand(formatting.length)]
        p[word] = "#{markup_item[0]}#{word}#{markup_item[1]}"
      end
      "<p>" + p + "</p>"
    end
  end

  def self.random_urls(how_many)
    items = []
    how_many.times do
      url = Faker::Internet.url
      i = rand(10)
      case i
        when 0..2
          url[/^http:\/\//] = ''
        when 3
          url[/^http:\/\//] = 'https://'
        when 9
          url = url[rand(url.length)..-1] #mangle badly like a user
      end
      items.push([Faker::Lorem.words(rand(15)+1).map{|i| i.capitalize}.join(' '), url])
    end
    items
  end

  # generate help_text
  # resource_type: resource_type, value: null, label: truncated_text(50), text: full_text
  def self.add_non_url(resource_type, number)
    items = self.random_texts(number)
    items.each do |item|
      truncated = item[0..49]

      r = Resource.new
      r.resource_type = resource_type
      r.value = nil
      r.label = truncated
      r.text = item
      r.save
    end
  end

  #adds resources of various types to the resources table
  def self.add_fake_data_to_resources(number)
    # generate actionable_url
    # resource_type: actionable_url, value: url, label: label, text: null
    items = self.random_urls(number)
    items.each do |item|
      r = Resource.new
      r.resource_type = 'actionable_url'
      r.value = item[1]
      r.label = item[0]
      r.text = nil
      r.save
    end

    self.add_non_url('help_text', number)
    self.add_non_url('suggested_response', number)
    self.add_non_url('example_response', number)
  end

end