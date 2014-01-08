class DateValidator < ActiveModel::EachValidator
	
	def validate_each(record, attribute, value)
 		unless value.is_a?(Date)
 			record.errors.add(attribute, 'Invalid date')
 		end
 	end
 
end