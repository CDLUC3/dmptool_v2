object @institution

attributes :id, :full_name, :contact_email

#node(:plans_count2) {|l| l.plans(institution)}

#node(:plans_count3) {|l| l.plans}

#node(:plans_count4) {|l| plans}

node(:plans_count5) {|l| l.id}

node(:status) { @status }

#node(:plans) { {@plans}

#node(:plans) { |l| l.unique_plans } 

#node(:plans_count) {|l| l.unique_plans(institution)}

#node(:edit_url) { |article| edit_article_url(article) }

#node(:time_ago) { |m| distance_of_time_in_words(m.created_at, Time.now) }