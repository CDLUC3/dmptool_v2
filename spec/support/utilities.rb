include ApplicationHelper

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.should have_selector('title', text: title)
  end
end

RSpec::Matchers.define :have_h1 do |text|
  match do |page|
    page.should have_selector('h1', text: text)
  end
end

RSpec::Matchers.define :have_h1_and_title do |text|
  match do |page|
    page.should have_selector('h1', text: text)
    page.should have_selector('title', text: text)
  end
end

