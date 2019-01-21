class ModelCollection

  include Enumerable

  attr_accessor :data


  def self.parse(value, model)
    self.new(value, model)
  end



  def initialize(value = {}, model = nil)

    @data = []

    @data = value.map do |val|
      model.parse(val)
    end

  end


  def each
    @data.each do |val|
      yield val
    end
  end

  def map
    @data.map do |val|
      yield val
    end
  end

  def each_with_index(&block)
    @data.each_with_index(&block)
  end

  def <<(val)
      @data << val
  end

  def sort!(&block)
    @data.sort!(&block)
  end

  def [](value)
    @data[value]
  end

  def +(value)
    @data + value
    self
  end

  def empty?
    @data.empty?
  end

  def remove(obj)
    @data = @data.delete_if do |val|
      val == obj
    end
    self
  end

  def insert(*args)
    @data.insert(*args)
  end

end



class Model


  class << self


    def associations
      @associations ||= {}
    end


    def model_registry
      @model_registry ||= {}
    end



    def register
      Model.model_registry[self.name] = self
    end


    def has_many(base_assosiation_name, options)

      serialize_as_root = options[:serialize_as_root] ? true : false

      #polymorphic_type: when your model has association on model with different type (e.g. Rails polymorphic association),
      #you model should have column which holds String name of a class, that will be associated for this particular model
      #e.g. has_one :node, polymorphic_type: 'node_type'
      #this is required for Model#parse_attributes
      polymorphic_type = options[:polymorphic_type] ? options[:polymorphic_type] : false

      self.associations[base_assosiation_name] = {class_name: options[:class_name], type: [], base_name: base_assosiation_name, serialize_as_root: serialize_as_root, polymorphic_type: polymorphic_type}

      options[:aliases].each do |association_name|
        self.associations[association_name] = {class_name: options[:class_name], type: [], base_name: base_assosiation_name, serialize_as_root: serialize_as_root}
      end if options[:aliases]

      attributes base_assosiation_name

    end



    def has_one(base_assosiation_name, options)
      #for info on polymorphic_type refer to #has_many
      polymorphic_type = options[:polymorphic_type] ? options[:polymorphic_type] : false
      self.associations[base_assosiation_name] = {class_name: options[:class_name], type: {}, base_name: base_assosiation_name, polymorphic_type: polymorphic_type}

      options[:aliases].each do |association_name|
        self.associations[association_name] = {class_name: options[:class_name], type: {}, base_name: base_assosiation_name, polymorphic_type: polymorphic_type}
      end if options[:aliases]


      attributes base_assosiation_name

    end


    def parse(data)

      if data.is_a?(Hash)

        if self.parses_by_root

          data.each do |_key, _data|

            return  Model.model_registry[_key.to_camel_case].new(_data)

          end

        else

          self.new(data)

        end


      elsif data.is_a?(Array)

        self.parse_collection(data)

      end


    end



    #WIP purpose: serverside just queries raw sql's and returns raw results without serializing active record
    #server should provide associations as necessary and reponse should follow this format:
    # {
    #   model_name: #that is in model_registry 
    #   {
    #     fs: ['id', 'foo'], #field names
    #     vs: [[1, 'bar']] #array of arrays containg attributes set 
    #     #if associations are loaded:
    #     as: 
    #     {
    #       model_name: #name of class 
    #       {
    #         fs: x,
    #         vs: [['id', 'model_name_id']],
    #         lk: [foreing_key_on_owner, local_key_on_this] # ['id', 'model_name_id'] 
    #       }
    #     }
    #   }
    # } 
    #associations can be nested
    #TODO
    #add alt_c field to specify name of attribute that associated model will be set on parent
    #add tp: type of association hm ho (has_many, has_one)
    def self.parse_raw(data, owner_map = false, on_slave = false, assign_slave_to = false, _parse_model = false)
      
      parsed_models = nil
      
      data.each do |model_name, model_data|
        p model_name
        parsing_model = _parse_model ? _parse_model : Model.model_registry[model_name]    
        
        fields = model_data[:fs]

        parsed_models = model_data[:vs].map do |values|
          
          attrs = {}
          values.each do |value_set|
            fields.each_with_index do |name, index|
              attrs[name] = value_set[index]
            end
          end
          
          model_instance = parsing_model.new(attrs)

          if owner_map && owner_map[model_instance.attributes[on_slave]]
            owner_map[model_instance.attributes[on_slave]].attributes[assign_slave_to] = model_instance
          end

          model_instance
        
        end

        if associations = model_data[:as]

          associations.each do |k, v|
            on_owner = v[:lk][0]
            on_slave =  v[:lk][1]
            relation_map = {}
            parsed_models.each do |owner_model|
              relation_map[owner_model.attributes[on_owner]] = owner_model
            end
            parse_raw({k => v}, relation_map, on_slave, k)
          end

        else
          next
        end 
      end

      parsed_models
    
    end





    def parse_collection(data)
      ModelCollection.parse(data, self)
    end





    def route(name, method_and_url, options)
      if name[0] == name.capitalize[0]
        self.define_singleton_method(name.downcase) do |req_options = {}|
          RequestHandler.new(self, name, method_and_url, options, req_options).promise
        end
      else
        #route :save, post: "pages/:id", defaults: [:id]
        self.define_method(name) do |req_options = {}|#|wilds = {}, req_options = {}|
          RequestHandler.new(self, name, method_and_url, options, req_options).promise
        end
      end
    end



    def attributes(*args)

      args.each do |arg|

        if (ass = self.associations[arg]) && ass[:type] == []

          self.define_method arg do | |
            @attributes[arg] ||= ModelCollection.new
          end

        else

          self.define_method arg do | |
            @attributes[arg]
          end

        end


        self.define_method "#{arg}=" do |val|
          @attributes[arg] = val
        end


      end

    end



    def transfer_attributes_to_form_data(val, form_data, track = nil)
    #new formData() wrapped in Native shall be passed
    #val is the normalized attributes (containing no models) of a model
    #result is populated formData object to be passed to HTTP request with all the pure_attributes attached to it
    #this is  necessary for sending file though xhr only
    #depending if model has file defaultly make ajax data: formData returned from this method (can be done through validation)
    #TODO: fallback for ie < 10 and other shitty versions via iframe. But is there a true neccessity in such?
      if val.is_a?(Array)
        val.each_with_index do |v, i|
          if i == 0
            track = track + "[#{i}]"
          else
            #last length will grab the string depending on it's digits, eg [1], i 3 but [111] is not
            last_length = ((i - 1).to_s.length + 3)
            substringed = track[0..-last_length]
            track = substringed + "[#{i}]"
          end
          transfer_attributes_to_form_data(v, form_data, track)
        end
      elsif val.is_a? Hash
        val.each do |k, v|
          (track == nil) ? _track = k.to_s : _track = "#{track}[#{k}]"
          transfer_attributes_to_form_data(v, form_data, _track)
        end
      else
        form_data.append track, val
      end
      form_data
    end

    def parses_by_root
      false
    end

  end

  ########################

        #END CLASS METHODS


  #######################
  def attribute_change_tracking_hash
    self.attributes[:_changed_attributes_] ||= {}
  end

  def record_change_for_attribute(attr_name)
    attribute_change_tracking_hash[attr_name] = true
  end

  def clear_change_record_for_attribute(attr_name)
    attribute_change_tracking_hash.delete(attr_name)
  end

  def attribute_was_changed?(attr_name)
    !!attribute_change_tracking_hash[attr_name]
  end

  def dirty
    @dirty
  end

  def dirty?
    @dirty != @prev_dirty
  end

  def make_dirty
    @prev_dirty = @dirty
    @dirty += 1
  end


  def attributes
    @attributes
  end

  def attributes=(new_attributes)
    @attributes = new_attributes
  end


  attr_accessor :arbitrary

  def initialize(attributes = {})
    @dirty = 0
    @attributes = {}
    @arbitrary = {}
    @errors = {}


    parse_attributes(attributes)


    init(attributes)
  end




  def init(attributes)

  end




  def parse_attributes(attributes)
    attributes.each do |key, value|

      if (association_config = self.class.associations[key]) && !(value.is_a?(Model) || value.is_a?(ModelCollection))

        #this is required for polymorphic parsing, e.g. when model has association to different models for one column
        #if polymorphic feature shall be excluded this if statement can be deleted leaving only @attributes[ass[:base_name]] = value
        if polymorphic_type_holding_property = association_config[:polymorphic_type]

          if stringified_class_name = attributes[polymorphic_type_holding_property]
            
            @attributes[association_config[:base_name]] = Model.model_registry[stringified_class_name].parse(value)
            
          else

            @attributes[association_config[:base_name]] = value

          end

        else
          
          @attributes[association_config[:base_name]] = Model.model_registry[association_config[:class_name]].parse(value)

        end

      else

        @attributes[key] = value

      end
    end

  end





  def pure_attributes(root = true)

    value_to_return = {}

    @attributes.delete(:errors)

    if root

      value_to_return[self.class.name.to_snake_case] = {}

      accumulator = value_to_return[self.class.name.to_snake_case]

    else

      accumulator = value_to_return

    end

    @attributes.each do |key, value|


      serialize_as_root =  ((ass = self.class.associations[key]) && ass[:serialize_as_root]) ? true : false


      if value.is_a?(Model)

        accumulator[key] = value.pure_attributes( serialize_as_root )

      elsif value.is_a?(ModelCollection)

        accumulator[key] = value.data.map do |model|

          model.pure_attributes( serialize_as_root )

        end

      else

        accumulator[key] = value

      end

    end

    value_to_return

  end



  def update_attributes(data)
    _data = self.class.new(data).attributes
    @attributes.merge!(_data)
  end




  def before_route_create(r)
    r.req_options = {payload: self.pure_attributes}
  end

  def after_route_create(r)
    if r.response.ok?
      self.update_attributes(r.response.json)
      self.validate
      r.promise.resolve self
    end
  end


  def self.after_route_index(r)
    if r.response.ok?
      r.promise.resolve self.parse(r.response.json)
    end
  end

  def after_route_destroy(r)
    if r.response.ok?
      to_return = self.class.parse(r.response.json)
      to_return.validate
      r.promise.resolve to_return
    end
  end

  def self.after_route_show(r)
    if r.response.ok?
      r.promise.resolve self.parse(r.response.json)
    end
  end


  def self.after_route_edit(r)
     self.after_route_show(r)
  end

  def before_route_update(r)
    r.req_options = {payload: pure_attributes}
  end

  def after_route_update(r)
    if r.response.ok?
      self.update_attributes(r.response.json)
      self.validate
      r.promise.resolve self
    end
  end
