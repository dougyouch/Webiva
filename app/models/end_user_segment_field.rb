
class EndUserSegmentField < UserSegment::FieldHandler

  def self.user_segment_fields_handler_info
    {
      :name => 'User Fields',
      :domain_model_class => EndUser,
      :end_user_field => :id
    }
  end

  register_field :email, UserSegment::CoreType::StringType, :name => 'Email', :sortable => true
  register_field :gender, EndUserSegmentType::GenderType, :name => 'Gender', :sortable => true
  register_field :created, UserSegment::CoreType::DateTimeType, :field => :created_at, :name => 'Created', :sortable => true
  register_field :registered, UserSegment::CoreType::BooleanType, :name => 'Registered', :sortable => true
  register_field :activated, UserSegment::CoreType::BooleanType, :name => 'Activated', :sortable => true
  register_field :user_level, UserSegment::CoreType::NumberType, :name => 'User Level', :sortable => true
  register_field :dob, UserSegment::CoreType::DateTimeType, :name => 'DOB', :sortable => true
  register_field :last_name, UserSegment::CoreType::StringType, :name => 'Last Name', :sortable => true
  register_field :first_name, UserSegment::CoreType::StringType, :name => 'First Name', :sortable => true
  register_field :source, EndUserSegmentType::SourceType, :name => 'Source', :sortable => true
  register_field :lead_source, EndUserSegmentType::LeadSourceType, :name => 'Lead Source', :sortable => true
  register_field :registered_at, UserSegment::CoreType::DateTimeType, :name => 'Registered At', :sortable => true
  register_field :referrer, UserSegment::CoreType::StringType, :name => 'Referrer', :sortable => true
  register_field :username, UserSegment::CoreType::StringType, :name => 'Username', :sortable => true
  register_field :introduction, UserSegment::CoreType::StringType, :name => 'Introduction', :sortable => true
  register_field :suffix, UserSegment::CoreType::StringType, :name => 'Suffix', :sortable => true

  def self.order_options(order_by, direction)
    field = self.user_segment_fields[order_by.to_sym][:field]
    {:order => "end_users.#{field} #{direction}"}
  end

  def self.field_display_value(user, field)
    display_field = self.user_segment_fields[field.to_sym][:display_field]

    value = t.send(display_field)
    if value.is_a?(DomainModel)
      value.name
    elsif value.is_a?(Time)
      value.strftime(DEFAULT_DATETIME_FORMAT.t)
    elsif value.nil?
      '-'
    else
      value.to_s
    end
  end

  def self.get_handler_data(ids, fields)
  end

  def self.field_heading(field)
    self.user_segment_fields[field][:name]
  end

  def self.field_output(user, handler_data, field)
    display_field = self.user_segment_fields[field][:display_field]

    value = user.send(display_field)
    return nil if value.nil?

    if value.is_a?(DomainModel)
      value.name
    elsif value.is_a?(Time)
      value.strftime(DEFAULT_DATETIME_FORMAT.t)
    else
      value.to_s
    end
  end
end
