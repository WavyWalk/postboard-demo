=begin
  NOTICE
  *****************OPAL JQUERY needs hack
  UPDATE: MONKEY PATCHED IN core_monkey_patches
  after this line
    settings, payload = @settings.to_n, @payload
  this should be inserted in opal_jquery opal gem

    %x{
      if (typeof(#{payload}) === 'string' || #{@method == "get"}) {
        payload = #{@payload.to_n};
        #{settings}.data = $.param(payload);
      }
      else if (payload != nil) {
        settings.data = payload.$to_json();
        settings.contentType = 'application/json';
      }

      settings.url  = #@url;
      settings.type = #{@method.upcase};

      settings.success = function(data, status, xhr) {
        return #{ succeed `data`, `status`, `xhr` };
      };

      settings.error = function(xhr, status, error) {
        return #{ fail `xhr`, `status`, `error` };
      };

      $.ajax(settings);
    }

This dirty hack is needed for proper serialization of payload povided with ruby hash to query string on HTTP.get requests

If you're going to use zepto: zepto itself as well as opal-jquery need hack
Zepto should be defined on window.
If you get raised with something like "gvars[]$[]and stuff", in opal-jquery change from $$["Zepto"][:zepto][:Z] to `window.Zepto.zepto.Z`
don't know why it isn't working -- it should be!
****************************RAILS CORE NEEDS HACK!
if you want to use as_json (reminder Model needs root true in serialized eg NOT User.find(1).as_json => {id:1} BUT {user: {id: 1}}),
this can be achieved via adding to  config/initializer/wrap_parameters.rb:
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = true
end
But if you have something nested eg user.has_many blogs User.includes(:blog).find(1).as_json(include: [:blog]) =>
user will get serialized with root: true, but blog will NOT e/g/ user: {id: 1, blog: {id: 1}} NOT user: {id: 1, blog: {blog: {id: 1}}}
even if youll pass root: true as include: {blog: {root: true}},
There some dirty hack again:
in config/application.rb after rails loaded just monkeypatch ActiveModel::Serialization
#WARNING: check out source of ActiveModel::Serialization if it gets changed in future versions and keep it in sync with this monkeypatch/
by adding:
    module ActiveModel
      module Serialization
        def serializable_hash(options = nil)
          options ||= {}

          attribute_names = attributes.keys
          if only = options[:only]
            attribute_names &= Array(only).map(&:to_s)
          elsif except = options[:except]
            attribute_names -= Array(except).map(&:to_s)
          end

          hash = {}
          attribute_names.each { |n| hash[n] = read_attribute_for_serialization(n) }

          Array(options[:methods]).each { |m| hash[m.to_s] = send(m) if respond_to?(m) }

          serializable_add_includes(options) do |association, records, opts|
            hash[association.to_s] = if records.respond_to?(:to_ary)
              records.to_ary.map { |a| a.serializable_hash(opts) }
            else
              records.serializable_hash(opts)
            end
          end
          root = options[:root]  <+==================THIS LINE IS ADDED
          root ? {self.class.name.split("::")[-1].underscore => hash} : hash <+++++++++THIS IS LINED IS CHANGED, PRIOR IT WAS SIMPLY: hash
        end
      end
    end
# above is optional and you can always just use root: true including include: models
********************************************************************



=end

# require "opal"
# require "promise"
class Model

  #@attributes_list REVISE AND DELETE
  #WARNING EXPERIMENTAL
  #@association_list #REVISE AND DELETE

  #@associations_list not yet implemented; think about it is there a reason to be?
  #they are handled as attribute now and we're not on backend,
  #TODO: think about
  #UPDATE: decided to go only wth has_many and has_one, and they're only needed for
  #proper serialization for handling accepts_nested_attributes_for
  #@nested_attributes#experimental REVISE AND DELETE
  class << self
    attr_accessor :attributes_list

    #experimental
    #if youve run has_many has_one @nested_attributes will contain them, and
    #that is needed in pure_attributes mehtod, and also when getter setter will be defined for
    #args passed to has_many has_one
    #has_many has_one ARE NOT method to make queries to server, they are needed
    #a. to make default value of geter of [] if has_many
    #b. they are used in accepts_nested_attributes_for
    #c. they're needed in pure_attributes (again to put in array if has_many)
    def nested_attributes
      @nested_attributes ||= {}
    end
    def association_list
      @association_list ||= {}
    end
    #!!!!!!!!!!!!!! NOT YET IMPLEMENTED REFER TO self.json_attr

  end

  ####EXPERIMENTAL NEEDED ONLY FOR ACCEPTS_NESTED_ATTRIBUTES TO WORK!
  #Itself there's no big difference between has_many and has_one on client
  #and the only difference that has_one is a hash containg the model
  #and has_many should hold an array of them/
  #this difference is needed for:
  #serialization in #pure_attributes to either out in array or hash
  #and also the has many getter definition (with .attributes) should return an array
  #that's it
  def self.has_many(*args)
    args.each do |arg|
      #in pure attributes is used for checking should either to array || hash
      #in .attributes is used for cheking if getter should return ||= array
      #also get copied to self.nested_attributes[arg] if accepts_nested_attributes_for defined
      #defines the getter and setter just like .attributes for you to manage it easily
      self.association_list[arg] = []
      self.attributes arg
    end
  end
  #the same as has_many behaviour
  def self.has_one(*args)
    args.each do |arg|
      #actually this can be assigned to anything truthy, in method where it's checked
      #eg. #pure_attributes or .attributes it checks if it's an [], else it's counted as
      #hash holding single model
      #self.nested_attributes[arg] = {}
      self.association_list[arg] = {}
      self.attributes arg
    end
  end

  def self.accepts_nested_attributes_for(*args)
    args.each do |arg|
      self.nested_attributes[arg] = self.association_list[:arg]
    end
  end

  def mark_for_destruction(model)
    x = self.where do |_model|
      _model == model
    end
    x.each do |_model|
      _model.attributes[:_destroy] = "1"
    end
  end
############################

  def self.parse(data)
    if data.is_a? String
      data = JSON.parse(data)
    end
    parsed_data = objectify data
    if parsed_data.is_a? Array
      return ModelCollection.new(data)
    end
    parsed_data
  end
## THESE ARE NEEDED FOR PARSE CLASS METHOD
  def self.objectify(data, class_name = "Model", objectify_model = nil)
    data = objectify_array(data)
    data = objectify_single_model(data) unless objectify_model
    if data.is_a? Hash
      data = objectify_from_model(data)
    end
    data
  end

  def self.objectify_array(data)
    if data.is_a? Array
      data = data.each_with_index do |v, i|
        data[i] = self.objectify(v)
      end
    end
    data
  end

  def self.objectify_single_model(data)
    if (data.is_a? Hash) && (data.size == 1)
      data.each_with_index do |(i, value), index|
        #TODO raise on constant missing, rescue with parse on value, and passing k as symbol to model
        begin
        data = i.to_camel_case.constantize.new(value) if value.is_a? Hash
        rescue
          data[i] = self.objectify(value)
        end
      end
    end
    data
  end

  def self.objectify_from_model(data)
    handle_specifically_selected(data)  #refer to .handle_specifically_selected
    data.each_with_index do |(k, v), index|
      if (v.is_a? Hash) || (v.is_a? Array)
        data[k] = objectify(v)
      end
    end
    data.delete_if {|k, v| k[0..2] == "sj_" || k[0..2] == "si_"} #refer to .handle_specifically_selected
    data
  end

  #Rails unfortunately doesn't provide a way to select columns on preloaded (or includes) table
  # eg User.includes(:profiles).select("users.*, profiles.name") will anyway load all from profile
  #as well as when doing joins with selecting Rails won't map selected columns on joined to corresponding models
  #eg User.joins(:profiles).select("users.*, profiles.name AS p_name")
  #that way youll be able to access name but it wont be on profile model
  #so to handle that stuff so your frontend would handle the modelized way
  #for includes with speciffically selected fields
  #follow this: e/g/ belongs_to :si_user1id_name_password, ->{select(:id, :name, :passowrd)}, classname: User, foreign_key: "user_id"
  #so when serialized it'll pass it to client like {profile: {foo: "bar", si_user1id_name_password: {user: {id: 1, name: "q", password: "joe"}}}}
  #but on client it would serialize as it is regular e.g. {profile: {foo: "bar", user: {user: {id: 1, name: "q", password: "joe"}}}}
  #for joins follow the same User.joins(:profile).select("users.*, profiles.name AS sj_profile1name")
  #your server will {user: {foo: "bar", sj_profile1name: "the joe"}}
  #but client will serialize it to {user: {foo: "bar", profile: {profile: {name: "joe"}}}}
  #so no need to remember and use those arbitrary attr holders if follow this convention
  #plus you can nest sj_ as sj_user1sj_profile1name will let {foo: {user: {user: {profile: {profile: {name: "yay!"}}}}}}
  def self.handle_specifically_selected(data)
    found = nil
    data.each do |k, v|
      if k[0..2] == "sj_"
        found = true
        splitted = k.split("1")
        name = splitted[0][3..-1].split("2")
        att_n = splitted[1..-1].join("1")
        if name[1]
          ((data[name[0]] ||= {})[name[1]] ||= {})[att_n] = v
        else
          ((data[name[0]] ||= {})[name[0]] ||= {})[att_n] = v
        end
      elsif k[0..2] == "si_"
        if k[0..2] == "si_"
          #found = true
          splitted = k.split("1")
          name ||= splitted[0][3..-1]
          data[name] = v
        end
      end
    end
  end
## END THESE ARE NEEDED FOR PARSE CLASS METHOD

  #Model.itearate_for_form serializes opal hash to JS formData
  #formData serialized nested arrays can't be serialized properly serverside (last item only will be in array)
  #so it iterate_for_form serialize it to simulated array the way accepts_nested_attributes_for undersatands e.g
  #{'1' => {foo: 'bar'}, '2' => {foo: bar}}
  #but other xhr is serialized properly as JSON
  #so it's needed for cases when you submit files only AND OU SHOULD NORMALIZE SIMULATED array to Array for compatibility
  # e.g. you can use such method in ApplicationController
  # def simulated_array_to_a(_params)
  #   if _params.is_a?(Hash)
  #     ary = []
  #     if /\A\d+\z/.match(_params.keys[0])
  #       _params.each do |k, v|
  #         ary << v
  #       end
  #       return ary
  #     end
  #   else
  #     return _params
  #   end
  # end
  def self.iterate_for_form(val, form_data, track = nil)
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
        iterate_for_form(v, form_data, track)
      end
    elsif val.is_a? Hash
      val.each do |k, v|
        (track == nil) ? _track = k.to_s : _track = "#{track}[#{k}]"
        iterate_for_form(v, form_data, _track)
      end
    else
      form_data.append track, val
    end
    form_data
  end


  #######INSTANCE

  #attr_accessor :attributes
  #This accessor needed if you need some arbitrary data on model at runtime temprorarily
  #for and just to have some centralized access to it without making accessors
  #you can use it
  attr_accessor :arbitrary, :attributes

  def initialize(data = {})
    data = self.class.objectify(data, nil, true)
    @arbitrary = {} #refer to attr_accessor :aritrary for info
    @attributes = data
    @errors = {}
    init
    #again this init is needed for you to use intialize without super
    #looks neatier for me
  end

  #refer to #initialize for info
  def init

  end

  #for example you have a model {user: {id: 1, page: {page: {id: 2}}}}
  #parsed it ll be user.@attributes {id: 1, <Page instance>}
  #and you'll need it to pass to server, but @attributes will contain instantiated page not its attributes
  #this way it will return the pure hash as -> kind of reverse of Model.parse
  #BUG: CHANGES THE ACTUAL ATTRIBUTES! edit: changed a bit but behaviour needs examination UPDATE: i does not anymore
  def pure_attributes(root = true)
    x = {}
    attributes.delete(:errors)

    attributes.each do |k,v|
      #weird part of v.dup is needed when native objects (in single case I encounterd
      #the native file from input would otherwise niled)
      if self.class.nested_attributes.has_key? k
        unless x["#{k}_attributes"].try(:empty?)
          x["#{k}_attributes"] = normalize_attributes( (v.nil? ? v : ( (v.dup.nil? || v.dup == 0) ? v : v.dup)), false )
        end
      else
        x[k] = normalize_attributes( (v.nil? ? v : ((v.dup.nil? || v.dup == 0) ? v : v.dup)))
      end
    end

    if root
      {self.class.name.to_snake_case => x}
    else
      x
    end

  end

  #THIS METHOD IS ONLY NEEDED FOR #pure_attributes
  def normalize_attributes(attrs, root = true)
    if attrs.is_a? Hash
      attrs.each do |k,v|
        if v.is_a? Model
          attrs[k] = v.attributes
        else
          attrs[k] = normalize_attributes(v)
        end
      end
    elsif attrs.is_a? Array
      attrs.map! do |val|
        normalize_attributes(val, root)
      end
    elsif attrs.is_a? Model
      attrs.pure_attributes(root)
    else
      attrs
    end
  end

  def update_attributes(data)

    attrs = self.class.objectify(data, nil, true)
    @attributes.merge! attrs
    #TODO: implement deep merge
  end

  def self.attributes(*args)
    (@attributes_list ||= []) + args
    args.each do |arg|
      self.define_method arg do | |
        if self.class.association_list[arg] == []
          @attributes[arg] ||= []
        else
          @attributes[arg]
        end
      end

      self.define_method "#{arg}=" do |val|
        @attributes[arg] = val
      end
    end
  end

  def where(&block)
    #JUST BEGAN TO IMPLEMENT
    #wanth to have a search method which would traverse model or assciation deeply
    #and will yield each model it finds and if the conditions in block will match for that model attrs
    #it'll grab that model to result association
    #why the block and not DSL? i thought of implementing sort of DSL for it, and almost wanted to make a separate class for that
    #but fucking with DSL is quite annoying and it'd be harder to maintain it later so what I want is
    #model_association.where do |a|
    #  a[:id] == 1 || a[:name].matches regex || a[:lenght] < 6 && a[:published] = "true"
    #end
    #and it's not a big deal )
    #IMPLEMENTED
    s = []
    attributes.each do |k, v|
      if v.is_a? Model
        s << v if yield(v)
        s = s + v.where {block.call}
      elsif v.is_a? Array
        v.each do |c|
          if c.is_a? Model
            s << c if yield(c)
            s = s + c.where {block.call}
          end
        end
      end
    end
    s
  end
=begin
  def self.associations(*args)
    #NOT YET IMPLEMENTED! it's here just beacuse it's here, and someday, some beatifull cloudy day i'll try do do
    #something with it!
    @associations_list = args
    args.each do |arg|
      self.define_method arg do | |
        @associations_list[arg]
      end

      self.define_method "#{arg}=" do |val|
        @associations_list[arg] = val
      end
    end
  end
  TODO: propbably shall be deleted beacuse association stuff can be done via routes, and no need in it on frontend
  UPDATE: done sort of it just leave it be or now
=end
  #defines method of making a request to server
  # described in docs
  def self.route(name, method_and_url, options ={})
    if name[0] == name.capitalize[0]
      self.define_singleton_method(name.downcase) do |req_options = {}|#| wilds = {}, req_options = {}|
        RequestHandler.new(self, name, method_and_url, options, req_options).promise
      end
    else
      #route :save, post: "pages/:id", defaults: [:id]
      self.define_method(name) do |req_options = {}|#|wilds = {}, req_options = {}|
        RequestHandler.new(self, name, method_and_url, options, req_options).promise
      end
    end
  end
#######MODEL WIDE RESPONSES TODO: add all REST methods and move to module

  def on_before_create(r)
    r.req_options = {payload: pure_attributes}
  end

  def responses_on_create(r)
    if r.response.ok?
      self.update_attributes(r.response.json[self.class.name.to_snake_case])
      self.validate
      r.promise.resolve self
    end
  end

  def self.responses_on_new_resource(r)
    if r.response.ok?
      r.promise.resolve Model.parse(r.response.json)
    end
  end

  def self.responses_on_index(r)
    if r.response.ok?
      r.promise.resolve self.parse(r.response.json)
    end
  end

  def responses_on_destroy(r)
    if r.response.ok?
      r.promise.resolve Model.parse(r.response.json)
    end
  end

  def self.responses_on_show(r)
    if r.response.ok?
      r.promise.resolve Model.parse(r.response.json)
    end
  end

  def self.responses_on_edit(r)
     self.responses_on_show(r)
  end

  def on_before_update(r)
    r.req_options = {payload: pure_attributes}
  end

  def responses_on_update(r)
    if r.response.ok?
      self.update_attributes(r.response.json[self.class.name.to_snake_case])
      self.validate
      r.promise.resolve self
    end
  end




#                       __   __  _______  ___      ___   ______   _______  _______  ___   _______  __    _
#                      |  | |  ||   _   ||   |    |   | |      | |   _   ||       ||   | |       ||  |  | |
#                      |  |_|  ||  |_|  ||   |    |   | |  _    ||  |_|  ||_     _||   | |   _   ||   |_| |
#                      |       ||       ||   |    |   | | | |   ||       |  |   |  |   | |  | |  ||       |
#                      |       ||       ||   |___ |   | | |_|   ||       |  |   |  |   | |  |_|  ||  _    |
#                       |     | |   _   ||       ||   | |       ||   _   |  |   |  |   | |       || | |   |
#                        |___|  |__| |__||_______||___| |______| |__| |__|  |___|  |___| |_______||_|  |__|

#that big letter are not for lulz, they are for easily navigate with that sublime all code view feature ;)
  #TODO: MOVE TO SEPARATE MODULE

  attr_accessor :errors
  #every model must have errors

  ############HAS FILE meths
  def has_file
    @file ||= false
  end

  def has_file=(value)
    @file = value
  end

  def serialize_attributes_as_form_data
    form_data = Native(`new FormData()`)
    self.class.iterate_for_form(self.pure_attributes, form_data)
  end

  def self.has_file
    false
    #for class routes methods todo: need some other wat
  end
  #this has file stuff is needed for cases when your model has collected file and wants to send it
  #to backend. The only way (for xhr of course) is to serialize it's attrs including file holding ones to formModel
  #that serialization is unnecessary job if model doesn't hold file, of course you could do everything manually but what for?
  #if your model has file holding attr, it will run validate_file_holing attribute, and that validate method has to set has_file to true
  #in validate method reset_errors will also assign has_file a false value
  #HTTP handler will check for that shit in initialize and will call model to serialize it's attrs to form and
  #will assign data: that_serialized_form.
  #this serialize_attributes_for_form_data can be in use elsewhere if you'll needed.

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
      if v.is_a? Array
        v.each do |c|
          c.reset_errors if c.is_a? Model
        end
      end
    end
    @errors = {}
  end

  def validate(options = {only: []})
    self.reset_errors
    self.has_file = false
    #for this method refer to itself; needed for serializing to automatic serialization to formData
    @attributes.each do |k, v|
      unless options[:only].empty?
        next unless options[:only].include? k
      end
      if v.is_a? Array
        v.each do |m|
          if m.is_a? Model
            m.validate
            if m.has_errors?
              @errors[:nested_errors] = true
            end
          end
        end
      elsif v.is_a? Model
        v.validate
        if v.has_errors?
          @errors[:nested_errors] = true
        end
      else
        self.send("validate_#{k}") if self.respond_to? "validate_#{k}"
        #p (self.respond_to? "validate_#{k}") ? "has validation method #{k}" : "doesn't have validation method #{k}"
        @errors ||= {}
        @errors.merge!(self.attributes[:errors] ||= {})
        self.attributes[:errors] = {}
        #in case errors teturned from server, but no validation rules for it on fronts
      end
    end
  end
  #attr_name model : Model <attr_name>, error : String
  #this method is called in validate_#{attr_name} method if your
  #attr has errors and you need to add it, but youre free to not use it
  #refer to important! notice
  def add_error(attr_name, error)
    (@errors[attr_name] ||= []) << error
  end

  ####
  #IMPORTANT!
  #your model should implement validate_attr_name for the attr you need to validate
  #this method should recieve optional option : Hash arg
  #and it should result in either add_error(:attr_name, "bad error")
  #or doing it manually, example
  #def validate_name
  # if name.length < 8
  #   add_error :name, "too short"
  # end
  #end
  #for convinience errors are assumed to have structure
  #repeating it's attributes hash
  #model.attributes => {name: "foo"}
  #model.validate
  #model.errors => {name: ["too short"]}
  #model.attributes => {name: "foo"}

  #-----------------END VALIDATION============

end



class ModelCollection
  #you will get it if will pass array of models to Model.parse
  include Enumerable
  attr_accessor :data
  def initialize(data = [])
    data.map! do |val|
      Model.parse(val)
    end
    @data = data
    init
  end

  def init

  end

  def where(&block)
    s = []
    @data.each do |v|
      next unless v.is_a?(Model)
      if v.is_a? Model
        s << v if yield(v) #previously was v.attributes; changed beacause sometimes yo'll need to check on their methods not only attributes
        s = s + v.where {block.call}
      end
    end
    s
  end

  def <<(val)
      @data << val
  end

  def +(val)
    @data + val
  end

  def each(&block)
      @data.each(&block)
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
end


=begin
       ______    _______  _______  __   __  _______  _______  _______    __   __  _______  __    _  ______   ___      _______  ______
      |    _ |  |       ||       ||  | |  ||       ||       ||       |  |  | |  ||   _   ||  |  | ||      | |   |    |       ||    _ |
      |   | ||  |    ___||   _   ||  | |  ||    ___||  _____||_     _|  |  |_|  ||  |_|  ||   |_| ||  _    ||   |    |    ___||   | ||
      |   |_||_ |   |___ |  | |  ||  |_|  ||   |___ | |_____   |   |    |       ||       ||       || | |   ||   |    |   |___ |   |_||_
      |    __  ||    ___||  |_|  ||       ||    ___||_____  |  |   |    |       ||       ||  _    || |_|   ||   |___ |    ___||    __  |
      |   |  | ||   |___ |      | |       ||   |___  _____| |  |   |    |   _   ||   _   || | |   ||       ||       ||   |___ |   |  | |
      |___|  |_||_______||____||_||_______||_______||_______|  |___|    |__| |__||__| |__||_|  |__||______| |_______||_______||___|  |_|
=end

class RequestHandler
  #handles your HTTP requests!!! Really! this get's started from your Model.route method, look there

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
    if @caller.respond_to?("on_before_#{@name.downcase}") && !@skip_before_handler
      @caller.send "on_before_#{@name.downcase}", self
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

    ##@req_options[:on_progress] of Proc can be also passed, if passed xhr will fire passed proc on xhr.upload.onprogress when
    #being sent (refer to opal jquery HTTP#send in monkey patch)

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
      elsif @caller.respond_to? "responses_on_#{@name.downcase}"
        @caller.send "responses_on_#{@name.downcase}", self
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

  def defaults_before_request

  end

end

=begin JS
class Model {

  static hasMany(...args) {

    args.forEach((v, i) => {

      this.nestedAttributes[v] = []
      this.attributes(v)

    })

  }



  static hasOne(...args) {

    args.forEach((v, i) => {

      this.associationList[v] = {}
      this.attributes(v)

    })

  }



  static acceptsNestedAttributesFor(...args) {

    args.forEach((v, i)=>{

      this.nestedAttributes[v] = this.associationList[v]

    })

  }



  static parse(data) {

    if (typeof data === 'string') {
      data = JSON.parse(data)
    }

    var objectifiedData = this.objectify(data)

    if (objectifiedData && Array === objectifiedData.constructor) {

      return new ModelCollection(data)

    }

    return(
      objectifiedData
    )

  }



  static objectify(data, className = 'model'/*, objectifyModel = null*/) {

    data = this.objectifyIfArray(data)

    data = this.objectifyIfSingleModel(data)

    if (_.isPlainObject(data)/*typeof data == 'object' && !(data instanceof Model) && !(Array === data.constructor)*/) {
      data = this.objectifyFromModel(data)
    }

    return data

  }



  static objectifyIfArray(data) {

    if (_.isArray(data)/*data && Array === data.constructor*/) {
      data.map((value) => {
        return this.objectify(value)
      })
    }

    return data

  }



  static objectifyIfSingleModel(data) {

    if(_.isPlainObject(data)/*typeof data === 'object' && !(data.constructor === Array) && !(data instanceof Model)*/){

      var dataKeys = Object.keys(data)

      if (typeof data === 'object' && dataKeys.length === 1) {

        if (Model.isRegisteredModel(dataKeys[0])) {

          data = new Model.registry[dataKeys[0]](data[dataKeys[0]])

        } else {

          data[ dataKeys[0] ] = this.objectify(data[ dataKeys[0] ])

        }
      }

    }

    return data

  }


  static objectifyFromModel(data) {

    this.handleSpecificallySelected(data)

    for (let prop in data) {
      data[prop] = this.objectify(data[prop])
    }

    for (let prop in data) {
      if (prop.substr(0, 3) === 'sj_' || prop.substr(0, 3) === 'si_') {
        delete data[prop]
      }
    }

    return data

  }

  static handleSpecificallySelected(data){

    for (let prop in data) {

      if (prop.substring(0, 3) == 'sj_'){

        var splitted = prop.split('1')
        var name = splitted[0].substring(3).split('2')

        var attributeName = ''
        for (let i = 1; i < splitted.length; i++){
          atributeName = attributeName + splitted[i] + '1'
        }

        if (name[1]) {

          let x = data[name[0]] = data[name[0]] || {}
          x = x[name[1]] = x[name[1]] || {}
          x[attributeName] = data[prop]

        } else {

          let x = data[name[0]] = data[name[0]] || {}
          x = x[name[0]] = x[name[0]] || {}
          x[attributeName] = data[prop]

        }

      } else if (prop.substring(0, 3) === 'si_'){

        var splitted = prop.split('1')

        var name = name || splitted[0].substring(3)

        data[name] = data[prop]

      }

    }

  }



  constructor(data = {}){

    data = this.constructor.objectify(data)

    this.attributes = data

    this.initialize()

  }



  pureAttributes( root = true ){

    var x = {}

    delete this.attributes['errors']

    _(this.attributes).each((v , k)=>{

      if(_.has(this.constructor.nestedAttributes, `${k}_attributes`)){

        if( !_.isEmpty(x[`${k}_attributes`]) ){

          x[`${k}_attributes`] = this.normalizeAttributes(v, false)

        }

      } else {

        x[k] = this.normalizeAttributes(v)

      }
    })

    if (root) {
      let z = {}

      z[this.constructor.modelName] = x

      return z

    } else {

      return x

    }



  }



  normalizeAttributes(attrs, root = true){

    if ( _.isPlainObject(attrs) ) {

      _(attrs).each((v, k)=>{

        if (v instanceof Model) {

          attrs[k] = v.attributes

        } else {

          attrs[k] = this.normalizeAttributes(v)

        }

      })

    } else if ( _.isArray(attrs) ) {

      attrs = _.map(attrs, (val, index)=>{

        this.normalizeAttributes(val, root)

      })

      return attrs

    } else if ( attrs instanceof Model ) {

      return attrs.pureAttributes(root)

    } else {

      return attrs

    }

  }



  static route(name, methodAndUrl, options = {}) {

    if (name[0]  === name[0].toUpperCase()) {

      this[name.toLowerCase()] = function(requestOptions) { /*TODO toLowerCase only 0th char*/

        let x = new RequestHandler(this, name, methodAndUrl, options, requestOptions)

        return x.promise

      }

    } else {

      this.prototype[name] = function(requestOptions){

        let x = new RequestHandler(this, name, methodAndUrl, options, requestOptions)

        return x.promise

      }

    }

  }

  static registerModel(model){
    this.registry[model.modelName] = model
  }

  static isRegisteredModel(modelName){
    if(modelName in this.registry){
     return true
    }
  }

  initialize(){

  }

}

//Static properties
Model.attributesList = []

Model.nestedAttributes = {}

Model.associationList = {}

Model.registry = {}

class RequestHandler {

  constructor(caller, name, methodAndUrl, options, reqOptions = {}){

    this.caller = caller
    this.name = name
    this.options = options
    this.wilds = reqOptions['wilds'] || {}
    this.component = reqOptions['component']
    this.shouldYieldResponse = reqOptions['yieldResponse']
    this.skipBeforeHandler = reqOptions['skipBeforeHandler']

    let namespace = reqOptions['namespace']
    this.url = this.prepareHttpUrlForMethod(methodAndUrl, namespace)

    this.httpMethod = _.keys(methodAndUrl)[0]
    let beforeRequestMethodName = `before${this.name.substr(0, 1).toUpperCase() + this.name.substr(1)}`
    if (this.caller[beforeRequestMethodName] && !this.skipBeforeHandler){

      this.caller[beforeRequestMethodName](this)

    }

    this.reqOptions = this.reqOptions || {}
    this.reqOptions.contentType = 'application/json'
    this.extraParams = {}

    if (reqOptions['extraParams']) {

      this.extraParams = reqOptions['extraParams']
      _.merge(this.reqOptions, this.extraParams)

    }



    if (reqOptions['data']) {

      this.reqOptions = reqOptions

    } else if ( this.caller.hasFile || reqOptions['serializeAsForm'] ){

      this.skipBeforeHandler = true
      this.caller.updateAttributes(this.extraParams)
      this.reqOptions['data'] = this.caller.serializeAttributesAsFormData()
      if (_.has(this.reqOptions, 'payload')){

        delete this.reqOptions['payload']

      }
      this.reqOptions['processData'] = false
      this.reqOptions['contentType'] = false

    } else {

      let x = this.reqOptions['payload'] = this.reqOptions['payload'] || {}
      _.merge(x, this.extraParams)

    }
    this.reqOptions['method'] = this.httpMethod
    this.reqOptions['url'] = this.url

    this.sendRequest()

  }

  /*sendRequest(){

    console.log('--------')
    console.log(this.caller)
    console.log(this.name)
    console.log(this.options)
    console.log(this.wilds)
    console.log(this.component)
    console.log(this.shouldYieldResponse)
    console.log(this.skipBeforeHandler)
    console.log(this.url)
    console.log(this.httpMethod)
    console.log(this.reqOptions)
    console.log(this.extraParams)
    console.log('--------')

 }*/



  prepareHttpUrlForMethod(methodAndUrl, namespace){

    let mAUKeys = Object.keys(methodAndUrl)[0]

    var url = methodAndUrl[ mAUKeys ].split('/')

    url = url.map((part, i)=>{

      if (part[0] === ':') {

        var wildKey = part.substring( 1/*, part.length*/ )
        var x = this.wilds[wildKey]
        if (x){
          return x
        } else if ( _.isArray(this.options.defaults) && _.findIndex(this.options.defaults, wildKey)) {

          return this.caller.attributes[wildKey]

        }
      } else {
        return part
      }

    })

    if(namespace){
      url.unshift(namespace)
    }

    url.unshift('api')

    return `/${url.join('/')}`

  }


  sendRequest(){
    this.promise = new WrappedPromise()
    //this.defaultsBeforeRequest()

    $.ajax(this.reqOptions).done((data)=>{
      this.promise.resolve(data)
    })

    return this.promise
  }

}


class WrappedPromise{

  constructor(){
    this.promise = new Promise((resolve, reject)=>{
      this.resolve = resolve
      this.reject = reject
    })
  }

  resolve(...args){
    this.promise.resolve(...args)
  }

  reject(...args){
    this.promise.reject(...args)
  }

  then(...args){
    this.promise.then(...args)
    return this.promise
  }

  catch(...args){
    this.promise.catch(...args)
    return this.promise
  }

}


class User extends Model {

   beforeIndex(r){
    console.log('default before')
    r.reqOptions = {data: this.pureAttributes()}
  }

}

User.modelName = 'user'

User.route('index', {post: 'users/:id', defaults: 'id'}, {defaults: ['id']})

User.route('Index', {get: 'users/foo/:bar/:baz'})

Model.registerModel(User)


var x = {user: {si_friend1id_name: {user: {name: 'joe'}}}}
x = Model.parse(x)
x.attributes.id = 2

x.index()
//User.index({wilds: {foo: 'foo', bar: 'bar'}}).then((foo)=>{console.log(foo)})

=end
