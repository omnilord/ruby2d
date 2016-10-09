# window.rb

module Ruby2D
  class Window
    attr_reader :title, :width, :height, :mouse_x, :mouse_y
    
    def initialize(width: 640, height: 480, title: "Ruby 2D", fps: 60, vsync: true)
      @title = title
      @width, @height = width, height
      @viewport_width, @viewport_height = nil, nil
      @background = Color.new([0.0, 0.0, 0.0, 1.0])
      @resizable = false
      @mouse_x = @mouse_y = 0
      @fps_cap = fps
      @fps = 60
      @vsync = vsync
      @objects = []
      @keys, @keys_up, @keys_down, @controller = {}, {}, {}, {}
      @on_key_proc = Proc.new {}
      @on_controller_proc = Proc.new {}
      @update_proc = Proc.new {}
    end
    
    def get(sym)
      case sym
      when :window;  self
      when :title;   @title
      when :width;   @width
      when :height;  @height
      when :fps;     @fps
      when :mouse_x; @mouse_x
      when :mouse_y; @mouse_y
      end
    end
    
    def set(opts)
      # Store new window attributes, or ignore if nil
      @title           = opts[:title]           || @title
      @width           = opts[:width]           || @width
      @height          = opts[:height]          || @height
      @viewport_width  = opts[:viewport_width]  || @viewport_width
      @viewport_height = opts[:viewport_height] || @viewport_height
      @resizable       = opts[:resizable]       || @resizable
      @borderless      = opts[:borderless]      || @borderless
      @fullscreen      = opts[:fullscreen]      || @fullscreen
      @highdpi         = opts[:highdpi]         || @highdpi
      if Color.is_valid? opts[:background]
        @background    = Color.new(opts[:background])
      end
    end
    
    def add(o)
      case o
      when nil
        raise Error, "Cannot add '#{o.class}' to window!"
      when Array
        o.each { |x| add_object(x) }
      else
        add_object(o)
      end
    end
    
    def remove(o)
      if o == nil
        raise Error, "Cannot remove '#{o.class}' from window!"
      end
      
      if i = @objects.index(o)
        @objects.slice!(i)
        true
      else
        false
      end
    end
    
    def clear
      @objects.clear
    end
    
    def update(&proc)
      @update_proc = proc
      true
    end
    
    def on(mouse: nil, key: nil, key_up: nil, key_down: nil, controller: nil, &proc)
      unless mouse.nil?
        # reg_mouse(btn, &proc)
      end
      
      unless key.nil?
        reg_key(key, &proc)
      end
      
      unless key_up.nil?
        reg_key_up(key_up, &proc)
      end
      
      unless key_down.nil?
        reg_key_down(key_down, &proc)
      end
      
      unless controller.nil?
        reg_controller(controller, &proc)
      end
    end
    
    def on_key(&proc)
      @on_key_proc = proc
      true
    end
    
    def key_callback(key)
      key.downcase!
      @on_key_proc.call(key)
      if @keys.has_key? key
        @keys[key].call
      end
    end
    
    def key_up_callback(key)
      key.downcase!
      if @keys_up.has_key? 'any'
        @keys_up['any'].call
      end
      if @keys_up.has_key? key
        @keys_up[key].call
      end
    end
    
    def key_down_callback(key)
      key.downcase!
      if @keys_down.has_key? key
        @keys_down[key].call
      end
    end
    
    def on_controller(&proc)
      @on_controller_proc = proc
      true
    end
    
    def controller_callback(which, is_axis, axis, val, is_btn, btn)
      @on_controller_proc.call(which, is_axis, axis, val, is_btn, btn)
      
      if is_axis
        if axis == 0 && val == -32768
          event = 'left'
        elsif axis == 0 && val == 32767
          event = 'right'
        elsif axis == 1 && val == -32768
          event = 'up'
        elsif axis == 1 && val == 32767
          event = 'down'
        end
      elsif is_btn
        event = btn
      end
      
      if @controller.has_key? event
        @controller[event].call
      end
    end
    
    def update_callback
      @update_proc.call
    end
    
    private
    
    def add_object(o)
      if !@objects.include?(o)
        @objects.push(o)
        true
      else
        false
      end
    end
    
    # Register key string with proc
    def reg_key(key, &proc)
      @keys[key] = proc
      true
    end
    
    # Register key string with proc
    def reg_key_up(key, &proc)
      @keys_up[key] = proc
      true
    end
    
    # Register key string with proc
    def reg_key_down(key, &proc)
      @keys_down[key] = proc
      true
    end
    
    # Register controller string with proc
    def reg_controller(event, &proc)
      @controller[event] = proc
      true
    end
    
  end
end
