require 'test_helper'

# bundle exec rake test:models

class ProductTest < ActiveSupport::TestCase

  # Loads fixture database before the test is run
  # loads /test/fixtures/products.yaml
  # Rails is smart about using the test database for this data
  # when you run `rake test`
  # Further, empties the database of old references
  # Instead of using Model#find, using fixtures allows access to
  # model_name.pluralize(:yaml_name) for testing models
  
  fixtures :products

  def new_product(image_url)
    Product.new(
      title: 'Mah Book Title',
      description: 'Yolo',
      image_url: image_url,
      price: 1
    )
  end

  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test 'product price must be positive' do
    product = Product.new(
      title: 'Mah Book Title',
      description: 'Yolo',
      image_url: 'zzz.jpg'
    )
    
    product.price = -1
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  test 'image url' do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }

    ok.each do |name|
      assert new_product(name).valid?, "#{name} should be valid"
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} should be invalid"
    end

  end

  test 'product is not valid without a unique title' do
    product = Product.new(
      title: products(:ruby).title,
      description: 'yyy',
      price: 1,
      image_url: 'zzz.png'
    )

    assert product.invalid?
    # Don't like how brittle this test is when the message is changed
    # on the model
#   assert_equal ["has already been taken"], product.errors[:title]
    assert_equal [I18n.translate('errors.messages.taken')], product.errors[:title]
  end

  test 'product title is longer than 10 characters' do
    product = Product.new(
      title: '2short',
      description: 'yyy',
      price: 1,
      image_url: 'zzz.png'
    )
    assert product.invalid?
#   assert_equal ["is too short (minimum is 10 characters)"], product.errors[:title]
  end

end
