require 'csv'
require 'typhoeus'
require 'json'
#------------------Replace these values-----------------------------#
access_token = ''
url = 'https://sometinggoeshere.instructure.com' #Enter the full URL to the domain
csv_file = 'tools.csv' 		#Enter the full path to the file.

#-------------------Do not edit below this line---------------------#

unless Typhoeus.get(url).code == 200 || 302
	raise 'Unable to run script, please check token, and/or URL.'
end



hydra = Typhoeus::Hydra.new(max_concurrency: 10)
	
CSV.foreach(csv_file, {:headers => true}) do |row|


	api_call = "#{url}/api/v1/courses/sis_course_id:#{row['course_id']}/external_tools?name=#{row['name']}&consumer_key=#{row['consumer_key']}&shared_secret=#{row['shared_secret']}&privacy_level=public&url=https://cloud.scorm.com/sc/blti&icon_url=http://www.edu-apps.org/tools/scorm_cloud/icon.png"
	notifications_api = Typhoeus::Request.new(api_call, 
										method: :post,  
										headers: { "Authorization" => "Bearer #{access_token}" })
	
	hydra.queue(notifications_api)
end
hydra.run

puts 'Successfully updated all LTIs.'
