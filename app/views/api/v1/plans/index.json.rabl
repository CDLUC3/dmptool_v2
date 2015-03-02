collection @plans

extends "api/v1/plans/show"

#node(:pagination) do
#  {
#    total:@plans.count,
#    total_pages: @plans.num_pages
#  }
#end

#node(:_links) do
#  paginate_api @plans
#end