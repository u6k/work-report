module NetModule
  extend ActiveSupport::Concern

  def self.get_s3_bucket
    Aws.config.update({
      region: Rails.application.secrets.s3_region,
      credentials: Aws::Credentials.new(Rails.application.secrets.s3_access_key, Rails.application.secrets.s3_secret_key)
    })
    s3 = Aws::S3::Resource.new(endpoint: Rails.application.secrets.s3_endpoint, force_path_style: true)

    bucket = s3.bucket(Rails.application.secrets.s3_bucket)
  end

  def self.download_with_get(url, file_name, missing_only = false)
    bucket = NetModule.get_s3_bucket

    obj_original = bucket.object(file_name)
    if obj_original.exists? && missing_only
      keys = { original: obj_original.key }
    else
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = "curl/7.54.0"
      req["Accept"] = "*/*"

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
        http.request(req)
      end

      sleep(1)

      obj_original = bucket.object(file_name)
      obj_original.put(body: res.body)
      obj_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d%H%M%S"))
      obj_backup.put(body: res.body)

      header = {}
      res.each do |name, value|
        header[name] = value
      end

      keys = {original: obj_original.key, backup: obj_backup.key, header: header}
    end
  end

end