#########################################

################VALIDATIONS#####################

##################################


  def errors
    @errors
  end

  def errors=(val)
    @errors = val
  end

  def has_file
    @file ||= false
  end




  def has_file=(value)
    @file = value
  end



  def self.has_file
    false
  end




  def serialize_attributes_as_form_data
    form_data = Native(`new FormData()`)
    self.class.transfer_attributes_to_form_data(self.pure_attributes(true), form_data)
  end

  def has_errors?
    !@errors.empty? #|| !(self.attributes[:errors] ||= {}).empty?
  end


  def reset_errors
    #It will set errors to empty hash
    # if  your view depends on errors (to show them or not)
    #youll need to reset them before each validation
    #TODO: recursion is not deep in here, not as deep as Grey's throat, but it needs to be!
    attributes.each do |k,v|
      if v.is_a? Model
        v.reset_errors
      end
      if v.is_a? ModelCollection
        v.each do |c|
          c.reset_errors
        end
      end
    end
    @errors = {}
  end



  def validate(options = {only: false})

    self.reset_errors
    self.has_file = false
    #for this method refer to itself; needed for serializing to automatic serialization to formData
    @attributes.each do |k, v|
      if options[:only]
        next unless options[:only].include? k
      end
      if v.is_a?(ModelCollection)
        v.each do |m|

            m.validate

            if m.has_errors?
              @errors[:nested_errors] = true
            end

        end

      elsif v.is_a?(Model)

        v.validate

        if v.has_errors?
          @errors[:nested_errors] = true
        end

      else

        self.send("validate_#{k}") if self.respond_to?("validate_#{k}")
        #p (self.respond_to? "validate_#{k}") ? "has validation method #{k}" : "doesn't have validation method #{k}"
        @errors.merge!(self.attributes[:errors] ||= {})
        self.attributes[:errors] = {}
        #in case errors teturned from server, but no validation rules for it on fronts

      end
    end
  end


  def add_error(attr_name, error)
    (@errors[attr_name] ||= []) << error
  end


