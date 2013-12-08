# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
require 'rmagick'

include OpenCV

if ARGV.length  < 2
  puts "Usage: ruby #{__FILE__} source dest"
  exit
end

data       = './data/haarcascade_eye.xml'
card_image = './image/card.png'

detector = CvHaarClassifierCascade::load(data)

card  = IplImage::load(card_image)

image = CvMat.load(ARGV[0])
image.save_image(ARGV[1])
s_image = CvMat.load(ARGV[1])

first_eye_center_x = 0
first_eye_center_y = 0
first_eye_width = 0
first_eye_height = 0

detector.detect_objects(image).each_with_index do |region, i|
  if i % 2 ==  0
    first_eye_center_x = region.center.x
    first_eye_center_y = region.center.y
    first_eye_width = region.top_right.x - region.top_left.x
    first_eye_height = region.bottom_left.y - region.top_left.y

    card_size = CvSize.new(first_eye_width * 1.6 * 0.8, first_eye_height * 0.8)
    card = card.resize(card_size)
    card.save_image('./image/resize_card.jpg')
  end

  generate_image    = Magick::ImageList.new(ARGV[1])
  resize_card_image = Magick::ImageList.new('./image/resize_card.jpg')

  x = region.center.x - first_eye_width / 2
  y = region.center.y - first_eye_height / 2

  generate_image.composite!(resize_card_image, x, y, Magick::OverCompositeOp);
  generate_image.write(ARGV[1])
end
