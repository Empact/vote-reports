class DistrictZipCodesReferenceZipCodes < ActiveRecord::Migration
  def self.up
    $stdout.sync = true
    rename_column :district_zip_codes, :zip_code, :zip_code_id
    DistrictZipCode.paginated_each do |district_zip_code|
      zip_code = ZipCode.find_by_zip_code(district_zip_code[:zip_code_id]) || raise("Foo")
      district_zip_code.update_attribute(:zip_code, zip_code)
      $stdout.print '.'
    end
    constrain :district_zip_codes, :zip_code_id, :reference => {:zip_codes => :id}
  end

  def self.down
    raise "nope"
  end
end
