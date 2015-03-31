# require gem 'aws-sdk', '~> 2'
namespace :ops do
  desc "get s3 object acl"
  task :get_s3_object_acl => :environment do 
    cli = Aws::S3::Client.new(
      region: 'ap-northeast-1',
      access_key_id: 'key',
      secret_access_key: 'access',
      # endpoint: 'https://s3.amazonaws.com',
    )
    
    # resp = cli.list_buckets
    # puts resp.buckets.map(&:name)
    
    obj = cli.get_object_acl(
      bucket: "bucket_name",
      key: "filepath"
    )
    p obj
  end
end

