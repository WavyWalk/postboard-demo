
=begin

For safe custom additions there either monkey pathcing in /vendor/core_monkeypatches or createing a plugin includable in component preferred.
You can monkey patch RW, Model there.

=end
# some poetry to begin with:
#
# I thought you were reserved keyword in language
# A constant in a clsss named Love you where for me
# Now analyzing trace, I know you're antipattern
# A variable, that my class named Heart, just couldn't free

class RW



  class << self
    #just dasherizes your class name
    def native_name
      @native_name ||= self.name.split('::').join('_') # that face is looking right in your soul
    end

  end

  def unique_name
    return "#{self}"[1..-1]
  end

  #needed to be called in every component. Makes it available from pure javascript env
  def self.expose
    `window[#{native_name}] = #{self.create_class}`
  end



  def initialize(native)
    @native = native
    #to not fuck with calling super just use init method instead of initialize
    init
    #refer to #validate_props for info
    validate_props
  end

  #decided to use this for props validation instead of react's default. The validate_props should be implemented the way you want.
  #well validating them the way in react is impossible
  #but with ruby it's just a breeze. Just implement your validations the PORO way you want e.g.:
  # def prop_named(prop_name, coditional, *options)
  #   case conditional
  #   when :should_be_of_class
  #     _p_v_should_be_of_class(prop_name, *options)
  #   else
  #     raise "#{self} of #{self.class.name} prop validation unknown condition: #{conditional}"
  #   end
  # end
  #
  # def _p_v_should_be_of_class(prop_name, class_to_test)
  #   unless props[prop_name].is_a?(class_to_test)
  #     raise "#{self} of #{self.class.name}: prop #{prop_name} expected to be of class #{class_to_test}. instead got: #{props[prop_name]} of #{props[prop_name].class.name}"
  #   end
  # end
  #
  #so you can use it like this
  #def validate_props
  #  prop_named :user, :should_be_of_class, User
  #end

  def validate_props

  end

  #called in initialize. Used for:
  #not breaking stuff when you want to use initialize
  #use this instead
  def init

  end

  def self.default_props

  end

  #of course it could be just to_n'ed. but that way some undesired values of your hash will be to_n'ed
  #as well. This way types are guaranteed to be passed as they where defined
  #Get initial state ONLY STRING KEYS SHALL BE PASSED!
  def __get_initial_state__
    `var result = {}`
    if hash = self.get_initial_state
      %x{
        
        var result = {},
        keys = #{hash}.$$keys,
        smap = #{hash}.$$smap,
          key, value;

        for (var i = 0, length = keys.length; i < length; i++) {
          key = keys[i];

          //if (key.$$is_string) {
            value = smap[key];
          //} else {
          //  key = key.key;
          //  value = key.value;
          //}

          result[key] = value;
        }
        
      }
    end
    `return result`
  end

  def get_initial_state

  end

  def component_will_mount

  end

  def component_did_mount

  end

  def __component_will_unmount__
    component_will_unmount
  end

  def component_will_unmount

  end

  def __component_will_update__(next_props, next_state)
    component_will_update(next_props, next_state)
  end

  def component_will_update(next_props, next_state)

  end

  def __should_component_update__(next_props, next_state)
    should_component_update(next_props, next_state)
  end

  def should_component_update(next_props, next_state)
    true
  end

  def __component_will_receive_props__(next_props)
    component_will_receive_props(Native(next_props))
  end

  def component_will_receive_props(next_props)

  end

  def __component_did_update__(prev_props, prev_state)
    component_did_update(Native(prev_props), Native(prev_state))
  end

  def component_did_update(prev_props, prev_state)

  end

  def self.create_class()
    (%x{
        React.createClass({
          getDefaultProps: function(){
            return #{self.default_props.to_n};
          },
          getInitialState: function(){
            this.rb = #{self.new(`this`)}
            return #{`this.rb.$__get_initial_state__()`};
          },
          componentWillMount: function() {
            return this.rb.$component_will_mount();
          },
          componentDidMount: function() {
            return this.rb.$component_did_mount();
          },
          componentWillReceiveProps: function(next_props) {
            return this.rb.$__component_will_receive_props__(next_props);
          },
          shouldComponentUpdate: function(next_props, next_state) {
            return this.rb.$__should_component_update__(next_props, next_state);
          },
          componentWillUpdate: function(next_props, next_state) {
            return this.rb.$__component_will_update__(next_props, next_state);
          },
          componentDidUpdate: function(prev_props, prev_state) {
            return this.rb.$__component_did_update__(prev_props, prev_state);
          },
          componentWillUnmount: function() {
            return this.rb.$__component_will_unmount__();
          },
          displayName: #{self.to_s},
          render: function() {
            return this.rb.$render();
          }
        })
    })
  end

  def render

  end

  def props
    Native(`#{@native}.props`)
  end

  def n_prop(accessor)
    `#{@native}.props[#{accessor}]`
  end

  def n_props
    @native.JS.props
  end

  def props_to_h(prop)
    Hash.new(`#{@native.to_n}.props[#{prop}]`)
  end

  def state
    Native(`#{@native}.state`)
  end

  def n_state(key)
    `#{@native}.state[#{key}]`
  end

  def rw_state
    @rw_state ||= RW_state.new(`#{@native}.state`)
  end

  def state_to_h
    Hash.new(state.to_n)
  end

  def ref(ref)
    Native(`#{@native}.refs[#{ref}]`)
  end

  #access ref without wrapping
  def n_ref(ref)
    `#{@native}.refs[#{ref}]`
  end

  def n_refs
    `#{@native}.refs`
  end

  def n_refs_each(&block)
      `
        Object.keys(#{@native}.refs).forEach(function(key) {

          #{yield(`key`, `#{@native}.refs[key]`)};
        
        });
      `
  end

  def refs
    Hash.new `#{@native}.refs`
  end

  def children
    n_prop(:children)
  end

  def set_state(val)
    __set_state__(val)
    `var x = {}`
    val.each do |k,v|
      `x[#{k}] = v`
    end
    `#{@native}.setState(x)`
  end

  def n_set_state(val)
    `#{@native}.setState(#{val})`
  end

  def __set_state__(val)

  end


  def t(_klass, _props, *args)

    #t is short for tag
    #creates react element
