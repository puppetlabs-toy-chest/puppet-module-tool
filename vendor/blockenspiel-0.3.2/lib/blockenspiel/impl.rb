# -----------------------------------------------------------------------------
# 
# Blockenspiel implementation
# 
# -----------------------------------------------------------------------------
# Copyright 2008-2009 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


require 'thread'


# == Blockenspiel
# 
# The Blockenspiel module provides a namespace for Blockenspiel, as well as
# the main entry point method "invoke".

module Blockenspiel
  
  
  # Base exception for all exceptions raised by Blockenspiel 
  
  class BlockenspielError < ::RuntimeError
  end
  
  
  # This exception is rasied when attempting to use the <tt>:proxy</tt> or
  # <tt>:mixin</tt> parameterless behavior with a target that does not have
  # the DSL module included. It is an error made by the DSL implementor.
  
  class DSLMissingError < ::Blockenspiel::BlockenspielError
  end
  
  
  # This exception is raised when the block provided does not take the
  # expected number of parameters. It is an error made by the caller.
  
  class BlockParameterError < ::Blockenspiel::BlockenspielError
  end
  
  
  # === DSL setup methods
  # 
  # These class methods are available after you have included the
  # Blockenspiel::DSL module.
  # 
  # By default, a class that has DSL capability will automatically make
  # all public methods available to parameterless blocks, except for the
  # +initialize+ method, any methods whose names begin with an underscore,
  # and any methods whose names end with an equals sign.
  # 
  # If you want to change this behavior, use the directives defined here to
  # control exactly which methods are available to parameterless blocks.
  
  module DSLSetupMethods
    
    
    # :stopdoc:
    
    # Called when DSLSetupMethods extends a class.
    # This sets up the current class, and adds a hook that causes
    # any subclass of the current class also to be set up.
    
    def self.extended(klass_)
      unless klass_.instance_variable_defined?(:@_blockenspiel_module)
        _setup_class(klass_)
        def klass_.inherited(subklass_)
          ::Blockenspiel::DSLSetupMethods._setup_class(subklass_)
          super
        end
        class << klass_
          unless private_method_defined?(:_blockenspiel_default_include)
            alias_method :_blockenspiel_default_include, :include
            alias_method :include, :_blockenspiel_custom_include
          end
        end
      end
    end
    
    # :startdoc:
    
    
    # Set up a class.
    # Creates a DSL module for this class, optionally delegating to the superclass's module.
    # Also initializes the class's methods hash and active flag.
    
    def self._setup_class(klass_)  # :nodoc:
      superclass_ = klass_.superclass
      superclass_ = nil unless superclass_.respond_to?(:_get_blockenspiel_module)
      mod_ = ::Module.new
      if superclass_
        mod_.module_eval do
          include superclass_._get_blockenspiel_module
        end
      end
      klass_.instance_variable_set(:@_blockenspiel_superclass, superclass_)
      klass_.instance_variable_set(:@_blockenspiel_module, mod_)
      klass_.instance_variable_set(:@_blockenspiel_methods, ::Hash.new)
      klass_.instance_variable_set(:@_blockenspiel_active, nil)
    end
    
    
    # Automatically make the given method a DSL method according to the current setting.
    
    def _blockenspiel_auto_dsl_method(symbol_)  # :nodoc:
      if @_blockenspiel_active
        dsl_method(symbol_)
      elsif @_blockenspiel_active.nil?
        if symbol_ != :initialize && symbol_.to_s !~ /^_/ && symbol_.to_s !~ /=$/
          dsl_method(symbol_)
        end
      end
    end
    
    
    # Hook called when a method is added.
    # This calls _blockenspiel_auto_dsl_method to auto-handle the method,
    # possibly making it a DSL method according to the current setting.
    
    def method_added(symbol_)  # :nodoc:
      _blockenspiel_auto_dsl_method(symbol_)
      super
    end
    
    
    # Custom include method. Calls the main include implementation, but also
    # goes through the public methods of the included module and calls
    # _blockenspiel_auto_dsl_method on each to make them DSL methods
    # (possibly) according to the current setting.
    
    def _blockenspiel_custom_include(*modules_)  # :nodoc:
      _blockenspiel_default_include(*modules_)
      modules_.reverse_each do |mod_|
        mod_.public_instance_methods.each do |method_|
          _blockenspiel_auto_dsl_method(method_)
        end
      end
    end
    
    
    # Get this class's corresponding DSL module
    
    def _get_blockenspiel_module  # :nodoc:
      @_blockenspiel_module
    end
    
    
    # Get information on the given DSL method name.
    # Possible values are the name of the delegate method, false for method disabled,
    # or nil for method never defined.
    
    def _get_blockenspiel_delegate(name_)  # :nodoc:
      delegate_ = @_blockenspiel_methods[name_]
      if delegate_.nil? && @_blockenspiel_superclass
        @_blockenspiel_superclass._get_blockenspiel_delegate(name_)
      else
        delegate_
      end
    end
    
    
    # Make a particular method available to parameterless DSL blocks.
    # 
    # To explicitly make a method available to parameterless blocks:
    #  dsl_method :my_method
    # 
    # To explicitly exclude a method from parameterless blocks:
    #  dsl_method :my_method, false
    # 
    # To explicitly make a method available to parameterless blocks, but
    # point it to a method of a different name on the target class:
    #  dsl_method :my_method, :target_class_method
    
    def dsl_method(name_, delegate_=nil)
      name_ = name_.to_sym
      if delegate_
        delegate_ = delegate_.to_sym
      elsif delegate_.nil?
        delegate_ = name_
      end
      @_blockenspiel_methods[name_] = delegate_
      unless @_blockenspiel_module.public_method_defined?(name_)
        @_blockenspiel_module.module_eval("def #{name_}(*params_, &block_); val_ = ::Blockenspiel._target_dispatch(self, :#{name_}, params_, block_); ::Blockenspiel::NO_VALUE.equal?(val_) ? super(*params_, &block_) : val_; end\n")
      end
    end
    
    
    # Control the behavior of methods with respect to parameterless blocks,
    # or make a list of methods available to parameterless blocks in bulk.
    # 
    # To enable automatic exporting of methods to parameterless blocks.
    # After executing this command, all public methods defined in the class
    # will be available on parameterless blocks, until
    # <tt>dsl_methods false</tt> is called:
    #  dsl_methods true
    # 
    # To disable automatic exporting of methods to parameterless blocks.
    # After executing this command, methods defined in this class will be
    # excluded from parameterless blocks, until <tt>dsl_methods true</tt>
    # is called:
    #  dsl_methods false
    # 
    # To make a list of methods available to parameterless blocks in bulk:
    #  dsl_methods :my_method1, :my_method2, ...
    # 
    # You can also point dsl methods to a method of a different name on the
    # target class, by using a hash syntax, as follows:
    #  dsl_methods :my_method1 => :target_class_method1,
    #              :my_method2 => :target_class_method2
    # 
    # You can mix non-renamed and renamed method declarations as long as
    # the renamed (hash) methods are at the end. e.g.:
    #  dsl_methods :my_method1, :my_method2 => :target_class_method2
    
    def dsl_methods(*names_)
      if names_.size == 0 || names_ == [true]
        @_blockenspiel_active = true
      elsif names_ == [false]
        @_blockenspiel_active = false
      else
        if names_.last.kind_of?(::Hash)
          names_.pop.each do |name_, delegate_|
            dsl_method(name_, delegate_)
          end
        end
        names_.each do |name_|
          dsl_method(name_, name_)
        end
      end
    end
    
    
    # A DSL-friendly attr_accessor.
    # 
    # This creates the usual "name" and "name=" methods in the current
    # class that can be used in the usual way. However, its implementation
    # of the "name" method (the getter) also takes an optional parameter
    # that causes it to behave as a setter. This is done because the usual
    # setter syntax cannot be used in a parameterless block, since it is
    # syntactically indistinguishable from a local variable assignment.
    # The "name" method is exposed as a dsl_method.
    # 
    # For example:
    # 
    #  dsl_attr_accessor :foo
    # 
    # enables the following:
    # 
    #  my_block do |param|
    #    param.foo = 1   # Usual setter syntax works
    #    param.foo 2     # Alternate setter syntax also works
    #    puts param.foo  # Usual getter syntax still works
    #  end
    #  
    #  my_block do
    #    # foo = 1       # Usual setter syntax does NOT work since it
    #                    #   looks like a local variable assignment
    #    foo 2           # Alternate setter syntax does work
    #    puts foo        # Usual getter syntax still works
    #  end
    
    def dsl_attr_accessor(*names_)
      names_.each do |name_|
        unless name_.kind_of?(::String) || name_.kind_of?(::Symbol)
          raise ::TypeError, "#{name_.inspect} is not a symbol"
        end
        unless name_.to_s =~ /^[_a-zA-Z]\w+$/
          raise ::NameError, "invalid attribute name #{name_.inspect}"
        end
        module_eval("def #{name_}(value_=::Blockenspiel::NO_VALUE); ::Blockenspiel::NO_VALUE.equal?(value_) ? @#{name_} : @#{name_} = value_; end\n")
        alias_method("#{name_}=", name_)
        dsl_method(name_)
      end
    end
    
    
    # A DSL-friendly attr_writer.
    # 
    # This creates the usual "name=" method in the current class that can
    # be used in the usual way. However, it also creates the method "name",
    # which also functions as a setter (but not a getter). This is done
    # because the usual setter syntax cannot be used in a parameterless
    # block, since it is syntactically indistinguishable from a local
    # variable assignment. The "name" method is exposed as a dsl_method.
    # 
    # For example:
    # 
    #  dsl_attr_writer :foo
    # 
    # is functionally equivalent to:
    # 
    #  attr_writer :foo
    #  alias_method :foo, :foo=
    #  dsl_method :foo
    # 
    # which enables the following:
    # 
    #  my_block do |param|
    #    param.foo = 1   # Usual setter syntax works
    #    param.foo 2     # Alternate setter syntax also works
    #  end
    #  my_block do
    #    # foo = 1       # Usual setter syntax does NOT work since it
    #                    #   looks like a local variable assignment
    #    foo(2)          # Alternate setter syntax does work
    #  end
    
    def dsl_attr_writer(*names_)
      names_.each do |name_|
        attr_writer(name_)
        alias_method(name_, "#{name_}=")
        dsl_method(name_)
      end
    end
    
    
  end
  
  
  # === DSL activation module
  # 
  # Include this module in a class to mark this class as a DSL class and
  # make it possible for its methods to be called from a block that does not
  # take a parameter.
  # 
  # After you include this module, you can use the directives defined in
  # DSLSetupMethods to control what methods are available to DSL blocks
  # that do not take parameters.
  
  module DSL
    
    def self.included(klass_)  # :nodoc:
      unless klass_.kind_of?(::Class)
        raise ::Blockenspiel::BlockenspielError, "You cannot include Blockenspiel::DSL in a module (yet)"
      end
      klass_.extend(::Blockenspiel::DSLSetupMethods)
    end
    
  end
  
  
  # === DSL activation base class
  # 
  # Subclasses of this base class are considered DSL classes.
  # Methods of the class can be made available to be called from a block that
  # doesn't take an explicit block parameter.
  # You may use the directives defined in DSLSetupMethods to control how
  # methods of the class are handled in such blocks.
  # 
  # Subclassing this base class is functionally equivalent to simply
  # including Blockenspiel::DSL in the class.
  
  class Base
    
    include ::Blockenspiel::DSL
    
  end
  
  
  # Class for proxy delegators.
  # The proxy behavior creates one of these delegators, mixes in the dsl
  # methods, and uses instance_eval to invoke the block. This class delegates
  # non-handled methods to the context object.
  
  class ProxyDelegator  # :nodoc:
    
    def method_missing(symbol_, *params_, &block_)
      ::Blockenspiel._proxy_dispatch(self, symbol_, params_, block_)
    end
    
  end
  
  
  # === Dynamically construct a target
  # 
  # These methods are available in a block passed to Blockenspiel#invoke and
  # can be used to dynamically define what methods are available from a block.
  # See Blockenspiel#invoke for more information.
  
  class Builder
    
    include ::Blockenspiel::DSL
    
    
    # This is a base class for dynamically constructed targets.
    # The actual target class is an anonymous subclass of this base class.
    
    class Target  # :nodoc:
      
      include ::Blockenspiel::DSL
      
      
      # Add a method specification to the subclass.
      
      def self._add_methodinfo(name_, block_, yields_)
        (@_blockenspiel_methodinfo ||= ::Hash.new)[name_] = [block_, yields_]
        module_eval("def #{name_}(*params_, &block_); self.class._invoke_methodinfo(:#{name_}, params_, block_); end\n")
      end
      
      
      # Attempt to invoke the given method on the subclass.
      
      def self._invoke_methodinfo(name_, params_, block_)
        info_ = @_blockenspiel_methodinfo[name_]
        case info_[1]
        when :first
          params_.unshift(block_)
        when :last
          params_.push(block_)
        end
        info_[0].call(*params_, &block_)
      end
      
    end
    
    
    # Sets up the dynamic target class.
    
    def initialize  # :nodoc:
      @target_class = ::Class.new(::Blockenspiel::Builder::Target)
      @target_class.dsl_methods(false)
    end
    
    
    # Creates a new instance of the dynamic target class
    
    def _create_target  # :nodoc:
      @target_class.new
    end
    
    
    # === Declare a DSL method.
    # 
    # This call creates a method that can be called from the DSL block.
    # Provide a name for the method, a block defining the method's
    # implementation, and an optional hash of options.
    # 
    # By default, a method of the same name is also made available to
    # parameterless blocks. To change the name of the parameterless method,
    # provide its name as the value of the <tt>:dsl_method</tt> option.
    # To disable this method for parameterless blocks, set the
    # <tt>:dsl_method</tt> option to +false+.
    # 
    # The <tt>:mixin</tt> option is a deprecated alias for
    # <tt>:dsl_method</tt>.
    # 
    # === Warning about the +return+ keyword
    # 
    # Because you are implementing your method using a block, remember the
    # distinction between <tt>Proc.new</tt> and +lambda+. Invoking +return+
    # from the former does not return from the block, but returns from the
    # surrounding method scope. Since normal blocks passed to methods are
    # of the former type, be very careful about using the +return+ keyword:
    # 
    #  add_method(:foo) do |param|
    #    puts "foo called with parameter "+param.inspect
    #    return "a return value"   # DOESN'T WORK LIKE YOU EXPECT!
    #  end
    # 
    # To return a value from the method you are creating, set the evaluation
    # value at the end of the block:
    # 
    #  add_method(:foo) do |param|
    #    puts "foo called with parameter "+param.inspect
    #    "a return value"    # Returns from method foo
    #  end
    # 
    # If you must use the +return+ keyword, create your block as a lambda
    # as in this example:
    # 
    #  code = lambda do |param|
    #    puts "foo called with parameter "+param.inspect
    #    return "a return value"   # Returns from method foo
    #  end
    #  add_method(:foo, &code)
    # 
    # === Accepting a block argument
    # 
    # If you want your method to take a block, you have several options
    # depending on your Ruby version. If you are running the standard Matz
    # Ruby interpreter (MRI) version 1.8.7 or later (including 1.9.x), you
    # can use the standard "&" block argument notation to receive the block.
    # Note that you must call the passed block using the +call+ method since
    # Ruby doesn't support invoking such a block with +yield+.
    # For example, to create a method named "foo" that takes one parameter
    # and a block, do this:
    # 
    #  add_method(:foo) do |param, &block|
    #    puts "foo called with parameter "+param.inspect
    #    puts "the block returned "+block.call.inspect
    #  end
    # 
    # In your DSL, you can then call:
    # 
    #  foo("hello"){ "a value" }
    # 
    # If you are using MRI 1.8.6, however, the parser does not support
    # passing a block argument to a block. Oddly, the current version of
    # JRuby (version 1.4.0 as of this writing) also does not support this
    # syntax, though it claims MRI 1.8.7 compatibility. (See bug JRUBY-4180
    # to track this issue.) If your Ruby interpreter doesn't support the
    # standard way to create a method that takes a block, Blockenspiel
    # provides an alternative in the form of the <tt>:block</tt> option.
    # This option causes blocks provided by the caller to be included in
    # the normal parameter list to your method, instead of as a block
    # parameter. It can be set to <tt>:first</tt> or <tt>:last</tt> to
    # prepend or append, respectively, the block (as a +Proc+ object) to
    # the parameter list. If the caller does not include a block when
    # calling your DSL method, nil is prepended/appended. For example:
    # 
    #  add_method(:foo, :block => :last) do |param, block|
    #    puts "foo called with parameter "+param.inspect
    #    if block
    #      puts "the block returned "+block.call.inspect
    #    else
    #      puts "no block passed"
    #    end
    #  end
    # 
    # The <tt>:receive_block</tt> option is a deprecated alternative.
    # Setting <tt>:receive_block => true</tt> is currently equivalent to
    # setting <tt>:block => :last</tt>.
    
    def add_method(name_, opts_={}, &block_)
      receive_block_ = opts_[:receive_block] ? :last : opts_[:block]
      receive_block_ = :first if receive_block_ && receive_block_ != :last
      @target_class._add_methodinfo(name_, block_, receive_block_)
      dsl_method_name_ = opts_[:dsl_method] || opts_[:mixin]
      if dsl_method_name_ != false
        dsl_method_name_ = name_ if dsl_method_name_.nil? || dsl_method_name_ == true
        @target_class.dsl_method(dsl_method_name_, name_)
      end
    end
    
  end
  
  
  # :stopdoc:
  NO_VALUE = ::Object.new
  # :startdoc:
  
  @_target_stacks = ::Hash.new
  @_mixin_counts = ::Hash.new
  @_proxy_delegators = ::Hash.new
  @_mutex = ::Mutex.new
  
  
  # === Invoke a given block
  # 
  # This is the meat of Blockenspiel. Call this function to invoke a block
  # provided by the user of your API.
  # 
  # For example, if you want users of your API to be able to do this:
  # 
  #  call_dsl do
  #    foo(1)
  #    bar(2)
  #  end
  # 
  # Then you should implement <tt>call_dsl</tt> like this:
  # 
  #  def call_dsl(&block)
  #    my_dsl = create_block_implementation
  #    Blockenspiel.invoke(block, my_dsl)
  #    do_something_with(my_dsl)
  #  end
  # 
  # In the above, <tt>create_block_implementation</tt> is a placeholder that
  # returns an instance of your DSL methods class. This class includes the
  # Blockenspiel::DSL module and defines the DSL methods +foo+ and +bar+.
  # 
  # Normally, this method will check the block's arity to see whether it
  # takes a parameter. If so, it will pass the given target to the block.
  # If the block takes no parameter, and the given target is an instance of
  # a class with DSL capability, the DSL methods are made available on the
  # caller's self object so they may be called without a block parameter.
  # 
  # === Recognized options
  # 
  # <tt>:parameterless</tt>::
  #   If set to false, disables parameterless blocks and always attempts to
  #   pass a parameter to the block. Otherwise, you may set it to one of
  #   three behaviors for parameterless blocks: <tt>:mixin</tt> (the
  #   default), <tt>:instance</tt>, and <tt>:proxy</tt>. See below for
  #   detailed descriptions of these behaviors.
  # <tt>:parameter</tt>::
  #   If set to false, disables blocks with parameters, and always attempts
  #   to use parameterless blocks. Default is true, enabling parameter mode.
  # 
  # The following values control the precise behavior of parameterless
  # blocks. These are values for the <tt>:parameterless</tt> option.
  # 
  # <tt>:mixin</tt>::
  #   This is the default behavior. DSL methods from the target are
  #   temporarily overlayed on the caller's +self+ object, but +self+ still
  #   points to the same object, so the helper methods and instance
  #   variables from the caller's closure remain available. The DSL methods
  #   are removed when the block completes.
  # <tt>:instance</tt>::
  #   This behavior actually changes +self+ to the target object using
  #   <tt>instance_eval</tt>. Thus, the caller loses access to its own
  #   helper methods and instance variables, and instead gains access to the
  #   target object's instance variables. The target object's methods are
  #   not modified: this behavior does not apply any DSL method changes
  #   specified using <tt>dsl_method</tt> directives.
  # <tt>:proxy</tt>::
  #   This behavior changes +self+ to a proxy object created by applying the
  #   DSL methods to an empty object, whose <tt>method_missing</tt> points
  #   back at the block's context. This behavior is a compromise between
  #   instance and mixin. As with instance, +self+ is changed, so the caller
  #   loses access to its own instance variables. However, the caller's own
  #   methods should still be available since any methods not handled by the
  #   DSL are delegated back to the caller. Also, as with mixin, the target
  #   object's instance variables are not available (and thus cannot be
  #   clobbered) in the block, and the transformations specified by
  #   <tt>dsl_method</tt> directives are honored.
  # 
  # === Dynamic target generation
  # 
  # It is also possible to dynamically generate a target object by passing
  # a block to this method. This is probably best illustrated by example:
  # 
  #  Blockenspiel.invoke(block) do
  #    add_method(:set_foo) do |value|
  #      my_foo = value
  #    end
  #    add_method(:set_things_from_block) do |value, &blk|
  #      my_foo = value
  #      my_bar = blk.call
  #    end
  #  end
  # 
  # The above is roughly equivalent to invoking Blockenspiel with an
  # instance of this target class:
  # 
  #  class MyFooTarget
  #    include Blockenspiel::DSL
  #    def set_foo(value)
  #      set_my_foo_from(value)
  #    end
  #    def set_things_from_block(value)
  #      set_my_foo_from(value)
  #      set_my_bar_from(yield)
  #    end
  #  end
  #  
  #  Blockenspiel.invoke(block, MyFooTarget.new)
  # 
  # The obvious advantage of using dynamic object generation is that you are
  # creating methods using closures, which provides the opportunity to, for
  # example, modify closure local variables such as my_foo. This is more
  # difficult to do when you create a target class since its methods do not
  # have access to outside data. Hence, in the above example, we hand-waved,
  # assuming the existence of some method called "set_my_foo_from".
  # 
  # The disadvantage is performance. If you dynamically generate a target
  # object, it involves parsing and creating a new class whenever it is
  # invoked. Thus, it is recommended that you use this technique for calls
  # that are not used repeatedly, such as one-time configuration.
  # 
  # See the Blockenspiel::Builder class for more details on add_method.
  # 
  # When using dynamic target generation, you may pass the options hash as
  # the second argument to invoke instead of the third, since you will not
  # be passing a target object as the second argument.
  # 
  # (And yes, you guessed it: this API is a DSL block, and is itself
  # implemented using Blockenspiel.)
  
  def self.invoke(block_, target_=nil, opts_={}, &builder_block_)
    
    unless block_
      raise ::ArgumentError, "Block expected"
    end
    
    # Perform dynamic target generation if requested
    if builder_block_
      # Support passing the opts hash as the second argument since we
      # aren't passing a target as an argument.
      opts_ = target_ || opts_
      builder_ = ::Blockenspiel::Builder.new
      invoke(builder_block_, builder_)
      target_ = builder_._create_target
    end
    
    # Read options
    parameter_ = opts_[:parameter]
    parameterless_ = opts_[:parameterless]
    
    # Handle no-target behavior
    if parameter_ == false && parameterless_ == false
      if block_.arity != 0 && block_.arity != -1
        raise ::Blockenspiel::BlockParameterError, "Block should not take parameters"
      end
      return block_.call
    end
    
    # Handle parametered block case
    if parameter_ != false && block_.arity == 1 || parameterless_ == false
      if block_.arity != 1
        raise ::Blockenspiel::BlockParameterError, "Block should take exactly one parameter"
      end
      return block_.call(target_)
    end
    
    # Check arity for parameterless case
    if block_.arity != 0 && block_.arity != -1
      raise ::Blockenspiel::BlockParameterError, "Block should not take parameters"
    end
    
    # Handle instance-eval behavior
    if parameterless_ == :instance
      return target_.instance_eval(&block_)
    end
    
    # Get the module of dsl methods
    mod_ = target_.class._get_blockenspiel_module rescue nil
    unless mod_
      raise ::Blockenspiel::DSLMissingError
    end
    
    # Get the block's calling context object
    object_ = ::Kernel.eval('self', block_.binding)
    
    # Handle proxy behavior
    if parameterless_ == :proxy
      
      # Create proxy object
      proxy_ = ::Blockenspiel::ProxyDelegator.new
      proxy_.extend(mod_)
      
      # Store the target and proxy object so dispatchers can get them
      proxy_delegator_key_ = proxy_.object_id
      target_stack_key_ = [::Thread.current.object_id, proxy_.object_id]
      @_proxy_delegators[proxy_delegator_key_] = object_
      @_target_stacks[target_stack_key_] = [target_]
      
      begin
        
        # Call the block with the proxy as self
        return proxy_.instance_eval(&block_)
        
      ensure
        
        # Clean up the dispatcher information
        @_proxy_delegators.delete(proxy_delegator_key_)
        @_target_stacks.delete(target_stack_key_)
        
      end
      
    end
     
    # Handle mixin behavior (default)
    
    # Create hash keys
    mixin_count_key_ = [object_.object_id, mod_.object_id]
    target_stack_key_ = [::Thread.current.object_id, object_.object_id]
    
    # Store the target for inheriting.
    # We maintain a target call stack per thread.
    target_stack_ = @_target_stacks[target_stack_key_] ||= ::Array.new
    target_stack_.push(target_)
    
    # Mix this module into the object, if required.
    # This ensures that we keep track of the number of requests to
    # mix this module in, from nested blocks and possibly multiple threads.
    @_mutex.synchronize do
      count_ = @_mixin_counts[mixin_count_key_]
      if count_
        @_mixin_counts[mixin_count_key_] = count_ + 1
      else
        @_mixin_counts[mixin_count_key_] = 1
        object_.extend(mod_)
      end
    end
    
    begin
      
      # Now call the block
      return block_.call
      
    ensure
      
      # Clean up the target stack
      target_stack_.pop
      @_target_stacks.delete(target_stack_key_) if target_stack_.size == 0
      
      # Remove the mixin from the object, if required.
      @_mutex.synchronize do
        count_ = @_mixin_counts[mixin_count_key_]
        if count_ == 1
          @_mixin_counts.delete(mixin_count_key_)
          ::Blockenspiel::Unmixer.unmix(object_, mod_)
        else
          @_mixin_counts[mixin_count_key_] = count_ - 1
        end
      end
      
    end
    
  end
  
  
  # This implements the mapping between DSL module methods and target object methods.
  # We look up the current target object based on the current thread.
  # Then we attempt to call the given method on that object.
  # If we can't find an appropriate method to call, return the special value NO_VALUE.
  
  def self._target_dispatch(object_, name_, params_, block_)  # :nodoc:
    target_stack_ = @_target_stacks[[::Thread.current.object_id, object_.object_id]]
    return ::Blockenspiel::NO_VALUE unless target_stack_
    target_stack_.reverse_each do |target_|
      target_class_ = target_.class
      delegate_ = target_class_._get_blockenspiel_delegate(name_)
      if delegate_ && target_class_.public_method_defined?(delegate_)
        return target_.send(delegate_, *params_, &block_)
      end
    end
    return ::Blockenspiel::NO_VALUE
  end
  
  
  # This implements the proxy fall-back behavior.
  # We look up the context object, and call the given method on that object.
  
  def self._proxy_dispatch(proxy_, name_, params_, block_)  # :nodoc:
    @_proxy_delegators[proxy_.object_id].send(name_, *params_, &block_)
  end
  
  
end
