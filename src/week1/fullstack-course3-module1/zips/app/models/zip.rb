class Zip

  # convenience method for access to client in console
  def self.mongo_client
    Mongoid::Clients.default
  end

  # convenience method for access to zips collection
  def self.collection
    self.mongo_client['zips']
  end

  #map internal :population term to :pop document form
  def self.all(prototype={}, sort={:population=>1}, offset=0, limit=100)
    tmp={} #hash needs to stay in stable order provided
    sort.each {|k, v|
      k = k.to_sym==:population ? :pop : k.to_sym
      tmp[k] = v if [:city, :state, :pop].include?(k)
    }
    sort=tmp
    prototype.each_with_object({}) {|(k, v), tmp| tmp[k.to_sym] = v; tmp}
  end
end