#=begin
#Some shit must be changed in react library
#in traverseAllChildrenImpl function
#
#  function traverseAllChildrenImpl(children, nameSoFar, callback, traverseContext) {
#  var type = typeof children;
#
#  if (type === 'undefined' || type === 'boolean' || children === Opal.nil) { <<<<<<<<< || children === Opal.nil was added
#    // All of the above are perceived as null.
#    children = null;
#  }

# THE MINIFIED REACT FOR EASIER FIND
# function r(e, t) {
#         return e && "object" == typeof e && null != e.key ? l.escape(e.key) : t.toString(36)
# }

# function o(e, t, n, a) {
#   var d = typeof e;
#   if ("undefined" !== d && "boolean" !== d /*>> && Opal.nil !== e <<*/ || (e = null), null === e || "string" === d || "number" === d || i.isValidElement(e)) return n(a, e, "" === t ? c + r(e, 0) : t), 1;
#   var f, h, v = 0,
#     m = "" === t ? c : t + p;

#
#THE REASON BEHIND:
#before args were compacted! to remove nils (e.g. if in render there was and if statement which returned nil)
#I thought that it's bad to traverse all children each time, so instead I altered react itself.
#That's a little hack and I don't think it'll be hard to do with further coming versions of React, beacuse even if
#traverseAllChildrenImpl be implemented in other way there would easily be place for checking if child is Opal.nil
#if you don't want to mess with react core simply uncomment params.compact!

#=end
    unless _klass.is_a? String
      _klass = `window[#{_klass.native_name}]` unless _klass.is_a?(Proc)
    end

    `var x = {}`
    _props.each do |k,v|
      `x[#{k}] = #{v}`
    end

    if args.empty?
      params = `[#{_klass}, x]`
    else
      #params = [_klass, `x`, *args] #< previous in case if breaks
      params = `[#{_klass}, x, #{args}]`
    end
    #params.compact!
    (%x{
      React.createElement.apply(null, #{params})
    })
  end

  def force_update
    `#{@native}.forceUpdate()`
  end


#props as procs
#for some reason in some cases if prop is assigned with proc it's being lost when passed to children
#for this reason ProcEvent class will act as container for proc (for props event)
#as extra plus it gives more explicity for events as well can be enriched with features
#also it can be changed anyway needed cause only event emit accessed so it's basically adapterable of some sort.
  def event(proc)
    ProcEvent.new(proc)
  end

  def emit(prop_name, *args)
    if n_prop(prop_name)
      n_prop(prop_name).call(*args)
    else
      p "WARNING #{self.class.name} emiting #{prop_name} but no prop #{prop_name} : Event was passed"
    end
  end

  class ProcEvent
    def initialize(proc)
      @proc = proc
    end

    def call(*args)
      @proc.call(*args)
    end
  end
# END props as procs
  #wrapper for RW#rw_state
  class RW_state

    def initialize(state)
      @state = state
    end

    def [](val)
      @state.JS[val]
    end

    def []=(i, v)
      @state.JS[i] = v
    end

  end
end
