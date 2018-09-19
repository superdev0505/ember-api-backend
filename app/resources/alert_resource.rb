class AlertResource < JSONAPI::Resource

  has_one :user
  has_one :target, polymorphic: true

  attributes :unread, :text, :read_link, :user_id, :updated_at, :created_at, :target_type

  filters :user_id, :unread

  filter :unique_read_link, apply: ->(records, value, _options){
    value = value[0] if value.is_a?(Array)
    puts "********* #{value}"
    if value == "true"
      puts "FILTERING"
      records.where("created_at IN (SELECT MAX(created_at) FROM alerts GROUP BY read_link)").order('created_at DESC')
      # records.order("created_at DESC").group(:read_link)#.distinct(:read_link)#select("DISTINCT(read_link),id,unread,user_id,text,updated_at,created_at,target_id,target_type")
    else
      puts "NOT FILTERING"
      records
    end
  }

end