end








class RequestHandler
  #handles your HTTP requests!!! Really! this get's started from your Model.route #route methods, look there

  attr_accessor :caller, :promise, :name, :response, :req_options

  def initialize(caller, name, method_and_url, options, req_options = {})
    @caller = caller
    #the model that called either instance or class
    @name = name
    #name of the route
    @options = options
    @wilds = req_options[:wilds] || {}
    #handy little :foo s
    #as well as options holder like
    #yield_response: true => will override default response handlers
    #component: component's self => will make RW comonent available
    #TODO: should wilds be renamed now? they're more options now than wilds as back then when they were young and silly little args
    @component = req_options[:component]
    #if you need to pass component to Http (e.g. turn on spinner before request, swith off after)
    #or any other sort of that
    #pass component to it
    #user.some_route({component: self})
    #and youll have access to it in automatic response handlers (or anywhere in requesthandler)
    @should_yield_response = req_options[:yield_response]
    #handy if you need unprocessed response
    #e.g. simply pass user.some_route({yield_response: true}) {|response| unprocessed response}
    @skip_before_handler = req_options[:skip_before_handler]
    #if you need to override defualts before request is made
    #pass this option to wild as {skip_before_handler: true}
    #else it's false by defaul
    name_space = req_options[:namespace] || false
    @url = prepare_http_url_for(method_and_url, name_space)
    #makes youre route get: "url/:foo",
    #passes default for wilds, or attaches one from wilds option

    @http_method = method_and_url.keys[0]

    if @caller.respond_to?("before_route_#{@name.downcase}") && !@skip_before_handler
      @caller.send "before_route_#{@name.downcase}", self
      #default prepare for ajax data (payload) on
      # rest actions e.g. save, update, destroy, etc/
      #so you wont need to user.destroy(payload: user.pure_attributes),
      #and simply user.destroy and that's it!
      #and be like responses_on_route_name
      #EDIT: it kinda works now as of nov 17 2015, but needs reviewing
    end

    @req_options ||= {}

    @extra_params = {}
    #TODO: WATCH the behaviour
    if req_options[:extra_params]
      @extra_params = req_options[:extra_params]
      @req_options.merge! @extra_params
    end

    if req_options[:data]
    #ve done it for these reasons:
    #if passed as payload it will be to_json,
    #depending on what you're passing it may throw some shit at you because it'll be to_n'ed
    #the main reason was to be able to pass files via formData
      @req_options = req_options

    elsif req_options[:payload]

      @req_options = req_options

    elsif @caller.has_file || req_options[:serialize_as_form]
      #this skip before is needed to override default's on model class which result in payload: something; not data
      @skip_before_handler = true

      @caller.update_attributes @extra_params

      @req_options[:data] = @caller.serialize_attributes_as_form_data

      @req_options.delete(:payload) if @req_options[:payload]

      @req_options[:processData] = false

      @req_options[:contentType] = false
      #For info on this method refer to validation part of model
    else

      (@req_options[:payload] ||= {}).merge!(@extra_params)

    end
    #TODO: NEED TO THROUGHLY PLAN AND STANDARTIZE THE OPTIONS THAT CAN BE PASSED FOR REQUEST!
    send_request

  end

  def prepare_http_url_for(method_and_url, name_space)
    url = method_and_url[method_and_url.keys[0]].split('/')
    url.map! do |part|
      if part[0] == ":"
        if @wilds[part[1..-1]]
          @wilds[part[1..-1]]
        elsif  (@options[:defaults].find_index(part[1..-1]) if @options[:defaults].is_a?(Array))
          @caller.send part[1..-1]
        end
      else
        part
      end
      #TODO: raise if route is defined with wild but no wild was resolved defaultly or not was given through wild arg
    end

    if name_space
      url.unshift(name_space)
    end

    url.unshift('api')
    #adds prefix to url as apiv1/url
    #TODO: move to as constant of Model
    "/#{url.join('/')}"
    #returns full url
  end

  def send_request

    @promise = Promise.new

    defaults_before_request
    #the super defaults app wide.
    #TODO: need option to override

    HTTP.__send__(@http_method, @url, @req_options) do |response|

      @response = response
      #SUPER DEFAULTS ON RESPONSE
      #TODO: make option to override
      defaults_on_response

      if @should_yield_response
        yield_response
        #handy if you need unprocessed response
        #e.g. simply pass user.some_route({yield_response: true}, {}) {|response| unprocessed response}
      elsif @caller.respond_to? "after_route_#{@name.downcase}"

        @caller.send "after_route_#{@name.downcase}", self
        #this will call the default actions on response if they are defined
        #the convention is that model shall implemenet responses_on_<route_name> method
        #else defaults will run
      else

        default_response

      end
    end
    @promise
  end

  def yield_response
    if @response.ok?
      @promise.resolve @response
    else
      @promise.reject @response
    end
  end

  def default_response(response, promise)
    if @response.ok?
      @promise.resolve @response.json
    else
      @promise.reject @response.json
    end
  end

  # def defaults_before_request

  # end

end
