require 'net/http'
require 'date'

def generate_ref_id(resource)
  next_refid = get_next_refid(resource)

  begin
    url = URI.parse(AppConfig[:backend_url] + "/plugins/caas_next_refid?resource_id=#{resource.id}")
    request = Net::HTTP::Post.new(url.to_s)
    Net::HTTP.start(url.host, url.port) do |http|
      http.request(request)
    end
    next_refid
  rescue
    return DateTime.now.strftime('%Q')
  end
end

def get_next_refid(resource)
  resource['caas_next_refid'] ? resource['caas_next_refid']['next_refid'] : 1
end

ArchivalObject.auto_generate(property: :ref_id,
                             generator: proc do |json|
                               resource = Resource.to_jsonmodel(JSONModel::JSONModel(:resource).id_for(json['resource']['ref']))
                               "#{resource['ead_id']}_ref#{generate_ref_id(resource)}"
                             end,
                             only_on_create: true)

ArchivalObject.auto_generate(property: :ref_id,
                             generator: proc do |json|
                               resource = Resource.to_jsonmodel(JSONModel::JSONModel(:resource).id_for(json['resource']['ref']))
                               "#{resource['ead_id']}_ref#{generate_ref_id(resource)}"
                             end,
                             only_if: proc { |json| json['caas_regenerate_ref_id'] })
