class Car
  SPRITE_FOLDER = "sprites/car"
  WIDTH = 14
  HEIGHT = 20

  attr_reader :x, :y
  attr_accessor :angle, :spread, :scale

  def initialize(args, scale: 6)
    @grid = args.grid
    @outputs = args.outputs

    @x = 0
    @y = 0
    @scale = scale
    @angle = 0
    @spread = 0
  end

  def handle_input(inputs)
    if inputs.keyboard.left
      self.angle += 1
    elsif inputs.keyboard.right
      self.angle -= 1
    end

    if inputs.keyboard.up || inputs.keyboard.key_down.close_square_brace
      self.spread += 1
    elsif inputs.keyboard.down || inputs.keyboard.key_down.open_square_brace
      self.spread -= 1
    end

    if inputs.keyboard.key_down.equal_sign
      return if scale == 15

      self.scale += 1
    elsif inputs.keyboard.key_down.minus
      return if scale == 1

      self.scale -= 1
    end
  end

  def render
    outputs.sprites << sprites
  end

  def serialize
    {}
  end

  private

  attr_reader :grid, :outputs
  attr_writer :x, :y

  def calculate_x
    self.x = grid.w.half - (WIDTH.half * scale)
  end

  def calculate_y
    self.y = grid.h.half - (HEIGHT.half * scale)
  end

  def sprites
    (0..6).to_a.map_with_index do |layer_number, index|
      {
        x: calculate_x,
        y: calculate_y - (1 * spread) + (index * spread),
        w: WIDTH * scale,
        h: HEIGHT * scale,
        path: "#{SPRITE_FOLDER}/img_#{layer_number}.png",
        angle: angle,
        source_x: 0,
        source_w: WIDTH,
        source_h: HEIGHT,
      }
    end
  end
end

def debug(args)
  left_padding = 30

  args.outputs.labels << [left_padding, 30.from_top, "FPS: #{args.gtk.current_framerate.to_sf}"]
  args.outputs.labels << [left_padding, 55.from_top, "X: #{args.state.car.x.to_sf}"]
  args.outputs.labels << [left_padding, 80.from_top, "Y: #{args.state.car.y.to_sf}"]
  args.outputs.labels << [left_padding, 105.from_top, "ANGLE: #{args.state.car.angle.to_sf}"]
  args.outputs.labels << [left_padding, 130.from_top, "SPREAD: #{args.state.car.spread.to_sf}"]
  args.outputs.labels << [left_padding, 155.from_top, "SCALE: #{args.state.car.scale.to_sf}"]
end

def instructions(args)
  right_padding = args.grid.w - 330

  args.outputs.labels << [right_padding, 30.from_top, "A/D || LEFT/RIGHT: Rotate".rjust(30)]
  args.outputs.labels << [right_padding, 55.from_top, "W/S || UP/DOWN: Spread".rjust(30)]
  args.outputs.labels << [right_padding, 80.from_top, "[ or ]: Spread (fine)".rjust(30)]
  args.outputs.labels << [right_padding, 105.from_top, "= or -: Scale".rjust(30)]
end

def tick(args)
  args.state.car ||= Car.new(args)

  debug(args)
  instructions(args)

  args.state.car.handle_input(args.inputs)
  args.state.car.render
end
